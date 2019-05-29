PostGIS Spatial Analysis with OQ_Analysis can be done using OSM extracts from various sources such as a Planet OSM download from Geofabrik, HOT Export or even an Overpass Query for building features. PostGIS offers a variety of Spatial analysis and the possibility to export data for visualisation.

# Installation

To run these functions, you need access to a PostgreSQl-PostGIS server and the Osmsois-Java based commands to import data into PostGIS.

## PostgreSql-PostGIS

The OSM [PostGIS/Installation](https://wiki.openstreetmap.org/wiki/PostGIS/Installation) wiki page provides instructions to dowload and install PostgreSQL-PosGis.  

A specific database, for example **osm_hist** can be created to group together OQ_analysis projects. In this database, each schema (like a directory) will contains table for a specific OQ_Analysis project (ie. one OSM Download - One schema).  While creating the database, we also add specific extensions necessarry for OQ_Analysis.

 -   CREATE DATABASE osm_hist;
 -   CREATE EXTENSION postgis;
 -   CREATE EXTENSION hstore;

You also need to download from  [OQ_Analysis/sql](https://github.com/pierzen/OQ_Analysis/tree/master/sql) all the sql files and run these files in PosGIS using database=osm_hist to install these functions in the library. The [test directory](https://github.com/pierzen/OQ_Analysis/tree/master/test) contains sql file for samples and tests. This is a good documentation source to how to use the functions.

## Osmosis PgSnapshot

Osmosis is a command line Java application for processing OSM data. The [Osmosis Wiki](https://wiki.openstreetmap.org/wiki/Osmosis) page provides instructions to download and install.

## Adapt Osmosis PgSnapShot scripts for the OQ_Analysis project

The PgSnapshot Schema is a simplified way to import OSM data into PostGIS for analyssis. It parses the OSM tables. Sql procedures also create the tables in PostGIS and transfer the data to the database.

The scripts that we briefly decribed below will be automatically installed when you download Osmosis. The [pgsnapshot_schema_0.6.sql](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_schema_0.6.sql) Script creates the PostGIS schema 0.6 tables. The [Action](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_schema_0.6_action.sql), [bbox](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_schema_0.6_bbox.sql) and [linestring](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_schema_0.6_linestring.sql) sql procedures let select other variables to add to the tables.  These three scripts are used without any modification.

To reflect the added options for action, bbox and linestring, we need to modify the [pgsnapshot_load_0.6.sql](https://github.com/openstreetmap/osmosis/blob/master/package/script/pgsnapshot_load_0.6.sql) script.  Download from OQ_Analysis [osmhist_pgsnapshot_load_0.6.sql](https://github.com/pierzen/OQ_Analysis/blob/master/script/osmhist_pgsnapshot_load_0.6.sql) which instruct PosGIS to install variables for action, bbox and linestring.

In the next section we will describe how to install the various components and refer to them in the Script to import OSM data into PostGIS.

## Installation of scripts on your computer

You need  to create a directory for your OQ_Analysis projects where you will store the scripts and OSM files to import into PostGIS.  The script [osmosis-pgsnapshot-load-postgis.ps1](https://github.com/pierzen/OQ_Analysis/blob/master/script/osmosis-pgsnapshot-load-postgis.ps1) to import data to PostGIS is available for Windows. Note that this scripts refers to the Osmosis scripts 
- d:\osmosis  : where Osmosis scripts are stored
- d:\osmosis-osmhist : where  osmhist_pgsnapshot_load_0.6.sql script is located
- d:\your project You need to revise the ps1 script to specify this directory.  OSM files that you dowload will be stored in this directory.  A working subdirectory (needs write autorisation) will also be created by the scripts.

For windows you need to describe where the Osmosis components are installed. You need to modify the path in the Advanced options of the System to add the osmosis/bin directory.  


## Loading OSM data into PostGIS

The ps1 script contains instructions for Osmosis to import data into PostGIS. is uses the Osmosis --write-pgsql-dump command.
    
For more infos about parsing OSM into PostGIS, see [Paul Norman Blog about PgSnapshot](https://www.paulnorman.ca/blog/2011/11/loading-a-pgsnapshot-schema-with-a-planet-take-2/) and the [Telenav Github Repository useful_postgis_queries](https://github.com/TelenavMapping/useful_postgis_queries).
