CREATE OR REPLACE FUNCTION OQ_01b_Topology_Intersect_Analysis(_schema varchar) 
RETURNS TABLE ( id bigint, id_b bigint, teval text, eval jsonb) 
AS $PROC$
DECLARE
	id int;
	source_overlaps text;
	w record;
	ww record;
	 BEGIN	 
		source_overlaps='
		select a.id as id, b.id as id_b, b.tags, 
		a.linestring as linestring_a, b.linestring as linestring_b,
		CASE WHEN exist(b.tags, ''building'')=True 
			THEN ''XB''
			WHEN exist(b.tags, ''building'')=False
			THEN ''XO''
		END AS teval,
		CASE
			when exist(b.tags, ''highway'') then ''highway''
			WHEN exist(b.tags, ''waterway'') then ''waterway''
			WHEN exist(b.tags, ''railway'') then ''railway''
			when exist(b.tags, ''aeroway'') then ''aeroway''
			when exist(b.tags, ''man_made'') then ''man_made''
			when exist(b.tags, ''landuse'') then ''landuse''
			when exist(b.tags, ''building'') then ''building''
			when exist(b.tags, ''amenity'') then ''amenity''
			when exist(b.tags, ''office'') then ''office''
			when exist(b.tags, ''craft'') then ''craft''
			when exist(b.tags, ''natural'') then ''natural''
			else ''other''
		END AS grptagb
		FROM %I.ways a
		INNER JOIN %I.ways b
		ON a.linestring && b.linestring
		AND exist(a.tags, ''building'') AND ST_NPoints(a.linestring)>3
		AND ST_IsClosed(a.linestring)
		AND ST_IsValid(ST_Polygon(a.linestring, 4326))
		AND	
		(
			(
			ST_NPoints(b.linestring)>3
			AND ST_IsClosed(b.linestring)
			AND ST_IsValid(ST_Polygon(b.linestring, 4326))
			AND (ST_LineCrossingDirection(a.linestring, b.linestring)<>0
			OR ST_Relate(a.linestring, b.linestring, ''T*T***T**'')=True)
			and ST_Touches(ST_MakeValid(ST_Polygon(a.linestring, 4326)), ST_MakeValid(ST_Polygon(b.linestring, 4326)) )=False	
			)
			OR
			(
			ST_NPoints(b.linestring)>3
			AND ST_LineCrossingDirection(a.linestring, b.linestring)<>0
			and ST_Touches(a.linestring, b.linestring)=False
			and (  exist(b.tags, ''building'') OR exist(b.tags, ''landuse'') OR exist(b.tags, ''amenity'') 
				OR exist(b.tags, ''office'')  OR exist(b.tags, ''craft'')
				OR exist(b.tags, ''natural'') OR exist(b.tags, ''man_made'')
				OR exist(b.tags, ''highway'') OR exist(b.tags, ''waterway'') 
				OR exist(b.tags, ''railway'') OR exist(b.tags, ''aeroway'') 
				OR exist(b.tags, ''man_made'') )
			) 
		)
		WHERE 
		ST_NPoints(a.linestring)>3
		AND ST_IsClosed(a.linestring)
		AND
		(
			(	exist(b.tags, ''building'') AND a.id < b.id)
			OR  a.id != b.id
		)
		'; 		
		FOR ww IN EXECUTE format(source_overlaps, _schema, _schema)
		LOOP
			RETURN QUERY
			select ww.id, ww.id_b, ww.teval, 
			format('{ "flag": "1", "grptag": "building", "grptag_b": "%s" }', ww.grptagb)::jsonb as eval;
		END LOOP;
	 END
$PROC$ LANGUAGE plpgsql;
