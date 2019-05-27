DROP  Function public.OQ_Json2File(TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE Function public.OQ_Json2File(
	_schema TEXT, tablename TEXT, varname TEXT, to_filename TEXT)
RETURNS void
AS $PROC$
-- Creates a JSON file from a JSON variable
DECLARE
	cmd text;
	tbname text;
BEGIN
	varname=quote_ident(varname);
	if tablename='' THEN tablename='fjson';
	END IF;
	if _schema in ('', '""') then tbname=tablename;
	ELSE tbname=format('%s.%s', _schema, tablename);
	END IF;
	if varname='' THEN varname='tjson';
	END IF;
	IF to_filename='' THEN to_filename='STDOUT';
	END IF;
	RAISE INFO 'OQ_Json2file tbname %, geom_var % copy to_filename %', 
		tbname, varname, to_filename;
	cmd=format('
	copy (select %2$s from %1$s) TO ''%3$s'' 
	 encoding ''utf-8'';
	', tbname, varname, to_filename);
	RAISE INFO '%', cmd ;
	RETURN;
END
$PROC$ LANGUAGE plpgsql;
