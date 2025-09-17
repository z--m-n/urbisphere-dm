#!/bin/bash

# examples:
# ./datasets_conjoin.sh 1 Y "FR:AWS" "2022-01-01" "2023-01-01"
# ./datasets_conjoin.sh 1 Y "FR:AWS" "2023-01-01" "2024-01-01"
# ./datasets_conjoin.sh 1 Y "FR:AWS" "2024-01-01" "2025-01-01"
# ./datasets_conjoin.sh 1 Y "FR:AWS" "$(date -u +"%Y-01-01")" "$(date -u +"%Y-01-01" -d "next year")"

# ./datasets_conjoin.sh 2 D "FR:AWS" "$(date -u +"%F 00:00:00" -d "-1 days")" "latest"
# ./datasets_conjoin.sh 2 H "FR:AWS" "$(date -u +"%F %H:00:00" -d "-1 hours")" "latest"


# config
nb_org="datasets_conjoin"
nb_version='v1.0.2'
latest="false"
latest_add=(
 "input.path_base = '/srv/meteo/scratch/z--m-n/{system_group}/{version}/data/L0/'"
 "cache.path_base = '/srv/meteo/scratch/z--m-n/{system_group}/{version}/cache/{production_level}/'"
 "output.path_base = '/srv/meteo/scratch/z--m-n/{system_group}/{version}/data/{production_level}/'"
)

# input args
dv=${1:-1}
dk=${2:-M}
dc=${3:-PA}
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
    input_start=$(date -u +"$df" -d "0 $du")
fi

# eval end
if [[ "$input_end" == "none" || "$input_end" == "latest" ]]; then
    input_end=$(date -u +"$df" -d "$dt $du")
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
cty_path='by-source/smurobs/by-location/France/Paris'
if [[ "${query_ids[@]}" == "" ]]; then
    query_ids=(
     "AWS"
    )
fi
toml_add+=( "input.path_base = '/srv/meteo/sandbox/z--m-n/AWS/v1.0.1/data/L0/'" )
toml_add+=( "" )
toml_add+=( "input.subset.version = 'v1.0.1'" )
toml_add+=( "input.subset.system_name = ['CR1000X']" )

elif [[ "$dc" == "BE" ]]; then
cty_code='BE'
cty_glob='de.berlin'
cty_path='by-source/smurobs/by-location/Germany/Berlin'
toml_add=( ""
)
elif [[ "$dc" == "FR" ]]; then
cty_code='FR'
cty_glob='de.freiburg'
cty_path='by-source/smurobs/by-location/Germany/Freiburg'
if [[ "${query_ids[@]}" == "" ]]; then
    query_ids=(
    "AWS"
    )
fi
toml_add+=( "" )
toml_add+=( "input.subset.version = 'v1.0.5'" )
toml_add+=( "input.subset.system_name = ['LoRAIN', 'Zero W']" )

elif [[ "$dc" == "BR" ]]; then
cty_code='BR'
cty_glob='uk.bristol'
cty_path='by-source/smurobs/by-location/UK/Bristol'
if [[ "${query_ids[@]}" == "" ]]; then
    query_ids=(
    "AWS"
    )
fi
toml_add+=( "" )
toml_add+=( "input.subset.version = 'v1.0.5'" )
toml_add+=( "input.subset.system_name = ['nMETOS100+']" )

else
    echo "Location not know."
    exit 1
fi


# Common options

toml_add+=( "input.subset.global_location = '${cty_glob}'" )
toml_add+=( "" )
toml_add+=( "logging.file = '${nb_org}_${dc}_${dv}${dk}.log'" )
toml_add+=( "logging.path = 'logs/{version_id}/'" )
toml_add+=( "" )
toml_add+=( "input.path = ['${cty_path}/']" )
toml_add+=( "cache.path = '${cty_path/by-serialnr/by-location}/{station_id}/{system_group}/{sensor_id}/'" )
toml_add+=( "output.path = '${cty_path/by-serialnr/by-location}/{station_id}/{system_group}/{sensor_id}/'" )
toml_add+=( "" )
toml_add+=( "query.cache = true" )
toml_add+=( "query.dask = true" )
toml_add+=( "query.city = '${cty_code}'" )
toml_add+=( "" )

