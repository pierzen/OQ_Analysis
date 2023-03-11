# OQ_Analysis
OpenStreetMap Quality Analysis Tools         
<img align="right" width="132" height="132" src="img/OQi_132.png">
PostgreSQL Library with PostGIS functions to analyze and transform OpenStreetMap Building data. 

------------------------------------------------------------------------------------------------

See the Prerequisites on the [Installation page](docs/Installation.md)

The main functions are:

**Building Analysis** 

- [OQ_Analysis_Table_Warnings_Error_Flags.sql](sql/Analysis/OQ_Analysis_Table_Warnings_Error_Flags.sql) Buildings irregular geometry warnings  and error flags.
- [Documentation](docs/OQ_Building_Analysis%20-%20Buildings%20Polygon%20errors%20and%20Geometry%20analysis.md)
- see [sql/test](sql/test) directory for more examples

**Orthogonal Transformations**

- [OQ_Orthogonal.sql](sql/Orthogonal/OQ_Orthogonal.sql) PRELIMINARY VERSION PostgreSQL Function (id, linestring geometry) Orthogonal Angles corrections - For each row, a JSON variable contains Results (ie, angles, angles corrected, linestring revised. Other procedures can analyse / transform the data, list Node ID's that need revision plus new geometry.

**Sample data and Tests**

- [OQ_sample_data.sql](sql/test/OQ_Sample_Data.sql) provides the postgis sample tables
- [OQ_Test1.sql](sql/test/OQ_Test1.sql) contains tests for various functions and Orthogonalisation examples plus GeoJSON outputs.
- [GeoJson sample results](sql/test/geojson) &nbsp; (Source OSM Data, license [ODbL](https://www.openstreetmap.org/copyright))


[GNU General Public License v3.0](LICENSE)

**Type of problems detected**

<img align="left" width="70%" src="img/OQ-Analysis-Detects-Geometry-problems.png">


