# Workflows

Workflows provide resources, or perform tasks, in the data management chain.

<p align="center">
  <img src="https://gi.copernicus.org/articles/13/393/2024/gi-13-393-2024-f09.png" title="Production pipeline (Zeeman et al. 2024)">
  <div style="font-size: small; font-style: italic">Figure: Example sequence of workflows (<a href="https://gi.copernicus.org/articles/13/393/2024/">Zeeman et al., 2024</a>)</div>
</p>

Workflows are organised by function, for example: 

```bash
.
├── common
│   ├── colormap
│   └── scripts
│       ├── conda
│       └── systemd
├── interfaces
│   ├── datasets
│   │   ├── api
│   │   └── zenodo
│   ├── eventdb
│   ├── filedb
│   ├── metadb
│   └── services
│       └── dashboards
└── processing
    ├── datasets
    │   ├── conjoin
    │   └── qc
    └── systems
        └── AWS
```

The `processing` group includes workflows for conversion and computations.
The `interfaces` group includes workflows aimed towards metadata, visualisation and data delivery. Resources in `common` are shared between workflows.
 

Each workflow contains a similar sub-structure:

```bash
.
├── conf
├── data
├── docs
├── notebooks
├── src
└── README.md -> docs/README.md
```

Typically, a `tmp` and `logs` folder are added during runtime use. 
