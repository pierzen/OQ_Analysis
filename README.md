# OQ_Analysis
OpenStreetMap Quality Analysis Tools 
<img align="right" width="132" height="132" src="img/OQi_132.png">

This project was started in 2018 while [Potentiel 3.0](http://potentiel3-0.org/index.php/en/) and [OSM-CD](https://openstreetmap.cd/)  collaborated to support the Kinshasa OpenCities project and Blog Posts have been published on the [OpenDatalab-RDC Blog](https://opendatalabrdc.github.io/Blog/#!index.md).

Warning Indicators for Irregular Building forms and Topological errors are produced.  Summary statistics from these indicators let Monitor a territory, a mapping project or individual contributors. While Ratios of irregular Forms are often less then 5% for an area, reports of areas / projects  with Irregular forms Ratios exceding 60% of total buildings did alert about revising / improving the quality of edits for the area.

The prerequisite to use the scripts presented in this repository is to install a PostgreSQL / PostGIS database with the Osmosis PgSnapshot Database and import OSM files.

## PostGIS OSM Database with Osmosis PgSnapshot Schema

PostGIS Spatial Analysis can be done for the Planet OSM, or simply a region or even specific features such as buildings extracted from an Overpass query for a specific ( BBOX - datetime). 
[Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) 
PgSnapshot Schema is a simplified way to import OSM data into PostGIS for analysis. 

See [postgis_load_with_osmosis_schema.md](postgis_load_with_osmosis_schema.md) for informations how to create a PostGIS database with the Osmosis PgSnapshot Schema and load OSM data. 

## Scripts 

- [OQ_Building_Analysis.sql](https://github.com/pierzen/OQ_Analysis/blob/master/script/OQ_Building_Analysis.sql)
 Determines orthogonal and irregular polygons. Function applied on each row returns the Eval Json result list with metrics about the polygon and the various angles.
- [OQ_Topology_Intersect_Analysis.sql](https://github.com/pierzen/OQ_Analysis/blob/master/script/OQ_Topology_Intersect_Analysis.sql) Topological Analysis detects Polygons Intersects.

*See [Documentation](docum/OQ_Building_Analysis%20-%20Buildings%20Topological%20evaluation%20and%20Form%20analysis.md).*
