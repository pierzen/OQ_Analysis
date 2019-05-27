DROP FUNCTION oq_postgis2json(text,text,text);

CREATE OR REPLACE Function public.OQ_PostGIS2Json(
	_schema TEXT, tablename TEXT, geom_var TEXT)
RETURNS TABLE(tjson TEXT)
AS $PROC$
-- Converts a PostGIS table geometry to a JSON variable
DECLARE
	cmd text;
	tbname text;
BEGIN
	--_schema = quote_ident(_schema);
	--tablename=quote_ident(tablename);
	geom_var=quote_ident(geom_var);
	if _schema in ('', '""') then tbname=tablename;
	ELSE tbname=format('%s.%s', _schema, tablename);
	END IF;
	if geom_var='' THEN geom_var='geom';
	END IF;
	RAISE INFO 'tbname %, geom_var %', tbname, geom_var;
	cmd=format('
	WITH
	features as (
	  SELECT jsonb_build_object(
		''type'',       ''Feature'',
		''geometry'',   ST_AsGeoJSON(%2$s)::jsonb,
		''properties'', to_jsonb(inputs) - ''%2$s'' 
	  ) AS feature
	  FROM %1$s inputs
	)
	, fjson as (
		SELECT jsonb_build_object(
		''type'',     ''FeatureCollection'',
		''features'', jsonb_agg(features.feature)
	)::json as tjson
	FROM features)
	select tjson::text from fjson;
	', tbname, geom_var);
	RAISE INFO '%', cmd ;
	RETURN QUERY EXECUTE cmd;
END
$PROC$ LANGUAGE plpgsql;
