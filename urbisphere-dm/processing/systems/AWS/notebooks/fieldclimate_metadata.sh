#!/bin/bash

# examples:
# ./fieldclimate_metadata.sh 1 D "FR:AWS" $(date --date="-1 day" +%F) $(date --date="0 day" +%F)
# ./fieldclimate_metadata.sh 1 H

join_arr() {
  local IFS="$1"
  shift
  echo "$*"
}

# config
nb_org="fieldclimate_metadata"
nb_version='v1.0.5'
latest="false"
latest_path="/srv/meteo/scratch/z--m-n/AWS/{version_id}/data/{production_level}/"
latest_cache="data/{version_id}/cache/{production_level}/"

# input args
dv=${1:-1}
dk=${2:-M}
dc=${3:-FR}
input_start=${4:-none}
input_end=${5:-none}

# input config
if [[ "$dk" == "D" ]]; then
    du=hour
    dt=$(( dv*24 ))
    df="%Y-%m-%d"
else
    du=hour
    dt=$(( dv*1 ))
    df="%Y-%m-%d %H:00:00"
fi

# eval latest
if [[ "$input_start" == "none" || "$input_end" == "latest"  ]]; then
    latest="true"
fi

# eval start
if [[ "$input_start" == "none" ]]; then
    input_start=$(date -u -d "0 $du" +"$df")   
fi

# eval end
if [[ "$input_end" == "none" || "$input_end" == "latest" ]]; then
    input_end=$(date -u -d "$dt $du" +"$df")     
fi

# eval loc
query_ids=("")
query_tasks=()
toml_add=("" "# Added lines (toml_add):")

# eval loc: split city and sensor id, e.g., "BE:T2920393"
if [[ $dc =~ ":" ]]; then
query_ids=("${dc##*:}")
dc=${dc%%:*}
fi

# eval loc: general 
if [[ "$dc" == "ALL" ]]; then
cty_code='FR'
cty_glob='de.freiburg'
cty_path='by-source/smurobs/by-serialnr/Germany/Freiburg'
production_profile="set(de.freiburg,AWS,%s)"
query_tasks+=( "'query'" )
elif [[ "$dc" == "FR" ]]; then
cty_code='FR'
cty_glob='de.freiburg'
cty_path='by-source/smurobs/by-serialnr/Germany/Freiburg'
production_profile="set(de.freiburg,AWS,%s)"
# query_tasks+=( "'query'" )
query_tasks+=( "'convert'" "'combine'" )
elif [[ "$dc" == "BR" ]]; then
cty_code='BR'
cty_glob='uk.bristol'
cty_path='by-source/smurobs/by-serialnr/UK/Bristol'
production_profile="set(uk.bristol,AWS,%s)"
query_tasks+=( "'convert'" "'combine'" )
else
    echo "Location not know."
    exit 1
fi


if [[ "$latest" == "true" ]]; then
if [[ "${query_ids[@]}" == "" ]]; then
    query_ids=("${dv}${dk}")
fi
toml_add+=( "query.cache = false" )
toml_add+=( "" )
toml_add+=( "cache.path_base = '${latest_cache}'" )
toml_add+=( "output.path_base = '${latest_path}'" )
toml_add+=( "" )
toml_add+=( "logging.filemode = 'w'" )
toml_add+=( "logging.file = '${nb_org}_${dc}_${dk}_latest.log'" )
elif [[ "$latest" == "false" ]]; then
if [[ "${query_ids[@]}" == "" ]]; then
    query_ids=("${dv}${dk}x")
fi
toml_add+=( "query.cache = true" )
toml_add+=( "" )
toml_add+=( "logging.file = '${nb_org}_${dc}_${dk}.log'" )
toml_add+=( "logging.filemode = 'a'" )
query_tasks+=( "'clean'" )
fi

