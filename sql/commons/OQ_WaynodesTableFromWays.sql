DROP Function public.OQ_WaynodesTableFromWays(bigint, bigint[]);

CREATE OR REPLACE Function public.OQ_WaynodesTableFromWays(id bigint, nodes bigint[])
RETURNS table
(
    way_id bigint,
    node_id bigint,
    sequence_id integer
)
AS $PROC$
-- Creates way_nodes table from ways id lists
DECLARE
	nb_points integer;
	lseq integer[];
BEGIN
	nb_points = array_length(nodes, 1);
	FOR kl IN 1..nb_points 
	LOOP
		lseq[kl]=kl;
	END LOOP;
	
	RETURN QUERY
	SELECT id AS way_id, unnest(nodes)::bigint as node_id, unnest(lseq)::integer as sequence_id;
END
$PROC$ LANGUAGE plpgsql;
