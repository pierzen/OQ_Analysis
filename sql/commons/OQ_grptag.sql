DROP FUNCTION public.OQ_grptag(hstore,text,text);

CREATE OR REPLACE FUNCTION public.OQ_grptag(in tags hstore, inout grptag text, inout sgrptag text) 
AS $PROC$
DECLARE
BEGIN
	case WHEN exist(tags, 'building') THEN grptag:='building';
	WHEN exist(tags, 'landuse') THEN grptag:='landuse';
	WHEN exist(tags, 'amenity') THEN grptag:='amenity';
	WHEN exist(tags, 'office') THEN grptag:='office';
	WHEN exist(tags, 'craft') THEN grptag:='craft';
	WHEN exist(tags, 'natural') THEN grptag:='natural';
	WHEN exist(tags, 'man_made') THEN grptag:='man_made';
	WHEN exist(tags, 'leisure') THEN grptag:='leisure';
	WHEN exist(tags, 'barrier') THEN grptag:='barrier';
	WHEN exist(tags, 'aeroway') THEN grptag:='aeroway';
	WHEN exist(tags, 'highway') THEN grptag:='highway';
	WHEN exist(tags, 'waterway') THEN grptag:='waterway';
	WHEN exist(tags, 'industrial') THEN grptag:='industrial';
	WHEN exist(tags, 'landcover') THEN grptag:='landcover';
	else grptag:='other';
	END CASE;
	IF grptag='building' THEN sgrptag='FB';
	ELSE sgrptag='FO';
	END IF;
	RETURN;
END
$PROC$ LANGUAGE plpgsql;
