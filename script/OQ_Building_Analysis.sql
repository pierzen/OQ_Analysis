
CREATE OR REPLACE FUNCTION public.OQ_Building_Analysis(id bigint, linestring geometry, 
	tags hstore default '"building" => "multipolygon", "QA" => "oq_polygon_ortho"') 
RETURNS json AS $PROC$
DECLARE
	-- OQ_Building_Analysis Performs Topology Validation and Form Analysis on buildings
	iDebug integer =0;
	nb_points integer;
	nb_points_m integer;
	nb_points_m_rev float;
	angle_reg float;
	tolerance_angle_1 float;
	tolerance_angle_2 float;
	tolerance_angle_3 float;
	-- angles analyzed are 
	-- q 90 / 270 degres
	-- h 45 / 135 / 225 / 315 / degres
	-- d 180 (points in a straight line)
	-- 
	angle_h_m float;
	angle_h_p float;
	angle_h2_m float;
	angle_h2_p float;
	angle_h3_m float;
	angle_h3_p float;
	angle_h4_m float;
	angle_h4_p float;
	angle_hh_m float;
	angle_hh_p float;
	angle_hh2_m float;
	angle_hh2_p float;
	angle_hh3_m float;
	angle_hh3_p float;
	angle_hh4_m float;
	angle_hh4_p float;
	angle_q_m float;
	angle_q_p float;
	angle_q2_m float;
	angle_q2_p float;
	angle_qq_m float;
	angle_qq_p float;
	angle_qq2_m float;
	angle_qq2_p float;
	angle_qqq_m float;
	angle_qqq_p float;
	angle_qqq2_m float;
	angle_qqq2_p float;
	angle_r_m float;
	angle_r_p float;
	angle_r2_m float;
	angle_r2_p float;
	angle_rr_m float;
	angle_rr_p float;
	angle_rr2_m float;
	angle_rr2_p float;
	angle_d_m float;
	angle_d_p float;
	angle_dd_m float;
	angle_dd_p float;
	deg_var_max float;
	l integer;
	elem text;
	e_angle float; 
	l_point geometry[];
	polygon geometry;
	lp_degre float[];
	lv_azimuth float[];
	lp_angle float[];
	lp_type_angle text[];
	grptag text;
	sgrptag text;
	type_polygon text;
	npoints text;
	tangles int;
	mangle float;
	pm1 integer;
	p0 integer;
	p1 integer;
	p2 integer;
	angle_deb integer;
	angle_end integer;	
	gti int;
	tnd int;
	tir int;
	trr int;
	tr int;	
	tq int;
	tqq int;
	tqqq int;
	th int;
	thh int;
	td int;
	tdd int;
	ts int;
	t2m2 int;
	tv int;
	tinvalid int;
	iflag int;
	poly_types_angle text;
	type_geom text;
	tpoints text;
	tazimuths text;
	tresultat text;
	resultat text[];
