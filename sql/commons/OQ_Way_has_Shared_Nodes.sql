DROP Function public.OQ_Way_has_Shared_Nodes(TEXT, TEXT);

CREATE OR REPLACE Function public.OQ_Way_has_Shared_Nodes(_schema TEXT, _tablename TEXT, id_way bigint)
RETURNS boolean
AS $PROC$
DECLARE
	cmd text;
	nb integer;
	resp boolean;
BEGIN
	_schema = quote_ident(_schema);
	cmd=format('WITH nodes_intersect AS (
	SELECT node_id, way_id
	FROM %1$s.way_nodes
	where node_id in
	(select distinct unnest(nodes) as node_ids from %1$s.%2$s
	where id=%3$s) 
	AND way_id not in (%3$s)
	)
	SELECT count(*) FROM nodes_intersect;
	', _schema, _tablename, id_way);
	EXECUTE cmd into nb;
	if nb>0 then resp=TRUE;
	ELSE resp=False;
	END IF;
	RETURN resp;
END
$PROC$ LANGUAGE plpgsql;
