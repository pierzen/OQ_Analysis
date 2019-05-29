-- Toronto Test file user jarek 
-- source osm (ODBl License) - Buildings only selected 
--  https://github.com/jfd553/OrthogonalizingBuildingFootprint/blob/master/OrthogonalizingBuildingFootprint.zip
-- REQUIREMENT : file on_toronto_jarek_2019_03_21.osm.gz must be downloaded 
-- and imported into PostGIS in schema on_toronto_jarek_2019_03_21

create TABLE on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2a_building AS
SELECT * FROM on_toronto_jarek_2019_03_21.ways;
-- 587 obs

select count(*) FROM on_toronto_jarek_2019_03_21.nodes;
-- 3459 obs
select count(*) FROM on_toronto_jarek_2019_03_21.ways;
-- 587 obs
select count(*) FROM on_toronto_jarek_2019_03_21.way_nodes;
-- 4862 obs

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('on_toronto_jarek_2019_03_21','OQ_on_toronto_jarek_s2a_building','linestring') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_on_toronto_jarek_s2a_building.geojson' encoding 'utf-8'; 

DROP TABLE IF EXISTS on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2a_building_orthogonal;
CREATE TABLE on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2a_building_orthogonal AS
with grp_buildings AS (
SELECT id, 
public.OQ_Orthogonal(id::bigint, 
linestring, 1.0, 10.0) as eval
FROM on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2a_building
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
-- 574 obs

SELECT * FROM on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2a_building_orthogonal limit 10;

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('on_toronto_jarek_2019_03_21','OQ_on_toronto_jarek_s2a_building_orthogonal','linestring_r') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_on_toronto_jarek_s2a_building_extring_orthogonal.geojson' encoding 'utf-8'; 


DROP TABLE IF EXISTS on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring;
CREATE TABLE on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring
(
    grp_poly integer,
	nodes bigint[],
	ways_id bigint[],
    geom_extring geometry(linestring, 4326)
);

INSERT INTO on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring
select (public.OQ_Block_Adjacent_Polygons('on_toronto_jarek_2019_03_21','oq_on_toronto_jarek_s2a_building')).*;
-- 66 obs

SELECT *, ST_AsText(geom_extring,7) 
FROM on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring ORDER BY grp_poly;

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('on_toronto_jarek_2019_03_21','oq_on_toronto_jarek_s2b_building_extring','geom_extring') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_on_toronto_jarek_s2b_building_extring.geojson' encoding 'utf-8'; 

DROP TABLE IF EXISTS on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring_orthogonal;
CREATE TABLE on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring_orthogonal AS
with grp_buildings AS (
SELECT grp_poly, 
public.OQ_Orthogonal(grp_poly::bigint, 
geom_extring, 1.0, 10.0) as eval
FROM on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring
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
-- 64 obs

SELECT * FROM on_toronto_jarek_2019_03_21.OQ_on_toronto_jarek_s2b_building_extring_orthogonal limit 10;

drop table IF EXISTS temp_fjson;
create temporary table temp_fjson as 
SELECT public.OQ_PostGIS2Json('on_toronto_jarek_2019_03_21','OQ_on_toronto_jarek_s2b_building_extring_orthogonal','linestring_r') as tjson;
copy (select tjson from temp_fjson) TO 'd:/temp/oq_on_toronto_jarek_s2b_building_extring_orthogonal.geojson' encoding 'utf-8'; 
