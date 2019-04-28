
## OQ_Building_Analysis - Buildings Topological evaluation and Form analysis 

Building Quality Studies on the [OpenDatalabRDC Blog](https://opendatalabrdc.github.io/Blog/#!index.md) gathered data from these scripts.

[OQ_01_Analysis_Table_Ways_Topology.sql](sql/OQ_Analysis_Table_Ways_Topology.sql) is the Main Script for OQ_Analysis. It Adds table  with Warnings and error flags to the schema specified in parallel to table ways that was analyzed.

This Script needs only the schema name and the date of the extract. It creates the ways_topology table and adds the Warnings and Topological Errors. This is the main Script the call other scripts for the various functions to prepare the table. 

 
Two types of analysis are performed over each building polygon.
1. Topological analysis indicates invalid and open polygon, overlaps, self-overlap (teval= [XB|XO])
2. Form Analysis classifies each polygon and individual angles for the following categories (teval=FB for Geometry Warnings)

For the description of variables, see [OQ_Analysis Documentation Variables](docum/OQ_Analysis Variables Documentation.md).

**SQL Query**

    	-- public.OQ_01_Analysis_Table_Ways_Topology(_schema text,_date_extract)
	SELECT * from public.OQ_01_Analysis_Table_Ways_Topology('myosm_extract_1', '2018_08_27', '')

**Output: OSM ways_topology Table** ( id bigint NOT NULL, id_b bigint, teval text, eval jsonb)

    Geometry: id=xxx, id_b=0, tags={tag list}, teval='FB', eval={ "grp_tag":"other", "flag":"1",  
      "nb_points": "17", "type_geom": "rreg-ireg", "poly_types_angle": "q-qq-ir", "type_polygon": 'FB_irreg',  
      "nb_angles": 16, 
      "angle_list": "{89.7,90.3,89.5,89.6,89.4,89.3,89.6,90.3,89.6,89.6,73.3,73.6,85.1,88.5,93.7,89.9,89.7}",
      "type_angle_list": "{q,q,q,q,q,q,q,q,q,q,ir,ir,qq,q,qq,q}"}
	
    Topology: id=xxx, id_b=yyyy, tags={tag list}, teval='XB', eval={  "flag":"1", 
      "grp_tag":"building", "grp_tag_b":"building" } 
    Topology: id=xxx, id_b=zzzz, tags={tag list}, teval='XO', eval={  "flag":"1", 
      "grp_tag":"building", "grp_tag_b":"amenity" } 
	
This file contains Geometry evaluation reports by OSM id for each building in the ways table. Records are also added to report Topological errors identification. In this case, 
- id refers to the building analyzed
- id_b refers to a second polygon (either building or other feature) in conflict with the id building.

 **OSM database query using OQ_Building_Analysis Function:**
 
 [OQ_01a_Building_Analysis.sql](sql/OQ_01a_Building_Analysis.sql) is called by 
 [OQ_01_Analysis_Table_Ways_Topology.sql](sql/OQ_01b_Analysis_Table_Ways_Topology.sql)
 but can also be run independtly like in the example below.
 
    CREATE temporary table temp_buildings AS 
    SELECT id, tags, 
    public.OQ_01a_Building_Analysis(id, linestring, tags) as eval
    FROM myosm_extract_1.ways
    WHERE (exist(tags, 'building')) ;
    	
    Result: id=xxx, tags={tag list}, eval={ "grp_tag":"other", "flag":"1",  "nb_points": "17", "type_geom": "rreg-ireg", "poly_types_angle": "q-qq-ir", "type_polygon": 'FB_irreg', "nb_angles": 16, "angle_list": "{89.7,90.3,89.5,89.6,89.4,89.3,89.6,90.3,89.6,89.6,73.3,73.6,85.1,88.5,93.7,89.9,89.7}", "type_angle_list": "{q,q,q,q,q,q,q,q,q,q,ir,ir,qq,q,qq,q}"}

**Polygons Summary Analysis Query Example**
	
    Query: 
    select (eval->>'type_geom') as type_geom, count(*) as nb_polygons
    FROM temp_buildings
    group by (eval->>'type_geom');

**Angles Summary Analysis Query Example**
	
    Query: 
	WITH tangles as (
    SELECT unnest((eval->>'type_angle_list')::text[]) as type_angle
    FROM temp_buildings
    )
    SELECT type_angle,  count(*) as nb_angles
    FROM tangles
    GROUP BY type_angle;


