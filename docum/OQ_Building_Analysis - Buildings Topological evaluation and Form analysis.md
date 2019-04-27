# OQ_Building_Analysis - Buildings Topological evaluation and Form analysis

Two types of analysis are performed over each building polygon.
1. Topological analysis indicates invalid and open polygon, overlaps, self-overlap
2. Form Analysis classifies each polygon and individual angles for the following categories

-  R, RR  Regular and quasi Regular (ie. silos, huts etc with constant angles) with tolerance +- 2, 5
-  Q, QQ, QQQ  Orthogonal (90, 270) with tolerance +- 2, 5 and 10 degrees
-  D, DD	  Straigth line (180 deg) with tolerance +- 2, 5
-  H, HH (45, 135, 225 and 315) with tolerance +- 2, 5
-  Ir Irregular angles (other then R, Q, D and H) 

The script is used inside a PostgreSQL-PostGIS Select command and returns the Eval Json data type with various keys fo analysis variables.
    
**The Eval Json list contains the following keys:values:** 
- grp_tag: building or other
- flag = 0 , regular polygon
- flag = 1 , Irregular forms and Invalid topology
- type_polygon prefix = FB_ flag = 1
- nb_points: polygon number of points
- type_geom: Polygon classification 
	-- reg, rreg, ireg
- poly_types_angle: summary of angle types in the polygone (example "q-qq-ir")
- type_polygon":  
- nb_angles: number of angles
- angle_list: list each angle in the polygon 
- type_angle_list: liste each angle category

**OSM ways_topology for ways table Warnings and Errors**

This Script needs only the schema name and the date of the extract. It creates the ways_topology table and adds the Warnings and Topological Errors. This is the main Script the call other scripts for the various functions to prepare the table. 

    SELECT * from public.OQ_Analysis_Table_Ways_Topology('myosm_extract_1', '2018_08_27', '')
 
**ways_topology** 	( id bigint NOT NULL, id_b bigint, teval text, eval jsonb)
- id   : OSM id of the polygon
- id_b : OSM id of the second polygon for polygons superpositions
- teval : FB (Geometry form warning),  XB-XO Topological Errors
- eval :  Json list with various metrics to analyse the polygon

 **OSM database query using OQ_Building_Analysis Function:**
 
    CREATE temporary table temp_buildings AS 
    SELECT id, tags, 
    public.OQ_Building_Analysis(id, linestring, tags) as eval
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


