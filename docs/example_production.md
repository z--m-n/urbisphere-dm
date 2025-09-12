# Production

## Rationale

Sensor networks in environmental research require a data system to manage a moderate volume of data (1-100s of Tb) in a large number of objects (millions of files). A sequence of data mangement tasks prepare the data for use and publication. 

## Production levels

- RAW: original data
- L0 (optional): Conversion to a common data structure
- L1: Computations and conversion to a common vocabulary
- L2: Final annotation and attribution for public release

## Production workflows
<p align="center">
  <img src="https://gi.copernicus.org/articles/13/393/2024/gi-13-393-2024-f08.png" title="Production pipeline (Zeeman et al. 2024)">
  <div style="font-size: small; font-style: italic">Figure: Example of production levels in a production workflow (<a href="https://gi.copernicus.org/articles/13/393/2024/">Zeeman et al., 2024</a>)</div>
</p>

### Collection, Conversion & Combination

Field-deployed systems collect sensor data and transfer these as files to temporary central storage volumes. From there, file objects are archived on locations with human and machine interpretable identifiers for the logical, physical and organisation network those data belong to. The information in the file name (creation time, serial number) and within the file objects (time records, configuration details) link to databases for inventory and deployment details. The sources are converted and combined into a standardised structure (L0, L1), which subsequent workflows can access.

- documentation in `docs/`[example_workflow](../docs/example_workflow.md)
- documentation in `docs/`[example_runtime](../docs/example_runtime.md)
- documentation in `docs/`[example_scheduling](../docs/example_scheduling.md)
- workflows in `urbisphere-dm/processing/systems/`
- workflows in `urbisphere-dm/processing/datasets/conjoin/`

### Visualisation & Monitoring

Visualisations are part of the monitoring of data infrastructure, data transmission and the exploration of data. Dashboard apps help monitor data streams, and summary plots of the data help monitor key signals as the data arrive. Resources can be saved (potentially) if visualisations built on standardised data structures.

Annotations are made based on maintenance reports. The annotation process is supported by automated quality control workflows, which comprise computations and visualisation. 

- documentation in `docs/`[example_workflow](../docs/example_workflow.md)
- workflows in `urbisphere-dm/interfaces/services/dashboards/`

### Sharing & Publication

Provenance and reuse of the data require access to structured metadata about the creation history and license terms agreed by the organisational network contributing to the work. Those details must be available to the (next) user, in human and machine interpretable form. 

- documentation in `docs/`[example_api](../docs/example_api.md)
- workflows in `urbisphere-dm/interfaces/datasets/api/`
- workflows in `urbisphere-dm/interfaces/datasets/zenodo/`

## References
<p align="left">
  <div style="font-size: small; font-style: normal">M. Zeeman, A. Christen, S. Grimmond, D. Fenner, W. Morrison, G. Feigel, M. Sulzer, and N. Chrysoulakis. “Modular
approach to near-time data management for multi-city atmospheric environmental observation campaigns”. In:
Geoscientific Instrumentation, Methods and Data Systems 13.2 (Dec. 2024), pp. 393–424. DOI: 10.5194/gi-13-393-
2024.</div>
</p>

