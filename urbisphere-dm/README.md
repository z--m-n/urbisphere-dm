# (urbisphere-dm) README.md

For general guidance, please consult the documentation in the '/docs' folder. You might find extra info for each tool or tool set in subfolders called `**/docs`.

### Files
```bash
$ tree --prune -I "README.md" -P "*.ipynb" urbisphere-dm
urbisphere-dm
├── common
│   ├── colormap
│   │   └── notebooks
│   │       └── colormaps.ipynb
│   └── plotly
│       └── notebooks
│           └── plotly_extra.ipynb
├── interfaces
│   ├── datasets
│   │   └── api
│   │       └── notebooks
│   │           └── datasets_api.ipynb
│   ├── filedb
│   │   └── notebooks
│   │       └── filedb_locate.ipynb
│   ├── metadb
│   │   └── notebooks
│   │       └── metadb_query_mwe.ipynb
│   └── services
│       └── dashboards
│           └── notebooks
│               └── dashboard_paris.ipynb
└── processing
    ├── datasets
    │   └── conjoin
    │       └── notebooks
    │           └── datasets_conjoin.ipynb
    └── systems
        └── AWS
            └── notebooks
                ├── cslogger_metadata.ipynb
                └── fieldclimate_metadata.ipynb

24 directories, 9 files
```

Some of the folders are empty because only certain tools have been added to this public repository.  