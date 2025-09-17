# (urbisphere-dm) processing/datasets/conjoin

The added functionality in `datasets_conjoin` translates input datasets into a common vocabulary and enables merging along multiple dimensions (e.g. time, station, system), particularly in RAM-limited environments.

## Rationale

The built-in methods for merging multiple datasets (module `xarray`) are increasingly capable of handling heterogeneous datasets with complex hierarchy, but this often demands more resources than are available on standard workstation data infrastructure. Optimised routines help to streamline the merging and translation process.


## Merge and concatenate datasets

`datasets_conjoin`

### Task `conform`

Translation of vocabulary (module `cfunits`) based on additional metadata queries. Cached output is created for each input file. 

### Task `concat`

Merge along dimension `time`, but keep each location in a separate group. An attempt is made to unify the global attributes.

### Task `combine`

Merge coordinates along all dimensions.

### Task `conflate`

Merge coordinates and variables along all dimensions.
