
-- OQ_NodeIdFromGeom Search id in Nodes table that corresponds to point geometry

SELECT *, public.OQ_NodeIdFromGeom('oq_sample.nodes', ST_AsText(geom)) 
FROM oq_sample.nodes limit 10;

select id, public.OQ_Way_has_shared_nodes('oq_sample',
	'oq_s1a_building', id) as shared_nodes
FROM oq_sample.oq_s1a_building
WHERE exist(tags, 'building') or exist(tags, 'building:part') or exist(tags, 'man_made');

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('oq_sample','oq_s1a_building','linestring') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_s1a_building.geojson' encoding 'utf-8'; 


SELECT *, public.OQ_Block_Adjacent_Polygons_id('oq_sample','oq_s1a_building')
FROM  oq_sample.oq_s1a_building LIMIT 10;

DROP TABLE IF EXISTS oq_sample.oq_s1b_building_extring;
CREATE TABLE oq_sample.oq_s1b_building_extring
(
    grp_poly integer,
	nodes bigint[],
	ways_id bigint[],
    geom_extring geometry(linestring, 4326)
);

INSERT INTO oq_sample.oq_s1b_building_extring
select (public.OQ_Block_Adjacent_Polygons('oq_sample','oq_s1a_building')).*;

SELECT *, ST_AsText(geom_extring,7) 
FROM oq_sample.oq_s1b_building_extring ORDER BY grp_poly;

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('oq_sample','oq_s1b_building_extring','geom_extring') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_s1b_building_extring.geojson' encoding 'utf-8'; 


/*	OQ_Calc_Classify_Angles
	Internal Function for OQ_Orthogonal
	It returns arrays for linestring/Polygons angles
*/

SELECT grp_poly, (public.OQ_Calc_Classify_Angles(geom_extring)).* 
FROM oq_sample.oq_s1b_building_extring;

/*  OQ_Circular_list_select_next
	Internal Function for OQ_Orthogonal
	Finds Prev / Next k (+-variation) to process in process lists
	ie k-1, k-2, k+2
*/

WITH circular  AS (
SELECT circular_list::integer[], kp, variation
FROM (VALUES
('{1, 3, 7, 9, 10,11}', 2, 3),
('{1, 3, 7, 9, 10,11}',2,4),
('{1, 3, 7, 9, 10,11}',2,5),
('{1, 3, 7, 9, 10,11}',2,-2),
('{1, 3, 7, 9, 10,11}',2,-3),
('{1, 3, 7, 9, 10,11}',2,-4),
('{1, 3, 7, 9, 10,11}',2,-5)
)  AS c (circular_list, kp, variation)
)
SELECT circular_list, kp, variation, public.OQ_Circular_list_select_next(circular_list, kp, variation)
from circular;

/*	OQ_OrthogonalProcessPoints
	Internal Function for OQ_Orthogonal
	It returns arrays for points to process
	lk_process_s1		points except near 180
	lk_process_180_s2,  points near 180
	lk_prev_s1			for S2, ref to prev s1.point
	lk_next_s1			for S2, ref to next s1.point
*/	

WITH angles AS (
SELECT k_angle_deb, tolerance_max, lp_angle
FROM (VALUES
(1, 10.0, '{178.6,89.8,87.3,87.8,178.5,88.5,89.2,178.2,87,88.5,91.6,178.6}'::float[]),
(2, 10.0, '{178.6,89.8,87.3,87.8,178.5,88.5,89.2,178.2,87,88.5,91.6,178.6, 88.9}'::float[])
) AS a (k_angle_deb, tolerance_max, lp_angle)
)
SELECT k_angle_deb, tolerance_max, lp_angle,
	 (public.OQ_OrthogonalProcessPoints(k_angle_deb, tolerance_max, lp_angle)).*
FROM angles;


/*	OQ_Calc_Classify_Angles
	input : linestring
*/

WITH angles AS (
SELECT grp_poly, ST_AsText(geom_extring,7) as tgeom, (public.OQ_Calc_Classify_Angles(geom_extring)).* 
FROM oq_sample.oq_s1b_building_extring ORDER BY grp_poly
)
SELECT grp_poly, k_angle_deb, lp_angle, (public.OQ_OrthogonalProcessPoints(1, 10.0, lp_angle)).*
from angles;

