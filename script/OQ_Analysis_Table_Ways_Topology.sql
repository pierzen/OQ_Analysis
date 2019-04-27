CREATE OR REPLACE FUNCTION public.OQ_Analysis_Table_Ways_Topology(
	_schema text,
	_date_extract text,
	_timezone text)
    RETURNS VOID
    LANGUAGE 'plpgsql'
AS $PROC$
DECLARE
	nb_recs integer;
	msg text;
	cmd text;
	cmd2 text;
BEGIN
	IF _timezone<>'' THEN SET TIMEZONE='America/Montreal';
	END IF;
	RAISE INFO '% OQ_Analysis_Table_Ways_Topology(%, %)',  to_char(current_timestamp, 'hh24:mi:ss'), _schema, _date_extract;

	cmd=format('CREATE TABLE IF NOT EXISTS %1$s.ways_topology  
	(
	    id bigint NOT NULL,
		id_b bigint, 
	    teval text NOT NULL,
	    eval jsonb,
	    CONSTRAINT ways_topology_pkey PRIMARY KEY (id, id_b, teval)
	);

	-------------------------------------------------------------------
	delete from %1$s.ways_topology; ', _schema, _date_extract);
	RAISE INFO '%', cmd ;
	EXECUTE cmd;
	RAISE INFO '% -- 1. Warning Building Forms',  to_char(current_timestamp, 'hh24:mi:ss');

	cmd='WITH form as 
	( SELECT id, 0 as id_b,	
	 ' || $$	CASE
		WHEN  exist(tags, 'building')
		AND (
			linestring is null OR ST_NPoints(linestring)< 4 OR ST_IsClosed(linestring) is false
		)
		then format('''{ "grptag":"%s", "flag": "1", "npoints": "%s", "type_polygon": "FB_v", "nb_angles": 0,
					"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }''', 'building', ST_NPoints(linestring))::json
		WHEN exist(tags, 'building')
		AND (
			GeometryType(linestring) not in ( 'LINESTRING', 'POLYGON')
			OR ST_IsValid(ST_Polygon(linestring, 4326)) is false
		)
		then format('''{ "grptag":"%s", "flag":"1", "npoints": "%s", "type_polygon": "FB_invalid", "nb_angles": 0,
					"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }''', 'building', ST_NPoints(linestring))::json
		WHEN
		(exist(tags, 'landuse') OR exist(tags, 'leisure')
				 or  exist(tags, 'natural')  or exist(tags, 'man_made')
		)
		AND
		(ST_NPoints(linestring)< 4 OR ST_IsClosed(linestring) is false
		)
		then format('''{ "grptag":"%s", "flag": "1", "npoints": "%s", "type_polygon": "FO_v", "nb_angles": 0,
					"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }''', 'other', ST_NPoints(linestring))::json
		WHEN
		(exist(tags, 'landuse') OR exist(tags, 'leisure')
				 or  exist(tags, 'natural')  or exist(tags, 'man_made')
		)
		AND
		(
			GeometryType(linestring) not in ( 'LINESTRING', 'POLYGON')
			OR ST_IsValid(ST_Polygon(linestring, 4326)) is false
		)
		then format('''{ "grptag":"%s", "flag":"1", "npoints": "%s", "type_polygon": "FO_invalid", "nb_angles": 0,
					"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }''', 'building', ST_NPoints(linestring))::json
		WHEN exist(tags, 'area')
		AND NOT (tags ?| array['building', 'highway', 'waterway',
			'landuse', 'natural', 'man_made', 'leisure',
			'office', 'craft', 'government', 'aeroway', 'railway'])
		then format('''{ "grptag":"%s", "flag":"1", "npoints": "%s", "type_polygon": "FA_area", "nb_angles": 0,
					"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }''', 'area', ST_NPoints(linestring))::json
		ELSE public.OQ_Building_Analysis(id, linestring, tags)
		END as eval
		$$ || format(' FROM 	%1$s.ways
		WHERE id not in (select member_id
			from 	%1$s.relation_members) ', _schema, _date_extract) || $$
		AND tags is not null
		AND
		(
			exist(tags, 'building')
		OR
		  (
			 (exist(tags, 'landuse') or exist(tags, 'leisure')
			 or exist(tags, 'natural')  or exist(tags, 'man_made'))
			AND 
			( ST_NPoints(linestring)< 4
			  OR ST_IsClosed(linestring) is false
			  OR ST_isvalid(ST_Polygon(linestring, 4326))=False )
			)
		  )
	) 
	$$ || format(' insert into %1$s.ways_topology (id, id_b, teval, eval) ', _schema, _date_extract) || $$ 
	select id, id_b, 
	CASE 
		WHEN btrim((eval->>'type_geom'), ' ') ~* ('ireg|rreg|qqq|qq|hh|dd|rr') then 'FB'
		ELSE ''
	END	 AS teval,
	eval from form
	ON CONFLICT DO NOTHING; $$ || ' ';
	EXECUTE cmd;
	
	RAISE INFO '% -- 2 XB-XO Topological Errors',  to_char(current_timestamp, 'hh24:mi:ss');
	----------------------------------------------------------------------------

	cmd = format('INSERT INTO %1$s.ways_topology (id, id_b, teval, eval)
	SELECT id, id_b, teval, eval FROM OQ_Topology_Intersect_Analysis(''%1$s'')
	ON CONFLICT DO NOTHING;', _schema);
	RAISE INFO 'cmd %', cmd;
	EXECUTE cmd;

	RAISE INFO '% OQ_Analysis_Table_Ways_Topology Function completed, nb_recs=%',  to_char(current_timestamp, 'hh24:mi:ss'), nb_recs;
	RETURN;
END
$PROC$;
