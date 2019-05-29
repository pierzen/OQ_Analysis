# OQ_Analysis
OpenStreetMap Quality Analysis Tools         
<img align="right" width="132" height="132" src="img/OQi_132.png">
See Prerequisites on the [Installation page](https://github.com/pierzen/OQ_Analysis/blob/master/docs/Installation.md)

------------------------------------------------------------------------------------------------

This library contains PostgreSQL functions to analyze and transform OpenStreetMap Building data. 

The main functions are:

**Building Analysis** 

- [OQ_01_Analysis_Table_Ways_Topology.sql](sql/Analysis/OQ_01_Analysis_Table_Ways_Topology.sql) Buildings irregular geometry warnings  and error flags.
- [Documentation](docs/OQ_01_Building_Analysis%20-%20Buildings%20Topological%20evaluation%20and%20Form%20analysis.md)
- see [sql/test](sql/test) directory for more examples

## Orthogonal SQL Functions

- [OQ_Orthogonal.sql](sql/Orthogonal/OQ_Orthogonal.sql) PRELIMINARY VERSION PostgreSQL Function (id, linestring geometry) Orthogonal Angles corrections - For each row, a JSON variable contains Results (ie, angles, angles corrected, linestring revised. Other procedures can analyse / transform the data, list Node ID's that need revision plus new geometry.

## Sample data and Tests
- [OQ_sample_data.sql](sql/test/OQ_Sample_Data.sql) provides the postgis sample tables
- [OQ_Tests.sql](sql/test/OQ_Tests.sql) contains tests and example of Orthogonalisation, GeoJSON outputs.
- [GeoJson sample results](sql/test/geojson) &nbsp; (Source OSM Data, license [ODbL](https://www.openstreetmap.org/copyright))


**Type of problems detected**
![](img/OQ-Analysis-Detects-Geometry-problems.png)

[GNU General Public License v3.0](LICENSE)

