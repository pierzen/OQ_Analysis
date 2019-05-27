DROP FUNCTION oq_block_adjacent_polygons(text, text);

CREATE OR REPLACE Function public.OQ_Block_Adjacent_Polygons(_schema TEXT, tablename TEXT)
RETURNS TABLE ( grp_poly bigint, nodes bigint[], ways_id bigint[], geom_extring geometry) 
AS $PROC$
-- Polygons from Input with adjacent polygons that share walls are merged, Node variable contains the list of nodes
DECLARE
	cmd text;
	r record;
	nb_points integer;
	line geometry(linestring, 4326);
	t_point text;
	t_id bigint;
	l_id bigint[];
BEGIN
	_schema = quote_ident(_schema);
	cmd=format('
	WITH polys as (
		select id, ST_Polygon(linestring, 4326) as geom 
		FROM %1$s.%2$s
		where (exist(tags, ''building'') or exist(tags, ''building:part'') 
			or exist(tags, ''man_made'') )
		AND id in (select unnest (public.OQ_Block_Adjacent_Polygons_id(''%1$s'', ''%2$s''))
		)
	),
	 geoms (geom) as 
		(SELECT (ST_Dump(ST_MemUnion(geom))).geom from polys
	),
	rings AS  
	(   SELECT array_agg(id) as ways_id, (St_DumpRings(g.geom)).* 
		FROM polys p, geoms g 
		WHERE St_Intersects(p.geom, g.geom)
		GROUP BY g.geom
			 
						
					 
	)
	SELECT row_number() OVER () AS grp_poly, ''{}''::bigint[] as nodes, ways_id, 
	ST_ExteriorRing(geom)::geometry(linestring, 4326) AS geom_extring 
	FROM rings
	WHERE path[1] = 0;   -- ie the outer ring
					', _schema, tablename);

	FOR r IN EXECUTE CMD
	LOOP
		line=r.geom_extring;
		nb_points = ST_NPoints(line::geometry);
		l_id=ARRAY[]::bigint[];
		FOR kl IN 1..nb_points
		LOOP
			t_point=ST_AsText(ST_Pointn(r.geom_extring, kl));
			EXECUTE FORMAT('SELECT public.OQ_NodeIdFromGeom(''%1$s.nodes'', ''%2$s'')', _schema, t_point) INTO t_id;
			l_id[kl]=t_id;
		END LOOP;
		r.nodes=l_id;
		RETURN QUERY SELECT r.grp_poly, r.nodes, r.ways_id, r.geom_extring;
	END LOOP; 
END
$PROC$ LANGUAGE plpgsql;
