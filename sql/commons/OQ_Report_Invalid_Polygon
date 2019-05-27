
CREATE OR REPLACE FUNCTION public.OQ_Report_Invalid_Polygon(in tags hstore, grptag TEXT, linestring geometry) 
RETURNS json AS $PROC$
DECLARE
BEGIN
	-- IF INVALID POLYGON
	-- json is filled with error messages 
	IF  exist(tags, 'building') AND (ST_NPoints(linestring)< 4 OR ST_IsClosed(linestring) is false)
	THEN return format('{ "grptag":"%s", "flag": "1", "npoints": "%s", "tpolygon": "FB_v", "nb_angles": 0,
				"angles": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring))::json;
	ELSIF exist(tags, 'building') AND ST_NPoints(linestring)> 3 and ST_IsValid(ST_Polygon(linestring, 4326)) is false
	THEN return format('{ "grptag":"%s", "flag":"1", "npoints": "%s", "tpolygon": "FB_invalid", "nb_angles": 0,
				"angles": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring))::json;
	ELSIF (ST_NPoints(linestring)< 4 OR ST_IsClosed(linestring) is false)
	THEN return format('{ "grptag":"%s", "flag": "1", "npoints": "%s", "tpolygon": "FO_v", "nb_angles": 0,
				"angles": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring))::json;
	ELSIF ST_NPoints(linestring)> 3 and ST_IsValid(ST_Polygon(linestring, 4326)) is false
	THEN return format('{ "grptag":"%s", "flag":"1", "npoints": "%s", "tpolygon": "FO_invalid", "nb_angles": 0,
				"angles": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring))::json;
	ELSIF  ST_NPoints(linestring)< 4
	THEN return format('{ "grptag":"nd", "flag": "-1", "npoints": "-4", "tpolygon": "ZZ_err", "nb_angles": 0,
				"angles": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring))::json;
	ELSE return format('{ "grptag":"%s", "flag": "0", "npoints": "%s" }', grptag, ST_NPoints(linestring))::json;
	END IF;
END
$PROC$ LANGUAGE plpgsql;
