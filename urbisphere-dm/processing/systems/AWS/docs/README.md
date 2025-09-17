# (urbisphere-dm) processing/systems/AWS


## Fieldclimate API (JSON)
`fieldclimate_metadata`

### Task `query`
Data are collected from the Fieldclimate API and the results are stored as JSON files. 

### Task `clean`
Data are read from collected JSON files and sensitive or proprietary information are masked or filtered from the JSON hierarchy. 

### Task `convert`
Data are converted and concatenated into a dataset (sing `xarray`) and structured with metadata.

### Task `combine`
This is a simplified variant of the `datasets_conjoin` workflow.

## Campbell Scientific Datalogger (TOA5)

`cslogger_metadata`

### Task `main`
Data are read from TOA5 files, the headers are evaluated, the time variable is evaluated and output is generated as dataset (using `xarray`). 

The collection procedure for this system group is by (1) automatic transmission (e.g, FTP) initiated from a local system to a storage volume, and (2) any additional manual collection during on-site maintenance. As a result, the source data are often duplicated in multiple output files that have no obvious resemblence in file name or number of contained records. The data must be organises by matching header, sorted and duplicate records removed.  