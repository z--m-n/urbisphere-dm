# Runtime

For production use, workflows are copied and configured using shell scripts. The shell scripts used for each workflow are functionally identical.

## Rationale

In order to make the work more accessible, the project favoured the use of Jupyter Notebooks (R and Python), TOML configuration files, and databases in SQL, CSV or NetCDF format. Consequently, Jupyter Notebooks were used for development, documentation and production. Dependecies between workflows were solved using the `ipynb` module. This development==production framework was implemented by necessity, in the interest of time.

The runtime copies were made to avoid confusion, as a version control system will register both code execution output and code changes in Jypyter Notebooks. The version control system (e.g., Git) was configured to ignore the prodction copies of workflows, keeping the focus on the changes made for code development. The notebook copies do not need to be deleted at runtime; their output can be examined and used as a standalone notebook. Converting a notebook to a script is optional if the Python code requires it (e.g. starting a new cluster with threading modules like `dask`). In both cases, log files are created or appended for debugging purposes. Splitting large tasks in multiple iterations executed from shell scripts made the production  more resilient to unhandled exceptions in the Python code.

## Runtime command

```bash
$ cd ./processing/systems/AWS/; ./notebooks/fieldclimate_metadata.sh 1 D "FR:AWS" "2022-05-01" "2023-01-01";
```

- **Command**: `fieldclimate_metadata.sh`
- Arg 1: time interval
- Arg 2: time interval unit, as in `H`ours OR `D`ays OR `Y`ears
- Arg 3: profile, as in `station_city` OR `station_city:system_group` OR `station_city:system_id`
- Arg 4: start time
- Arg 5: end time OR `latest` (optional)

## Features

- **Configuration**: the workflow configuration (TOML file) and source code (Jupyter notebook file) are copied and updated based on shell script arguments.

- **Execution**: while iterating through the tasks, the updated sources are executed by the shell script as notebooks or Python scripts (`papermill`), within the appropriate environment (`conda run`). Execution controls are added where needed (e.g., `timeout`, resource priority, concurrent execution, handling errors, stdout).
