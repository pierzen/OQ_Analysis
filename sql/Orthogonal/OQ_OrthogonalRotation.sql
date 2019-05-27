DROP FUNCTION public.OQ_OrthogonalRotation(double precision, double precision, double precision, double precision) ;

CREATE OR REPLACE FUNCTION public.OQ_OrthogonalRotation(tolerance_min double precision, tolerance_max double precision, azimuth_pm1_p0 double precision,
	azimuth_p0_p1 double precision
) 
RETURNS double precision AS 
$PROC$
-- From azimuths (previous and current segment)
-- Determines RotRadian Rotation of Way Segment to orthogonalize, compare to the previous one
DECLARE
	rotation_azimuth double precision;
	angle_p0 double precision;
	diff_angle double precision;
	rotradians double precision;
	direction integer;
BEGIN	
	-- P0-P1 Angle rotation correction to Orthogonalize
	-- prepares rotRadians parameter for ST_Rotate (this function works counter-clockwise)
	rotation_azimuth=azimuth_p0_p1-azimuth_pm1_p0;
	angle_p0 = (@(180-(@(degrees(azimuth_p0_p1)-degrees(azimuth_pm1_p0)) )));
		
	IF angle_p0 BETWEEN (90.0-tolerance_max) AND (90.0+tolerance_max)
	AND angle_p0 NOT BETWEEN (90.0-tolerance_min) AND (90.0+tolerance_min) THEN
		-- signed direction of angle rotation
		CASE 
			WHEN degrees(rotation_azimuth) BETWEEN 90.0 AND (90.0+tolerance_max) then direction:=-1;
			WHEN degrees(rotation_azimuth) BETWEEN (270.0-tolerance_max) AND 270.0 then direction:=-1;
			ELSE direction:=1;
		END CASE;
		diff_angle:=(angle_p0-90.0)*direction;
		if (degrees(azimuth_p0_p1)-degrees(azimuth_pm1_p0))> 0 THEN
			diff_angle:=0-diff_angle;
		END IF;
		rotradians:=diff_angle*pi()/180.0;
	ELSE 
		diff_angle=0;
		rotRadians=0;
	END IF;	
	RETURN rotradians;
END
$PROC$ LANGUAGE 'plpgsql' VOLATILE;

