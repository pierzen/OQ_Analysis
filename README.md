# OQ_Analysis
OpenStreetMap Quality Analysis Tools 
<img align="right" width="132" height="132" src="img/OQi_132.png">

------------------------------------------------------------------------------------------------

The prerequisite to use the scripts presented in this repository is to install a PostgreSQL / PostGIS database with the Osmosis PgSnapshot Database and import an OSM file into a PostgreSQL schema (See [PostGIS OSM Database with Osmosis PgSnapshot Schema](docum/PostGIS%20OSM%20Database%20with%20Osmosis%20PgSnapshot%20Schema.md)).

------------------------------------------------------------------------------------------------


## Scripts 

- [OQ_Analysis_Table_Ways_Topology.sql](script/OQ_Analysis_Table_Ways_Topology.sql) Main Script for Topology Analysis - Adds table ways_topology with Warnings and error flags.
- [OQ_Building_Analysis.sql](script/OQ_Building_Analysis.sql)
 Determines orthogonal and irregular polygons. Function applied on each row returns the Eval Json result list with metrics about the polygon and the various angles.
- [OQ_Topology_Intersect_Analysis.sql](script/OQ_Topology_Intersect_Analysis.sql) Topological Analysis detects Polygons Intersects.

*See [Documentation](docum/OQ_Building_Analysis%20-%20Buildings%20Topological%20evaluation%20and%20Form%20analysis.md).*


[GNU General Public License v3.0](LICENSE)

