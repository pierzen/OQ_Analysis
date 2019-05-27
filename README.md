# OQ_Analysis
OpenStreetMap Quality Analysis Tools 
<img align="right" width="132" height="132" src="img/OQi_132.png">

------------------------------------------------------------------------------------------------

The prerequisite to use the SQL scripts presented in this repository is to install a PostgreSQL / PostGIS database with the Osmosis PgSnapshot Database and import an OSM file into a PostgreSQL schema (See [PostGIS OSM Database with Osmosis PgSnapshot Schema](docum/PostGIS%20OSM%20Database%20with%20Osmosis%20PgSnapshot%20Schema.md)).
You also need to load and compile the various functions in the sql folder before running analysis.

------------------------------------------------------------------------------------------------


## Building Analysis SQL Functions

- [OQ_01_Analysis_Table_Ways_Topology.sql](sql/Analys/OQ_01_Analysis_Table_Ways_Topology.sql) PostgreSQL Function (_schema, _date_extract) 
  Main Function for Topology Analysis - Adds table ways_topology with Warnings and error flags.
  <br/>**>** SELECT * from **public.OQ_01_Analysis_Table_Ways_Topology('myosm_extract_1', '2018_08_27')**;

- [OQ_01a_Building_Analysis.sql](sql/Analysis/OQ_01a_Building_Analysis.sql) PostgreSQL Function (id, geometry, tags) -- call for each line
  Determines orthogonal and irregular polygons. Function applied on each row returns the Eval Json result list with metrics about the polygon and the various angles.
  <br/>**>** SELECT id, tags, **public.OQ_01a_Building_Analysis(id, linestring, tags) as eval**
  FROM myosm_extract_1.ways WHERE (exist(tags, 'building')) ;

- [OQ_01b_Topology_Intersect_Analysis.sql](sql/Analysis/OQ_01b_Topology_Intersect_Analysis.sql) PostgreSQL Function (_schema) Topological Analysis detects Polygons Intersects.
  <br/>**>** SELECT id, id_b, teval, eval FROM **public.OQ_01b_Topology_Intersect_Analysis(_schema)**;
 
*See [Documentation](docum/OQ_01_Building_Analysis%20-%20Buildings%20Topological%20evaluation%20and%20Form%20analysis.md)*

## Orthogonal SQL Functions

- [OQ_Orthogonal.sql](sql/OQ_Orthogonal.sql) PRELIMINARY VERSION PostgreSQL Function (id, linestring geometry) Orthogonal Angles corrections - For each row, a JSON variable contains Results (ie, angles, angles corrected, linestring revised. Other procedures can analyse / transform the data, list Node ID's that need revision plus new geometry.
https://github.com/pierzen/OQ_Analysis/blob/master/sql/Orthogonal/OQ_OrthogonalRotation.sql

## Sample data and Tests
- [OQ_sample_data.sql](sql/test/OQ_Sample_Data.sql) provides the postgis sample tables
- [OQ_Tests.sql](sql/test/OQ_Tests.sql) contains tests and example of Orthogonalisation, GeoJSON outputs.


**Type of problems detected**
![](img/OQ-Analysis-Detects-Geometry-problems.png)

[GNU General Public License v3.0](LICENSE)

