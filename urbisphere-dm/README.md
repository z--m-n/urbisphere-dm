# (urbisphere-dm) README.md

Please consult the documentation in `/docs` for general guidance. Each tool or tool set may have additional documentation in sub-folders `**/docs`.

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