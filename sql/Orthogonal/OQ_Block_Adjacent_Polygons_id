DROP Function public.OQ_Block_Adjacent_Polygons_id(TEXT, TEXT);

CREATE OR REPLACE Function public.OQ_Block_Adjacent_Polygons_id(_schema TEXT, _tablename TEXT)
RETURNS bigint[]
AS $PROC$
-- id List of adjacen polygons to merge
DECLARE
	cmd text;
	l_id bigint[];
BEGIN
	_schema = quote_ident(_schema);
	cmd=format('
	with sn as (
	select id, public.OQ_Way_has_Shared_Nodes(''%1$s'', ''%2$s'', id) as shared_nodes
	FROM %1$s.%2$s
	WHERE exist(tags, ''building'') or exist(tags, ''building:part'') or exist(tags, ''man_made'')
	)
	SELECT array_agg(id) as ways_id_list 
	FROM sn
	WHERE shared_nodes = True
	GROUP BY shared_nodes;
	', _schema, _tablename);
	EXECUTE cmd into l_id;
	RETURN l_id;
END
$PROC$ LANGUAGE plpgsql;
