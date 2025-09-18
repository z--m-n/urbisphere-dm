# Workflows

<figure><img src="https://gi.copernicus.org/articles/13/393/2024/gi-13-393-2024-f09.png"><figcaption>Figure: Example sequence of workflows (<a href="https://gi.copernicus.org/articles/13/393/2024/">Zeeman et al., 2024</a>)</figcaption></figure>

___
Workflows provide resources, or perform tasks, in the data management chain. Workflows are organised by function, for example: 

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


## Examples

1. [Collection of AWS data (RAW, L0)](/urbisphere-dm/processing/systems/AWS/docs/README.md) 
1. [Production of AWS data (L1)](/urbisphere-dm/processing/datasets/conjoin/docs/README.md) 
1. [Publication of AWS data (API)](/urbisphere-dm/interfaces/datasets/api/docs/README.md) 
