#!/bin/bash

# the `date` command requires GNU date.

# examples:
# ./cslogger_metadata.sh 1 D "BE" "2021-07-01" "2022-09-30"
# ./cslogger_metadata.sh 1 D "PA" "2022-10-01" "2023-04-01"

# config
nb_org="cslogger_metadata"
nb_version='v1.0.1'
latest="false"
latest_path="/srv/meteo/scratch/latest/AWS/data/{production_level}/"

# input args
dv=${1:-1}
dk=${2:-M}
dc=${3:-PA}
input_start=${4:-none}
input_end=${5:-none}

# input config
if [[ "$dk" == "M" ]]; then
    du=month
    dt=$(( dv*1 ))
    df="%Y-%m-%d"
elif [[ "$dk" == "D" ]]; then
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
toml_add=()

# eval loc: split city and sensor id, e.g., "BE:T2920393"
if [[ $dc =~ ":" ]]; then
query_ids=("${dc##*:}")
dc=${dc%%:*}
fi

# eval loc: general 
if [[ "$dc" == "PA" ]]; then
cty_code='PA'
cty_glob='fr.paris'
cty_path='by-source/smurobs/by-serialnr/France/Paris'
elif [[ "$dc" == "BE" ]]; then
cty_code='BE'
cty_glob='de.berlin'
cty_path='by-source/smurobs/by-location/Germany/Berlin'
elif [[ "$dc" == "FR" ]]; then
cty_code='FR'
cty_glob='de.freiburg'
cty_path='by-source/ufrmeteo/by-location/Germany/Freiburg'
else
    echo "Location not know."
    exit 1
fi

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
        echo -e "\n## ----------------------------------" >> ${nb_run}.toml 
        echo -e "## ${nb_version} -- Added During Automation --" >> ${nb_run}.toml 
        echo -e "[[${nb_org}]]" >> ${nb_run}.toml 
        echo -e "version.id = '${nb_version}'\n" >> ${nb_run}.toml  
        echo -e "query.latest = ${latest}" >> ${nb_run}.toml          
        echo -e "query.cache = false" >> ${nb_run}.toml         
        echo -e "query.start = '${d0}'" >> ${nb_run}.toml         
        echo -e "query.period = '${dv}${dk}'" >> ${nb_run}.toml       
        echo -e "query.system_index = '${id}'" >> ${nb_run}.toml   
        echo -e "query.city = '${cty_code}'" >> ${nb_run}.toml  
        echo -e "input.subset.global_location = '${cty_glob}'" >> ${nb_run}.toml  
        echo -e "input.path = ['${cty_path}/']" >> ${nb_run}.toml 
        echo -e "output.path = '${cty_path/by-serialnr/by-location}/{station_id}/{system_group}/{system_id}/'" >> ${nb_run}.toml 


        if [[ "$latest" == "true" ]]; then
            echo -e "output.path_base = '${latest_path}'\n" >> ${nb_run}.toml
            echo "  Warning: 'output_path_base' = '${latest_path}'"
        fi
        
        if (( ${#toml_add[@]} != 0 )); then
            for add in "${toml_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done
            echo "  Warning: added lines from an array to the TOML config file."
        fi        
        
        sleep 5 ;
        { ( nice -n 10 \
          conda run -n status310v1 \
          papermill "notebooks/${nb_org}.ipynb" "${nb_run}.ipynb" -p ioconfig_file "${nb_run}.toml"
          ) } 2>/dev/null
    done

    # Collect all background processes.
    wait
    
    d0=$(date -u -d "$d0 $dt $du" +"%Y-%m-%d %H:%M:%S")
    d1=$(date -u -d "$d1 $dt $du" +"%Y-%m-%d %H:%M:%S")  
    nextdate=$(date -u -d "$d0" +"%s")   
done


