
CREATE OR REPLACE FUNCTION public.OQ_Calc_Classify_Angles(IN linestring geometry(linestring, 4326))
RETURNS TABLE(k_angle_deb integer,k_angle_end integer, l_point geometry(point, 4326)[], lv_azimuth double precision[], lp_angle double precision[], lp_tpolygon text[]) 
AS $PROC$
DECLARE	
	nb_points integer;
	nb_points_m integer;
	nb_points_m_rev float;
	angle_reg float;
	variance_angle float;
	variance2_angle float;
	angle_regm float;
	angle_regp float;
	angle_reg2m float;
	angle_reg2p float;
	pm1 integer;
	p0 integer;
	p1 integer;
	gti integer;
	l integer;
	k_angle_deb integer;
	k_angle_end integer;
	tangles int;
	mangle float;
	l_point geometry(point, 4326)[];
	lv_azimuth double precision[];
	lp_angle double precision[];
	lp_tpolygon text[];
BEGIN
	nb_points = ST_NPoints(linestring);
	nb_points_m = nb_points-1;
	FOR kl IN 1..nb_points 
	LOOP
		l_point[kl]=ST_Pointn(linestring, kl); --::geometry(point, 4326);
	END LOOP;
	-- Generalisation - Accept unclosed polygons (for topology segment linestrings)
	IF not ST_Equals(l_point[1],l_point[nb_points]) THEN
		k_angle_deb=2;
		k_angle_end=nb_points;
	ELSE
		k_angle_deb=1;
		k_angle_end=1;
	END IF;
	
	FOR kl IN k_angle_deb..nb_points_m LOOP
		-- vertice from point kl (p0) to point kl+1 (p1)
		IF kl=nb_points_m THEN p1=k_angle_end;
		else  p1=kl+1;
		END IF;
		p0=kl;
		lv_azimuth[kl] = ST_Azimuth(l_point[p0]::geography, l_point[p1]::geography);
	END LOOP;
	lv_azimuth   [nb_points] = lv_azimuth [1];
	FOR kl IN k_angle_deb..nb_points_m 
	LOOP
		-- angle between vertice kl-1 (pm1,p0) and kl (p0,p1)
		p0=kl;
		IF kl=(nb_points_m-1) THEN 
			pm1=kl-1;
			p1=kl;
		ELSIF kl=nb_points_m THEN 
			pm1=kl-1;
			p1=k_angle_end;
		ELSIF kl=1 THEN 
			-- polygon loop
			pm1=nb_points_m;
			p0=1;
			p1=2;
		ELSE 
			pm1=kl-1;
			p1=kl+1;
		END IF;
					
		lp_angle [kl] = abs(round(@(180-(@(degrees(lv_azimuth[p0])-degrees(lv_azimuth[pm1]) ) ))::numeric,1));
	END LOOP;
	lp_angle   [nb_points] = lp_angle   [1];

	gti=0;
	tangles=0;
	IF nb_points>3 and array_length(lp_angle,1)>=nb_points_m THEN
		FOR kl IN 1..nb_points_m LOOP
			IF (lp_angle[kl] between 178 and 182) THEN
				gti = gti + 1;
			ELSE
				-- sum angles - ignore points on straight line (ie. 180 degre)
				tangles=tangles+lp_angle[kl];
			END IF;
		END LOOP;
	END IF;

	nb_points_m_rev=(nb_points_m::float - gti)::float;
	angle_reg=(((nb_points_m_rev-2.0)*180.0)/nb_points_m_rev)::float;
	variance_angle=(2.0/90.0)*angle_reg;
	variance2_angle=2.5*variance_angle;
	angle_regm = angle_reg-variance_angle;
	angle_regp = angle_reg+variance_angle;
	angle_reg2m = angle_reg-variance2_angle;
	angle_reg2p = angle_reg+variance2_angle;

	FOR kl IN k_angle_deb..nb_points_m 
	LOOP
		IF kl=nb_points_m THEN l=k_angle_end;
		ELSE l=kl+1;
		END IF;
		IF kl=nb_points_m and ST_IsClosed(linestring) = false THEN lp_tpolygon[kl] = 'v';
		-- ignore 180 degres (point in a straight line) for orthogonal measure
		ELSIF lp_angle [kl] between 178 and 182 THEN lp_tpolygon[kl] = 'i';
		ELSIF lp_angle [kl] between 176 and 184 THEN lp_tpolygon[kl] = 'ii';
		ELSIF lp_angle [kl] between 88 and 92 THEN lp_tpolygon[kl] = 'o';
		ELSIF lp_angle [kl] between 85 and 95 THEN lp_tpolygon[kl] = 'oo';
		ELSIF lp_angle [kl] between angle_regm and angle_regp THEN lp_tpolygon[kl] = 'r';
		ELSIF lp_angle [kl] between angle_reg2m and angle_reg2p THEN lp_tpolygon[kl] = 'rr';
		else lp_tpolygon[kl] = 'ir';
		END IF;	
	END LOOP;
		
	RETURN QUERY
	SELECT k_angle_deb, k_angle_end, l_point, lv_azimuth, lp_angle, lp_tpolygon;		

	RETURN;
END
$PROC$ LANGUAGE 'plpgsql' VOLATILE;