BEGIN
	tolerance_angle_1=2;
	tolerance_angle_2=5;
	tolerance_angle_3=10;
	angle_q_m   =  90 - tolerance_angle_1;
	angle_q_p   =  90 + tolerance_angle_1;
	angle_q2_m  = 270 - tolerance_angle_1;
	angle_q2_p  = 270 + tolerance_angle_1;
	angle_qq_m  =  90 - tolerance_angle_2;
	angle_qq_p  =  90 + tolerance_angle_2;
	angle_qq2_m = 270 - tolerance_angle_2;
	angle_qq2_p = 270 + tolerance_angle_2;

	angle_qqq_m  =  90 - tolerance_angle_3;
	angle_qqq_p  =  90 + tolerance_angle_3;
	angle_qqq2_m = 270 - tolerance_angle_3;
	angle_qqq2_p = 270 + tolerance_angle_3;

	angle_h_m   =  45 - tolerance_angle_1;
	angle_h_p   =  45 + tolerance_angle_1;
	angle_h2_m  = 135 - tolerance_angle_1;
	angle_h2_p  = 135 + tolerance_angle_1;
	angle_h3_m  = 225 - tolerance_angle_1;
	angle_h3_p  = 225 + tolerance_angle_1;
	angle_h4_m  = 315 - tolerance_angle_1;
	angle_h4_p  = 315 + tolerance_angle_1;
	angle_hh_m  =  45 - tolerance_angle_2;
	angle_hh_p  =  45 + tolerance_angle_2;
	angle_hh2_m = 135 - tolerance_angle_2;
	angle_hh2_p = 135 + tolerance_angle_2;
	angle_hh3_m = 225 - tolerance_angle_2;
	angle_hh3_p = 225 + tolerance_angle_2;
	angle_hh4_m = 315 - tolerance_angle_2;
	angle_hh4_p = 315 + tolerance_angle_2;

	angle_d_m  = 180 - tolerance_angle_1;
	angle_d_p  = 180 + tolerance_angle_1;
	angle_dd_m = 180 - tolerance_angle_2;
	angle_dd_p = 180 + tolerance_angle_2;
	nb_points = ST_NPoints(linestring);
	
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

	IF (ST_NPoints(linestring)< 4 OR ST_IsClosed(linestring) is false)
	THEN return format('{ "grptag":"%s", "flag": "1", "npoints": "%s", "type_polygon": "%s_v", "nb_angles": 0,
				"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring), sgrptag)::json;
	ELSIF ST_NPoints(linestring)> 3 and ST_IsValid(ST_Polygon(linestring, 4326)) is false
	THEN return format('{ "grptag":"%s", "flag":"1", "npoints": "%s", "type_polygon": "%s_invalid", "nb_angles": 0,
				"angles": "{NULL}", "type_geom": "{NULL}", "poly_types_angle": "{NULL}", "l_polygon": "{NULL}" }', grptag, ST_NPoints(linestring), sgrptag)::json;
	ELSE
		IF ST_IsClosed(linestring) = False OR ST_IsValid(ST_Polygon(linestring, 4326)) is false
		THEN polygon=null;
		ELSE polygon=ST_Polygon(linestring, 4326);
		END IF;
		nb_points_m = nb_points-1;
		FOR k IN 1..nb_points 
		LOOP
			l_point[k]=ST_Pointn(linestring, k)::geometry;
		END LOOP;
		-- Generalisation - Accept unclosed polygons (for topology segment linestrings)
		IF polygon=null THEN
			angle_deb=2;
			angle_end=nb_points;
		ELSE
			angle_deb=1;
			angle_end=1;
		END IF;		
		FOR k IN angle_deb..nb_points_m LOOP
			-- vertice from point k (p0) to point k+1 (p1)
			IF k=nb_points_m THEN p1=angle_end;
			else  p1=k+1;
			END IF;
			p0=k;			
			lv_azimuth[k] = ST_Azimuth(ST_SetSRID(l_point[p0],4326)::geography, ST_SetSRID(l_point[p1],4326)::geography);
		END LOOP;
		lv_azimuth   [nb_points] = lv_azimuth [1];
		FOR k IN angle_deb..nb_points_m 
		LOOP
			-- angle between vertice k-1 (pm1,p0) and k (p0,p1)
			p0=k;
			IF k=(nb_points_m-1) THEN 
				pm1=k-1;
				p1=k;
			ELSIF k=nb_points_m THEN 
				pm1=k-1;
				p1=angle_end;
			ELSIF k=1 THEN 
				-- polygon loop
				pm1=nb_points_m;
				p0=1;
				p1=2;
			ELSE 
				pm1=k-1;
				p1=k+1;
			END IF;
						
			lp_angle [k] = abs(round(@(180-(@(degrees(lv_azimuth[p0])-degrees(lv_azimuth[pm1]) ) ))::numeric,1));

		END LOOP;
		lp_angle   [nb_points] = lp_angle [1];
		gti=0;
		tangles=0;
		IF nb_points>3 and array_length(lp_angle,1)>=nb_points_m THEN
			FOR k IN 1..nb_points_m LOOP
				IF (lp_angle[k] between angle_d_m and angle_d_p) then gti = gti + 1;
				ELSE
					-- sum angles - ignore points on straight line (ie. 180 degre)
					tangles=tangles+lp_angle[k];
				END IF;
			END LOOP;
		END IF;

		nb_points_m_rev=(nb_points_m::float - gti)::float;
		angle_reg=(((nb_points_m_rev-2.0)*180.0)/nb_points_m_rev)::float;
		angle_r_m = angle_reg-tolerance_angle_1;
		angle_r_p = angle_reg+tolerance_angle_1;
		angle_rr_m = angle_reg-tolerance_angle_2;
		angle_rr_p = angle_reg+tolerance_angle_2;
		deg_var_max=0;
		tnd=0;
		tir=0;
		trr=0;
		tr=0;
		th=0;
		thh=0;
		tq=0;
		tqq=0;
		tqqq=0;
		td=0;
		tdd=0;
		t2m2=0;
		ts=0;
		tv=0;
		tinvalid=0;
		FOR k IN angle_deb..nb_points_m 
		LOOP
			IF k=nb_points_m THEN l=angle_end;
			ELSE l=k+1;
			END IF;
			IF k=nb_points_m and ST_IsClosed(linestring) = false THEN lp_type_angle[k] = 'v';
			-- ignore 180 degres (point in a straight line) for orthogonal measure
			elsif lp_angle [k] between angle_d_m and angle_d_p then lp_type_angle[k] = 'd';
			elsif lp_angle [k] between angle_dd_m and angle_dd_p then lp_type_angle[k] = 'dd';
			elsif lp_angle [k] between angle_q_m and angle_q_p then lp_type_angle[k] = 'q';
			elsif lp_angle [k] between angle_q2_m and angle_q2_p then lp_type_angle[k] = 'q';
			elsif lp_angle [k] between angle_r_m and angle_r_p then lp_type_angle[k] = 'r';
			elsif lp_angle [k] between angle_r2_m and angle_r2_p then lp_type_angle[k] = 'r';
			elsif lp_angle [k] between angle_h_m and angle_h_p then lp_type_angle[k] = 'h';
			elsif lp_angle [k] between angle_h2_m and angle_h2_p then lp_type_angle[k] = 'h';
			elsif lp_angle [k] between angle_h3_m and angle_h3_p then lp_type_angle[k] = 'h';
			elsif lp_angle [k] between angle_h4_m and angle_h4_p then lp_type_angle[k] = 'h';
			elsif lp_angle [k] between angle_qq_m and angle_qq_p then lp_type_angle[k] = 'qq';
			elsif lp_angle [k] between angle_qq2_m and angle_qq2_p then lp_type_angle[k] = 'qq';
			elsif lp_angle [k] between angle_rr_m and angle_rr_p then lp_type_angle[k] = 'rr';
			elsif lp_angle [k] between angle_rr2_m and angle_rr2_p then lp_type_angle[k] = 'rr';
			elsif lp_angle [k] between angle_hh_m and angle_hh_p then lp_type_angle[k] = 'hh';
			elsif lp_angle [k] between angle_hh2_m and angle_hh2_p then lp_type_angle[k] = 'hh';
			elsif lp_angle [k] between angle_hh3_m and angle_hh3_p then lp_type_angle[k] = 'hh';
			elsif lp_angle [k] between angle_hh4_m and angle_hh4_p then lp_type_angle[k] = 'hh';
			elsif lp_angle [k] between angle_qqq_m and angle_qqq_p then lp_type_angle[k] = 'qqq';
			elsif lp_angle [k] between angle_qqq2_m and angle_qqq2_p then lp_type_angle[k] = 'qqq';
			else lp_type_angle[k] = 'ir';
			END IF;
			IF lp_type_angle[k]='nd' THEN tnd=tnd+1;
			ELSIF lp_type_angle[k]='ir' THEN tir=tir+1;
			ELSIF lp_type_angle[k]='rr' THEN trr=trr+1;
			ELSIF lp_type_angle[k]='r' THEN tr=tr+1;
			elsif lp_type_angle[k]='q' then tq=tq+1;
			elsif lp_type_angle[k]='qq' then tqq=tqq+1;
			elsif lp_type_angle[k]='qqq' then tqqq=tqqq+1;
			elsif lp_type_angle[k]='h' then th=th+1;
			elsif lp_type_angle[k]='hh' then thh=thh+1;
			elsif lp_type_angle[k]='d' then td=td+1;
			elsif lp_type_angle[k]='dd' then tdd=tdd+1;
			ELSE RAISE NOTICE 'id %, total not selected, %, (%)', id, k, lp_type_angle[k];
			END IF;
		END LOOP;
		
		IF (ST_IsClosed(linestring)= false OR nb_points<4)
			and (exist(tags, 'building') or exist(tags, 'landuse') OR exist(tags, 'leisure')
			 or  exist(tags, 'natural')  or exist(tags, 'man_made'))
		THEN type_polygon=format('%s_v',sgrptag);
		ELSIF (nb_points=4)  
			 and (exist(tags, 'building') or exist(tags, 'landuse') OR exist(tags, 'leisure')
			 or   exist(tags, 'natural')  or exist(tags, 'man_made'))
		THEN type_polygon=format('%s_s',sgrptag);
		ELSIF ST_isvalid(polygon)=true and ST_Area(polygon::geography)<2.0
		THEN type_polygon=format('%s_2m2',sgrptag);
		ELSIF tv > 0 THEN type_polygon= format('%s_v',sgrptag);
		ELSIF t2m2 > 0 THEN type_polygon=format('%s_2m2',sgrptag);
		ELSIF ts > 0 THEN type_polygon=format('%s_s',sgrptag);
		elsif ((th+tq+tr)>4) and (tq+tr+th+td) = nb_points_m then type_polygon='r';
		elsif grptag<>'building' then type_polygon='nd';
		-- flag building polygon only
		elsif tir > 0 then type_polygon = 'FB_irreg';
		elsif ((th+tq+tr+thh+tqq+trr)>4) and ((th+tq+tr+thh+tqq+tqqq+td+tdd) = nb_points_m)
		then type_polygon = 'FB_rr';
		elsif ((th+tq+tr+thh+tqq+tqqq+trr)>4) and ((th+tq+tr+thh+tqq+tqqq+trr+td+tdd) = nb_points_m)
		then type_polygon = 'FB_rrr';
		elsif ((th+tq+tr+thh+tqq+tqqq+trr+tir)>4) and ((th+tq+tr+thh+tqq+tqqq+trr+td+tdd+tir) = nb_points_m)
		then type_polygon = 'FB_irreg';
		else type_polygon='nd';
		END IF;

		poly_types_angle='';
		if tq>0 then poly_types_angle:=trim(poly_types_angle ||'-q');
		end if;
		if tqq>0 then poly_types_angle:=trim(poly_types_angle ||'-qq');
		end if;
		if tqqq>0 then poly_types_angle:=trim(poly_types_angle ||'-qqq');
		end if;
		if tr>0 then poly_types_angle:=trim(poly_types_angle ||'-r');
		end if;
		if trr>0 then poly_types_angle:=trim(poly_types_angle||'-rr');
		end if;
		if th>0 then poly_types_angle:=trim(poly_types_angle ||'-h');
		end if;
		if thh>0 then poly_types_angle:=trim(poly_types_angle||'-hh');
		end if;
		if tdd>0 then poly_types_angle:=trim(poly_types_angle ||'-dd');
		end if;
		if tir>0 then poly_types_angle:=trim(poly_types_angle ||'-ir');
		end if;
		poly_types_angle=ltrim(poly_types_angle,'-');
		-- type_geom tqqq - th - thh distinct
		CASE
			WHEN type_polygon='' THEN type_geom:='';
			WHEN (tq+tr)>0 and (tqq+tqqq+trr+th+thh+tdd)=0 and tir=0 THEN type_geom:='  reg';
			WHEN (tq+tr+th)>0 and (tqq+tqqq+trr+thh+tdd)=0 and tir=0 THEN type_geom:='  reg-h';
			WHEN (tq+tr)>0 and (tqq+tqqq+trr+tdd)=0 and tir>0 THEN type_geom:='  reg-ireg';
			WHEN (tq+tr)=0 and (tqq+trr+tdd)=0 and tir>0 THEN type_geom:='ireg';
			WHEN (tqq+trr+tdd)>0 and (tqqq+thh)=0 and tir=0 THEN type_geom:=' rreg';
			WHEN (tqq+tqqq+trr+tdd)>0 and thh=0 and tir=0 THEN type_geom:=' rreg-qqq';
			WHEN (tqq+tqqq+trr+thh+tdd)>0 and tir=0 THEN type_geom:=' rreg-hh';
			WHEN (tqq+tqqq+trr+tdd)>0 and tir>0 THEN type_geom:='rreg-ireg';
			ELSE type_geom:='-nd-';
		END CASE;
		IF ltrim(type_geom) in ('','reg') then iflag=0;
		ELSE iflag=1;			   
		END IF;
			
		npoints = nb_points::text;
		tresultat=format('{ "grp_tag":"%s", "flag":"%s",  "nb_points": "%s", "type_geom": "%s", "poly_types_angle": "%s", "type_polygon": "%s", "nb_angles": %s, "angle_list": "%s", "type_angle_list": "%s"}', grptag, iflag, npoints, type_geom, poly_types_angle,type_polygon, nb_points_m-td, lp_angle, lp_type_angle);
		RETURN tresultat;
	END IF;
END
$PROC$ LANGUAGE plpgsql;