/* OQ_Orthogonal  
	Input Ways table
	Output Eval JSON variable 
	{  "grptag":"", 
	"flag":"0",  	 -- 0 orthogonal, otherwise 1
	"npoints": "8",  -- nb_points in polygon
	"tpolygon": "r", -- classif. of polygon geometry
	"nb_angles": 6,  -  nb_angles in polygon
	"angles": "{90,90.2,179.8,90.1,89.9,89.9,90.1,90}", 
	"angles_r": "{90,90.1,179.9,90.1,89.9,89.9,90.1,90}", 
	"lp_tpolygon": "{o,o,i,o,o,o,o}", -- classif each angle
	"linestring": "LINESTRING(-79.439676 43.691105,-79.439656 43.691056,-79.439821 43.69102,-79.439965 43.690989,-79.44004 43.691171,-79.439572 43.691272,-79.439518 43.691139,-79.439676 43.691105)", 
	"linestring_r": "LINESTRING(-79.439676 43.691105,-79.439656 43.691056,-79.439821 43.6910202,-79.439965 43.690989,-79.44004 43.691171,-79.439572 43.691272,-79.439518 43.691139,-79.439676 43.691105)", 
	"segments_q_rev": "", "segments_d_rev": "", "segments_p0_rev": "", 
	"lk_S1":"{1,2,4,5,6,7}", "lk_180_S2": "{3}"
	}
*/

DROP TABLE IF EXISTS oq_sample.oq_s1a_building_orthogonal;
CREATE TABLE oq_sample.oq_s1a_building_orthogonal AS
with grp_buildings AS (
SELECT id, 
public.OQ_Orthogonal(id::bigint, 
linestring, 1.0, 10.0) as eval
FROM oq_sample.oq_s1a_building
),
revs as (
SELECT id, eval
, eval->>'angles' as angles,
eval->>'angles_r' as angles_r,
ST_GeomFromText((eval->>'linestring'), 4326) as linestring,
(eval->>'linestring_r') as tlinestring_r,
ST_GeomFromText((eval->>'linestring_r'), 4326) as linestring_r,
(eval->>'segments_q_rev') as t_segments_q_rev,
(eval->>'segments_d_rev') as t_segments_d_rev,
(eval->>'segments_p0_rev') as t_segments_p0_rev,
(eval->>'lk_S1') as lk_S1,
(eval->>'lk_180_S2') as lk_180_S2, 
CASE WHEN NOT (eval->>'segments_q_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_q_rev'), 4326) 
END AS segments_q_rev, 
CASE WHEN NOT (eval->>'segments_d_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_d_rev'), 4326) 
END AS segments_d_rev, 
CASE WHEN NOT (eval->>'segments_p0_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_p0_rev'), 4326) 
END AS segments_p0_rev
FROM grp_buildings
WHERE (eval->>'linestring_r')<>'' 
)
SELECT * FROM revs;

SELECT * FROM oq_sample.oq_s1a_building_orthogonal limit 10;


drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('oq_sample','oq_s1a_building_orthogonal','linestring_r') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_s1a_building_orthogonal.geojson' encoding 'utf-8'; 

DROP TABLE IF EXISTS oq_sample.oq_s1b_building_extring_orthogonal;
CREATE TABLE oq_sample.oq_s1b_building_extring_orthogonal AS
with grp_buildings AS (
SELECT grp_poly, 
public.OQ_Orthogonal(grp_poly::bigint, 
geom_extring, 1.0, 10.0) as eval
FROM oq_sample.oq_s1b_building_extring
),
revs as (
SELECT grp_poly, eval
, eval->>'angles' as angles,
eval->>'angles_r' as angles_r,
ST_GeomFromText((eval->>'linestring'), 4326) as linestring,
(eval->>'linestring_r') as tlinestring_r,
ST_GeomFromText((eval->>'linestring_r'), 4326) as linestring_r,
(eval->>'segments_q_rev') as t_segments_q_rev,
(eval->>'segments_d_rev') as t_segments_d_rev,
(eval->>'segments_p0_rev') as t_segments_p0_rev,
(eval->>'lk_S1') as lk_S1,
(eval->>'lk_180_S2') as lk_180_S2, 
CASE WHEN NOT (eval->>'segments_q_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_q_rev'), 4326) 
END AS segments_q_rev, 
CASE WHEN NOT (eval->>'segments_d_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_d_rev'), 4326) 
END AS segments_d_rev, 
CASE WHEN NOT (eval->>'segments_p0_rev') ~ 'MULTILINESTRING' 
	THEN NULL 
ELSE ST_GeomFromText((eval->>'segments_p0_rev'), 4326) 
END AS segments_p0_rev
FROM grp_buildings
WHERE (eval->>'linestring_r')<>'' 
)
SELECT * FROM revs;

SELECT * FROM oq_sample.oq_s1b_building_extring_orthogonal limit 10;

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('oq_sample','oq_s1b_building_extring_orthogonal','linestring_r') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_s1b_building_extring_orthogonal.geojson' encoding 'utf-8'; 
