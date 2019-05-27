DROP FUNCTION  public.OQ_NodeIdFromGeom(TEXT, GEOMETRY);

CREATE OR REPLACE Function public.OQ_NodeIdFromGeom(_tablename TEXT, geom  GEOMETRY)
RETURNS bigint
AS $PROC$
/* Search in Nodes table id from point geometry */
DECLARE
	cmd TEXT;
	geog geography;
	id bigint;
BEGIN
	cmd=format('SELECT id FROM %1$s n WHERE (n.geom::geography) = (''%2$s''::geography)', _tablename, geom);
	EXECUTE cmd INTO id;
	RETURN id;
END
$PROC$ LANGUAGE plpgsql;
