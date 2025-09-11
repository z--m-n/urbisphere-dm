#!/bin/bash

# examples:
# ./datasets_api.sh 1 D "FR:AWS" "$(date -u -d "-1 hours" +"%F %H:00:00")" "$(date -u -d "0 hours" +"%F %H:00:00")"


# config
nb_org="datasets_api"
nb_version='v1.0.3'
latest="false"
latest_add=(
 ""
)

# input args
dv=${1:-1}
dk=${2:-M}
dc=${3:-FR}
input_start=${4:-none}
input_end=${5:-none}

# input config
if [[ "$dk" == "Y" ]]; then
    du=month
    dt=$(( dv*12 ))
    df="%Y-01-01"
elif [[ "$dk" == "M" ]]; then
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
    input_start=$(date -u -d  "0 $du" +"$df")   
fi

# eval end
if [[ "$input_end" == "none" || "$input_end" == "latest" ]]; then   
    input_end=$(date -u -d  "$dt $du" +"$df")    
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
if [[ "$dc" == "FR" ]]; then
# nb_version='v1.0.3'
cty_code='FR'
cty_glob='de.freiburg'
cty_path='by-source/smurobs/by-location/Germany/Freiburg'
toml_add=( ""
 "logging.filemode = 'w'"
 ""
 "query.cache = true"
 ""
 "input.subset.version = 'v1.0.5'"
 "input.subset.system_name = ['LoRAIN', 'Zero W']"
 "input.subset.system_group = 'AWS'"
 "input.subset.global_location = '${cty_glob}'"  
 "input.subset.campaign_location = '${cty_code}'" 
 ""
 "input.path_base = ['/srv/meteo/sandbox/zeeman/{system_group}/{version}/data/L1/','/srv/meteo/scratch/zeeman/{system_group}/{version}/data/L1/']"
 "input.path = ['${cty_path}/{system_group}/']"
 ""
 "cache.path_base = './tmp/'"
 "cache.path = './cache/'"
 "" 
 "output.path_base = '127.0.0.1:55555'"
 "output.path = '/public/freiburg/api/v1/'"
 "" 
 "output.api.mapbox.customAttribution = 'Data: <a href=\"http://www.uni-freiburg.de/en/\">University of Freiburg</a>, Funding: European Research Council (ERC) Grant: 855005'"

)
elif [[ "$dc" == "BR" ]]; then
# nb_version='v1.0.3'
cty_code='BR'
cty_glob='uk.bristol'
cty_path='by-source/smurobs/by-location/UK/Bristol'
toml_add=( ""
 "logging.filemode = 'w'"
 ""
 "query.cache = true"
 ""
 "input.subset.version = 'v1.0.5'"
 "input.subset.system_name = ['LoRAIN']"
 "input.subset.system_group = 'AWS'"
 "input.subset.global_location = '${cty_glob}'"  
 "input.subset.campaign_location = '${cty_code}'" 
 ""
 "input.path_base = ['/srv/meteo/sandbox/zeeman/{system_group}/{version}/data/L1/','/srv/meteo/scratch/zeeman/{system_group}/{version}/data/L1/']"
 "input.path = ['${cty_path}/{system_group}/']"
 ""
 "cache.path_base = './tmp/'"
 "cache.path = './cache/'"
 ""
 "output.path_base = '127.0.0.1:55555'"
 "output.path = '/public/bristol/api/v1/'"
 ""
 "output.api.mapbox.customAttribution = 'Data: <a href=\"http://www.uni-freiburg.de/en/\">University of Freiburg</a> / University of Reading, Funding: European Research Council (ERC) Grant: 855005'"
)
else
    echo "Location not know."
    exit 1
fi

# reduce workload and output for real-time applications 
if [[ "$dk" == "H" ]]; then
    toml_add+=( "" "# Warning: replacing default settings" )
    toml_add+=( "query.tasks = ['cache']" )    
    toml_add+=( "" )
