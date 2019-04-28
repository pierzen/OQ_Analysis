
# PostGIS OSM Database with Osmosis PgSnapshot Schema

PostGIS Spatial Analysis can be done for the Planet OSM, or simply a region or even specific features such as buildings extracted from an Overpass query. 
[Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) 
PgSnapshot Schema is a simplified way to import OSM data into PostGIS for analyssis. 

The OSM wiki describes the [PostGIS Setup](https://wiki.openstreetmap.org/wiki/Osmosis/PostGIS_Setup) to load OSM data in the database. You can create a specific database to store OSM data where you will add  PostGIS and hstore Extensions

 -   CREATE DATABASE osm_hist;
 -   CREATE EXTENSION postgis;
 -   CREATE EXTENSION hstore;

The [pgsnapshot_schema_0.6.sql](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_schema_0.6.sql) Script creates the PostGIS schema 0.6 tables.

PostgreSQL schemas (not to confuse with pgsnapshot_schema) are like directories that group tables.  By default, files are placed in the Public schema, but you can create your ownd schema to load tables specific for a project. For the OpenStreetMap Quality Analysis Project, we load each OSM extract in a specific PostgreSQL schema.

## Loading OSM data into PostGIS

There two Osmosis commands options --write-pgsql  and --write-pgsql-dump can be used to load OSM data into a PostGIS Database. Paul Normand Blog Post [Loading a Pgsnapshot Schema With a Planet: Take 2](http://www.paulnorman.ca/blog/2011/11/loading-a-pgsnapshot-schema-with-a-planet-take-2/) suggest to use --write-pgsql-dump and describes the various steps.

    osmosis \
    --read-xml file="myosm_extract_1.osm" \
    --write-pgsql host="localhost" database="osm" user="x" password='x'

To retrieve Postgis functions stored in the Public schema, we need to provide a pgsql commmand to search for this schema.

    SET search_path TO public;
    
 For more infos about parsing OSM into PostGIS, see [Paul Norman Blog about PgSnapshot](https://www.paulnorman.ca/blog/2011/11/loading-a-pgsnapshot-schema-with-a-planet-take-2/) and the [Telenav Github Repository useful_postgis_queries](https://github.com/TelenavMapping/useful_postgis_queries).
