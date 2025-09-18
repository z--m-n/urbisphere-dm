# Runtime

For production use, workflows are copied and configured using shell scripts. The shell scripts used for each workflow are functionally identical.

## Rationale

In order to make the work more accessible, the project favoured the use of Jupyter Notebooks (R and Python), TOML configuration files, and databases in SQL, CSV or NetCDF format. Consequently, workflows contain production routines, evaluation routines and output. Dependencies between workflows were solved using the `ipynb` module. 

Splitting large tasks into multiple iterations executed from shell scripts made production more resilient to unhandled exceptions in the Python code. Runtime copies of workflows were created. Those temporary copies are not deleted at runtime, so their output can be examined and used as a standalone notebook. Conversion of a notebook to a Python script (in `src/`) is only necessary if the code requires it, e.g., to start a new cluster with threading modules such as `dask`.  The version control system (e.g. Git) was configured to ignore the production runtime copies of workflows, to help keep the focus on changes made for development. 

This 'development=production' framework was implemented due to constraints and out of necessity: although this approach is not recommended, it serves to demonstrate a notebook-based codebase in an academic context.

## Features

- **Configuration**: the workflow configuration (TOML file) and source code (Jupyter notebook file) are copied and updated based on shell script arguments.

- **Execution**: while iterating through the tasks, the updated sources are executed by the shell script as notebooks or Python scripts (`papermill`), within the appropriate environment (`conda run`, see ![conda environments](/urbisphere-dm/common/scripts/conda/conf)). Execution controls are added where needed (e.g., `timeout`, resource priority, concurrent execution, handling errors, stdout).

## Runtime command

```bash
$ cd ./processing/systems/AWS/; ./notebooks/fieldclimate_metadata.sh 1 D "FR:AWS" "2022-05-01" "2023-01-01";
```

- **Command**: `fieldclimate_metadata.sh`
- Arg 1: time interval
- Arg 2: time interval unit, as in `H`ours OR `D`ays OR `Y`ears
- Arg 3: profile, as in `station_city` OR `station_city:system_group` OR `station_city:system_id`
- Arg 4: start time, as in `YYYY-MM-DD HH:MM:SS` OR `YYYY-MM-DD`
- Arg 5: end time (optional), as in `YYYY-MM-DD HH:MM:SS` OR `YYYY-MM-DD` OR `latest`

## Runtime configuration

The TOML configuration files use variables and arrays:
- configuration defaults
- query options
- input locations
- cache locations
- output locations

Runtime copies of configuration files residing outside the scope of the code version control needed a workaround to be aware of relevant changes and versioning (e.g., runtime options). A configuration includes version-specific blocks for the workflow, using TOML array definitions.

```toml
## DEFAULTS
[[fieldclimate_metadata]]
version.id = 'v1.'

# logging
logging.path = "logs/{version_id}/"
logging.file = "fieldclimate_metadata.log"
logging.format = "[%(asctime)s] %(levelname)-8s %(message)s"
logging.filemode = 'a'

# query (papermill command line, other)
query.start = "2022-07-01" # first data: 2022-05-04
query.period = "1D"
query.system_index = ""
query.latest = false
query.cache = true
query.tasks = ['query']
query.key_file = "/etc/creds/other/.fieldclimate_keys.json"

# metadb (offline)
metadb.system_id = []

[[fieldclimate_metadata]]
version.id = 'v1.0'

# input
input.path_base = "https://api.fieldclimate.com/v2"

# output cache
cache.path_base = "/srv/meteo/sandbox/z--m-n/AWS/{version_id}/cache/{production_level}/"
cache.path = "by-source/smurobs/by-location/Germany/Freiburg/{station_id}/dupes/by-upload-date/{time_query}/"
cache.file = "fieldclimate_set({global_location},{system_group}{delimiter}{system_name},{time_bounds})_version({version_id}).{extension}"

# output
output.path_base = "/srv/meteo/sandbox/z--m-n//AWS/{version_id}/data/{production_level}/"
output.path = "by-source/smurobs/by-location/Germany/Freiburg/{station_id}/{system_group}/{system_id}/"
output.file = "urbisphere_set({global_location}{delimiter_url}{station_id},{system_group}{delimiter}{system_id},{time_bounds})_version({version_id}).{extension}"

[...]
```

Version specific defaults and options are appended to the array manually or during automation, for example:
```toml
[...]

[[fieldclimate_metadata]]
version.id = 'v1.0.5'

# -------- Start of block
[[fieldclimate_metadata.gattrs]]
history=[
    "[{version_time}] Field observations were made using a LoRAIN (NBIoT) model (Pessl Instruments GmbH) automatic weather station (AWS)",
    "[{version_time}] Data were collected by the FieldClimate system (Pessl Instruments GmbH)",
    "[{version_time}] @status-meteo(status310v1): `fieldclimate_metadata.ipynb` {version_id} by Matthias Zeeman",
    "[{version_time}] Data were retrieved from the <a href=\"https://api.fieldclimate.com/v2/\">Fieldclimate API</a>",
    "[{version_time}] Text-based data were decoded and transcribed, data attributes were assigned and some meta data were added"
]
production_level="L0"
production_version="{version_id}"
production_profile="set(de.freiburg,AWS,2025)"
production_time="{creation_time}"
# -------- End of block
```

Configuration lines added during automation append the condfuguration and overwrite defaults:
```toml
## ----------------------------------
## v1.0.5 -- Added During Automation
[[fieldclimate_metadata]]
version.id = 'v1.0.5'

query.latest = false
query.start = '2024-06-24 00:00:00'
query.period = '1D'


# Added lines (toml_add):
query.cache = true

logging.file = 'fieldclimate_metadata_ALL_D.log'
logging.filemode = 'a'

# Added lines (toml_add) for location:
query.city = 'FR'
output.subset.global_location = 'de.freiburg'

cache.path = 'by-source/smurobs/by-serialnr/Germany/Freiburg/{station_id}/{time_query}/'
output.path = 'by-source/smurobs/by-location/Germany/Freiburg/{station_id}/{system_group}/{system_id}/'

query.tasks = ['query','clean']

[[fieldclimate_metadata.gattrs]]
production_profile = 'set(de.freiburg,AWS,2024)'
```

Using the above example, a Notebook for the `fieldclimate_metadata` workflow with `version.id =  'v1.0.5'` would import sections `v1`, `v1.0` and `v1.0.5` of the configuration file, but ignores sections with `version.id = 'v1.0.4'` or `version.id = v1.1`.
