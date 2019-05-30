# OQ_Analysis
OpenStreetMap Quality Analysis Tools         
<img align="right" width="132" height="132" src="https://github.com/pierzen/OQ_Analysis/blob/master/img/OQi_132.png">
PostgreSQL Library with PostGIS functions to analyze and transform OpenStreetMap Building data. 

------------------------------------------------------------------------------------------------

See the Prerequisites on the [Installation page](https://github.com/pierzen/OQ_Analysis/blob/master/docs/Installation.md)

The main functions are:

**Building Analysis** 

- [OQ_01_Analysis_Table_Ways_Topology.sql](https://github.com/pierzen/OQ_Analysis/blob/master/sql/Analysis/OQ_01_Analysis_Table_Ways_Topology.sql) Buildings irregular geometry warnings  and error flags.
- [Documentation](https://github.com/pierzen/OQ_Analysis/blob/master/docs/OQ_01_Building_Analysis%20-%20Buildings%20Topological%20evaluation%20and%20Form%20analysis.md)
- see [sql/test](https://github.com/pierzen/OQ_Analysis/blob/master/sql/test) directory for more examples

**Orthogonal Transformations**

- [OQ_Orthogonal.sql](https://github.com/pierzen/OQ_Analysis/blob/master/sql/Orthogonal/OQ_Orthogonal.sql) PRELIMINARY VERSION PostgreSQL Function (id, linestring geometry) Orthogonal Angles corrections - For each row, a JSON variable contains Results (ie, angles, angles corrected, linestring revised. Other procedures can analyse / transform the data, list Node ID's that need revision plus new geometry.

**Sample data and Tests**

- [OQ_sample_data.sql](https://github.com/pierzen/OQ_Analysis/blob/master/sql/test/OQ_Sample_Data.sql) provides the postgis sample tables
- [OQ_Test1.sql](https://github.com/pierzen/OQ_Analysis/blob/master/sql/test/OQ_Test1.sql) contains tests for various functions and Orthogonalisation examples plus GeoJSON outputs.
- [GeoJson sample results](https://github.com/pierzen/OQ_Analysis/blob/master/sql/test/geojson) &nbsp; (Source OSM Data, license [ODbL](https://www.openstreetmap.org/copyright))


[GNU General Public License v3.0](https://github.com/pierzen/OQ_Analysis/blob/master/LICENSE)

**Type of problems detected**

<img align="left" width="70%" src="https://github.com/pierzen/OQ_Analysis/blob/master/img/OQ-Analysis-Detects-Geometry-problems.png">


