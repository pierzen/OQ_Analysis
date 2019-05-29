#!/bin/bash
<#
 Import OSM Data In a PostGRESQL-PostGIS (Linux)
#>

today=`date +%Y-%m-%d`
#
# Parameters       --------------------------------------------------------------------------

$rep_osmosis_script    = "/osmosis/script"
# for script pgsnapshot_load_0.6_rev_osm_hist.sql - revision of pgsnapshot_load_0.6.sql 
$rep_osmosis_osmhist  = "/osmosis-oshmist"
# uncoment and provide PostgreSQL server info   pppp=port, uuuu=user
#$conn_postgreSQL      = "-h localhost -p pppp -U uuuu"
$conn_postgreSQL      = "-h localhost -p 7535 -U osm"
$rep_data             = "/potentiel_3_0/2018-05-RDC-Opencity/data"
$osm                  = "on_toronto_jarek_2019_03_21.osm"
# postgreSQL schema for OSM History file - For better documentation add a suffixe with date of Extraction
$pgsql_schema         = "on_toronto_jarek_2019_03_21"
    
#--------------------------------------------------------------------------------------------#
                                                       
clear
$s="`r`n"

echo $today   Loading OSM To Postgis $pgsql_schema       --------------------$s

echo "-----------------------------------------------------------------------------------"
rep_data_pgsqldump="$rep_data/pgsqldump"

echo "Parameters Osmosis-PgSnaphot 0.6 Import OSM to POSTGIS"
echo "-----------------------------------------------"
echo "rep_osmosis_osmhist  = $rep_osmosis_osmhist"
#conn_postgreSQL           = "-h $postgre_hot -p $postgre_port -U $postge_user"
echo "conn_postgreSQL      = psql : à remplacer valeurs connexion postgre      - h host, -p port -u user"
echo "rep_data             = $rep_data"
echo "rep_data_pgsqldump   = $rep_data_pgsqldump (Needs writing permission)"
echo "osm                  = $osm"
echo "pgsql_schema         = $pgsql_schema"
ls -l $rep_data/$osm

#
#
#
#
echo "$s------------------------------------------------------------------------------------$s"
echo "    PostgreSQL Schema  + PosGIS datatypes   -------------------------------------------"
echo "$s------------------------------------------------------------------------------------$s"

echo "- pgsql_schema $pgsql_schema"
psql -h localhost -p 7535 -U osm -d osm_hist -c "DROP SCHEMA IF EXISTS $pgsql_schema cascade"
psql -h localhost -p 7535 -U osm -d osm_hist -c "CREATE SCHEMA IF NOT EXISTS $pgsql_schema"
psql -h localhost -p 7535 -U osm -d osm_hist -c "ALTER DATABASE osm_hist SET search_path TO $pgsql_schema, public"
echo " "
echo "- pgsnapshot_schema_0.6 create the tables in PostGIS"
psql.exe --echo-all -h localhost -p 7535 -U osm -d osm_hist -f "$rep_osmosis_script/pgsnapshot_schema_0.6.sql"
# adds supplementary columns
psql.exe --echo-all -h localhost -p 7535 -U osm -d osm_hist -f "$rep_osmosis_script/pgsnapshot_schema_0.6_action.sql"
psql.exe --echo-all -h localhost -p 7535 -U osm -d osm_hist -f "$rep_osmosis_script/pgsnapshot_schema_0.6_bbox.sql"
psql.exe --echo-all -h localhost -p 7535 -U osm -d osm_hist -f "$rep_osmosis_script/pgsnapshot_schema_0.6_linestring.sql"


echo " "
echo "$s------------------------------------------------------------------------------------$s"
echo "   Osmosis OSM Parser  creates temporary files                      ------------------"
echo "$s------------------------------------------------------------------------------------$s"
chdir "$rep_data"
If (-not (Test-Path "pgsqldump")) { New-Item -ItemType Directory -Name "pgsqldump" }
rm $rep_data_pgsqldump/*.txt

/bin/osmosis/do_osmosis.cmd --fast-read-xml "$rep_data/$osm" --log-progress  interval=30 --write-pgsql-dump directory=pgsqldump

echo " "
echo " "
echo "$s------------------------------------------------------------------------------------$s"
echo "$s Validation - List Temporary files                                                  $s" 
echo "$s Should see nodes.txt, relations.tex, relation_members, users.txt. ways.txt, way_nodes.txt $s "
echo "$s------------------------------------------------------------------------------------$s"
chdir "pgsqldump"
dir "*.txt"
pause
echo " "
echo "$s------------------------------------------------------------------------------------$s"
echo "   PgSQL copy files and post process variables                      ------------------"
echo "$s------------------------------------------------------------------------------------$s"

psql.exe --echo-all -h localhost -p 7535 -U osm -d osm_hist -f "$rep_osmosis_script/osmhist_pgsnapshot_load_0.6.sql"

echo " "
echo " "
echo "$s------------------------------------------------------------------------------------$s"
echo "$today   Postgis $pgsql_schema Schema                                                 $s"
echo "$s           TRANSFER COMPLETED                                                       $s"
echo "$s------------------------------------------------------------------------------------$s"

break all