toml_add+=("" "# Added lines (toml_add) for location:")
toml_add+=( "query.city = '${cty_code}'" )
toml_add+=( "output.subset.global_location = '${cty_glob}'" )
toml_add+=( "" )
if [[ "$cty_code" == "BR" ]]; then
toml_add+=( "output.subset.sensor_name = 'nMETOS100+'" )
toml_add+=( "output.subset.system_name = 'nMETOS100+'" )
toml_add+=( "input.path = 'by-source/smurobs/by-serialnr/Germany/Freiburg/{station_id}/{time_query}/'" )
fi
toml_add+=( "" )
toml_add+=( "cache.path = '${cty_path}/{station_id}/{time_query}/'" )
toml_add+=( "output.path = '${cty_path/by-serialnr/by-location}/{station_id}/{system_group}/{system_id}/'" )
toml_add+=( "" )
toml_add+=( "query.tasks = [$(join_arr , "${query_tasks[@]}")]" )

# Arrays, last item
#toml_add+=( "" "[[${nb_org}.gattrs]]" )
#toml_add+=( "production_profile = '${production_profile}'" )


# After this, startdate and enddate will be valid ISO 8601 dates,
# or the script will have aborted when it encountered unparseable data
# such as input_end=abcd

startdate=$(date -u -d "$input_start")   || exit -1
enddate=$(date -u -d "$input_end" +"%s") || exit -1

# Additional loop variables
d0=$(date -u -d "$startdate   0 $du" +"%Y-%m-%d %H:%M:%S")
d1=$(date -u -d "$startdate $dt $du" +"%Y-%m-%d %H:%M:%S")
nextdate=$(date -u -d "$d0" +"%s")

while [ "$nextdate" -lt "$enddate" ]; do

    # papermill [OPTIONS] NOTEBOOK_PATH [OUTPUT_PATH]
    for id in "${query_ids[@]}" ; do 
        echo  $(date +"[%Y-%m-%d %H:%M:%S]") "${d0} to ${d1}" "// Period:[$dt $du][$dv$dk]  Latest:[${latest}] ID:[${id}] Loc:[${dc}][${cty_code}]" 
        nb_run="_tmp_${nb_org}_${dc}_${id}"       
        cat "conf/${nb_org}.toml" > ${nb_run}.toml
        echo -e "\n\n## ----------------------------------" >> ${nb_run}.toml 
        echo -e "## ${nb_version} -- Added During Automation " >> ${nb_run}.toml 
        echo -e "[[${nb_org}]]" >> ${nb_run}.toml 
        echo -e "version.id = '${nb_version}'\n" >> ${nb_run}.toml  
        echo -e "query.latest = ${latest}" >> ${nb_run}.toml    
        echo -e "query.start = '${d0}'" >> ${nb_run}.toml
        echo -e "query.period = '${dv}${dk}'" >> ${nb_run}.toml
        echo -e "" >> ${nb_run}.toml            
            

        loop_add=()
        dY=$(date -u -d "$d0" +"%Y")
        if [[ "$dc" == "FR" && (( $dY > 2021 )) && (( $dY < 2025 )) ]]; then
            loop_add+=( "" )
            loop_add+=( "[[${nb_org}.gattrs]]" )
            loop_add+=( "production_profile = '$(printf ${production_profile} "2022_2024" )'" )
        else
            loop_add+=( "" )
            loop_add+=( "[[${nb_org}.gattrs]]" )
            loop_add+=( "production_profile = '$(printf ${production_profile} "${dY}" )'" )
        fi

        if [[ "$latest" == "true" ]]; then
            echo "  Warning: 'output_path_base' = '${latest_path}'"
        fi
        
        if (( ${#toml_add[@]} != 0 )); then
            echo "  Warning: added lines from an array to the TOML config file."        
            for add in "${toml_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done

        fi  

        if (( ${#loop_add[@]} != 0 )); then
            echo "  Warning: added lines from an array to the TOML config file."        
            for add in "${loop_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done

        fi   

        sleep 5 ;
        { ( nice -n 10 \
          conda run -n status310v1 \
          papermill "notebooks/${nb_org}.ipynb" "${nb_run}.ipynb" -p ioconfig_file "${nb_run}.toml"
          ) }  2>/dev/null
    done

    # Collect all background processes.
    wait
    
    d0=$(date -u -d "$d0 $dt $du" +"%Y-%m-%d %H:%M:%S")
    d1=$(date -u -d "$d1 $dt $du" +"%Y-%m-%d %H:%M:%S")  
    nextdate=$(date -u -d "$d0" +"%s")     
done