fi

if [[ "$dk" == "D" ]]; then
    toml_add+=( "" "# Warning: replacing default settings" )
    toml_add+=( "query.tasks = ['serve']" )    
    toml_add+=( "" )
fi



# Background processes should not linger...
#trap "trap - SIGTERM && kill -- -$$" EXIT
#trap 'kill $(jobs -p)' EXIT

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
        nb_run="_tmp_${nb_org}_${cty_code}_${id}_${dv}${dk}"        
        cat "conf/${nb_org}.toml" > ${nb_run}.toml
        echo -e "\n## ----------------------------------" >> ${nb_run}.toml 
        echo -e "## ${nb_version} -- Added During Automation --" >> ${nb_run}.toml 
        echo -e "[[${nb_org}]]" >> ${nb_run}.toml 
        echo -e "version.id = '${nb_version}'\n" >> ${nb_run}.toml     
        echo -e "logging.file = '${nb_run}.log'" >> ${nb_run}.toml
        echo -e "logging.path = 'logs/{version_id}/'" >> ${nb_run}.toml         
        
        if (( ${#toml_add[@]} != 0 )); then
            for add in "${toml_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done
            echo "  Warning: added lines from an array to the TOML config file."
        fi        
        
        if [[ "$latest" == "true" ]]; then
            for add in "${latest_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done        
            echo "  Warning: added lines from an array to the TOML config file (LATEST)."
        fi       

        # catalogues
        echo -e "\n## ----------------------------------" >> ${nb_run}.toml 
        echo -e "## ${cty_code} -- Added During Automation --" >> ${nb_run}.toml
        cat "conf/catalogues/${nb_org}_${cty_code}.toml" >> ${nb_run}.toml
        
        #sleep 1 ;


        
        # copy and update notebook
        if [[ "$nb_version" == "v1.0.3" ]]; then
        # python 3.12
        # convert from python notebook        
        { ( nice -n 10 \
          timeout 1m \ 
          conda run -n status312v1 \
          papermill --prepare-only "notebooks/v1.0.3-dev/${nb_org}.ipynb" "${nb_run}.ipynb" -p ioconfig_file "${nb_run}.toml" 
        ) } 2>/dev/null

        wait
          
        # convert to python script
        { ( conda run -n status312v1 \
            jupyter nbconvert --to script "${nb_run}.ipynb" 
        ) } 2>/dev/null

        wait
          
        # execute python script
        if [[ "$dk" == "H" || "$dk" == "D" ]]; then          
        { ( nice -n 10 \
          conda run -n status312v1 \
          python "${nb_run}.py"
          ) } 2>/dev/null             
        fi   



        
        elif [[ "$nb_version" == "v1.0.2" ]]; then
        # python 3.10
        # convert from python notebook
        { ( nice -n 10 \
          timeout 1m \ 
          conda run -n status310v1 \
          papermill --prepare-only "notebooks/v1.0.2-stable/${nb_org}.ipynb" "${nb_run}.ipynb" -p ioconfig_file "${nb_run}.toml" 
        ) } 2>/dev/null   

        wait
          
        # convert to python script
        { ( conda run -n status310v1 \
            jupyter nbconvert --to script "${nb_run}.ipynb" 
        ) } 2>/dev/null

        wait
          
        # execute python script
        if [[ "$dk" == "H" || "$dk" == "D" ]]; then          
        { ( nice -n 10 \
          conda run -n status310v1 \
          python "${nb_run}.py"
          ) } 2>/dev/null             
        fi   
        
        fi

          
        wait  
        
    done

    # Collect all background processes.
    wait
    
    d0=$(date -u -d "$d0 $dt $du" +"%Y-%m-%d %H:%M:%S")
    d1=$(date -u -d "$d1 $dt $du" +"%Y-%m-%d %H:%M:%S")  
    nextdate=$(date -u -d "$d0" +"%s")   
done