if [[ "$dc" == "FR" || "$dc" == "BR" ]]; then
# Redirection options.

# temporary redirect
if [[ "$latest" == "false" ]]; then
    toml_add+=( "" "# Warning: replacing default settings" )
    toml_add+=( "input.path_base = '/srv/meteo/sandbox/z--m-n/AWS/v1.0.5/data/L0/'" )
fi

# reduce workload and output for real-time applications
if [[ "$latest" == "false" && "$dk" == "D"  ]]; then
    toml_add+=( "" "# Warning: replacing default settings" )
    toml_add+=( "query.tasks = ['conform']" )
    toml_add+=( "query.latest = true" )
    toml_add+=( "" )
elif [[ "$latest" == "false" && "$dk" == "Y"  ]]; then
    toml_add+=( "" "# Warning: replacing default settings" )
    toml_add+=( "query.tasks = ['concat','combine']" )
    toml_add+=( "query.latest = true" )
    toml_add+=( "" )
fi

# reduce workload and output for real-time applications
if [[ "$latest" == "true" && "$dk" == "H" ]]; then
    latest_add+=( "" "# Warning: replacing default settings" )
    latest_add+=( "query.tasks = ['conform']" )
    latest_add+=( "query.latest = true" )
    latest_add+=( "" )
    latest_add+=( "logging.filemode = 'w'" )
    latest_add+=( "" )
elif [[ "$latest" == "true" && "$dk" == "D" ]]; then
    latest_add+=( "" "# Warning: replacing default settings" )
    latest_add+=( "query.tasks = ['concat','combine']" )
    latest_add+=( "query.latest = true" )
    latest_add+=( "" )
    latest_add+=( "logging.filemode = 'w'" )
    latest_add+=( "" )

fi

fi


# Background processes should not linger...
#trap "trap - SIGTERM && kill -- -$$" EXIT
#trap 'kill $(jobs -p)' EXIT

# After this, startdate and enddate will be valid ISO 8601 dates,
# or the script will have aborted when it encountered unparseable data
# such as input_end=abcd
startdate=$(date -u +"%Y-%m-%d %H:%M:%S" -d "$input_start")  || exit -1
enddate=$(date -u +"%s" -d "$input_end") || exit -1

# Additional loop variables
d0=$(date -u +"%Y-%m-%d %H:%M:%S" -d "$startdate   0 $du")
d1=$(date -u +"%Y-%m-%d %H:%M:%S" -d "$startdate $dt $du")
nextdate=$(date -u +"%s" -d "$d0")

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


        if (( ${#toml_add[@]} != 0 )); then
            for add in "${toml_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done
            echo "  Warning: added lines from an array to the TOML config file."
        fi

        echo -e "query.start = '${d0}'" >> ${nb_run}.toml
        echo -e "query.period = '${dv}${dk}'" >> ${nb_run}.toml
        echo -e "query.system_index = '${id}'" >> ${nb_run}.toml

        if [[ "$latest" == "true" ]]; then
            for add in "${latest_add[@]}" ; do
                echo -e "${add}" >> ${nb_run}.toml
            done
            echo "  Warning: added lines from an array to the TOML config file (LATEST)."
        fi

        sleep 1 ;

        # copy and update notebook
        { ( nice -n 10 \
          timeout 1m \
          conda run -n status312v1 \
          papermill --prepare-only "notebooks/${nb_org}.ipynb" "${nb_run}.ipynb" -p ioconfig_file "${nb_run}.toml"
        ) } 2>/dev/null

        wait

        # convert to python script
        { ( conda run -n status312v1 \
            jupyter nbconvert --to script "${nb_run}.ipynb"
        ) } 2>/dev/null

        wait

        # execute python script
        { ( nice -n 10 \
          conda run -n status312v1 \
          python "${nb_run}.py"
          ) } 2>/dev/null

    done

    # Collect all background processes.
    wait

    d0=$(date -u +"%Y-%m-%d %H:%M:%S" -d "$d0 $dt $du")
    d1=$(date -u +"%Y-%m-%d %H:%M:%S" -d "$d1 $dt $du")
    nextdate=$(date -u +"%s" -d "$d0")
done
