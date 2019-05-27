
CREATE OR REPLACE FUNCTION public.OQ_Orthogonal(id bigint, linestring geometry(linestring, 4326), tolerance_min float DEFAULT 1.0, tolerance_max float default 10.0 ) 
RETURNS json AS $PROC$
DECLARE
	iDebug integer =0;
	nb_points integer;
	nb_points_m integer;
	nb_points_m_rev float;
	l integer;
	elem text;
	l_point geometry(point, 4326)[];
	polygon geometry;
	lp_degre double precision[];
	lv_azimuth double precision[];
	lp_angle float[];
	lp_tpolygon text[];
	grptag text default '';
	sgrptag text default '';
	tpolygon text;
	npoints text;
	tnd int  :=0;
	tir int  :=0;
	trr int  :=0;
	tr int   :=0;
	tto int  :=0;
	too int  :=0;
	ti int   :=0;
	tii int  :=0;
	ts int   :=0;
	t2m2 int :=0;
	tv int   :=0;
	
	-- orthogonal correction variables
	
	k integer;
	ks1 integer;
	ks2 integer;
	kl integer;
	kp integer;
	kn integer;
	kd integer;
	nb_lk_process_s1 integer;
	p_last integer;
	p_last_m1 integer;
	p_last_m2 integer;
	lk_process_s1 integer[];
	tpm1 integer;
	tp0 integer;
	tp1 integer;
	tp2 integer;
	pm1 integer;
	p0 integer;
	p1 integer;
	p2 integer;
	l_point_r geometry(point, 4326)[] DEFAULT '{}';
	pcentre_p0_p1 geometry(point, 4326);
	v_to_l_tangent geometry(point, 4326);
	c_vertice geometry(point, 4326)[] DEFAULT '{}';
	c_azimuth double precision[] DEFAULT '{}';
	c_inv_azimuth double precision[] DEFAULT '{}';
	c_distance float[] DEFAULT '{}';
	c_degre double precision[] DEFAULT '{}';
	c_angle double precision[] DEFAULT '{}';
	v_pm1_p0 geometry(linestring, 4326);
	v_p0_p1 geometry(linestring, 4326);
	v_p1_p2 geometry(linestring, 4326);
	dist_p0_p1 float;
	k_angle_deb integer;
	k_angle_end integer;
	degre_azimuth_pm1 double precision;
	degre_azimuth_p0 double precision;
	degre_azimuth_p1 double precision;
	degre_azimuth_p2 double precision;
	angle_pm1_vs_p1 float;
	azimuth_pm1_p0 double precision;
	azimuth_p0_pm1 double precision;
	azimuth_p0_p1 double precision;
	azimuth_p1_p2 double precision;
	azimuth_p2_p1 double precision;
	rotradians double precision;
	--xx diff_degre_azimuth_p0 double precision;
	--xx diff_degre_azimuth_p1 double precision;
	angle_p0 float;
	angle_p0r float;
	angle_p1 float;
	l_tangent_p0 geometry(linestring, 4326);
	length_tangent_p0 float;
	-- xx dist_mh_p0 float;
	-- xx dist_oh_p0 float;
	-- List Prefixes - lp points, lv vectors, lk indices
	lp_degre_r double precision[] DEFAULT '{}';
	lv_azimuth_r double precision[] DEFAULT '{}';
	lp_angle_r float[] DEFAULT '{}';
	lv_q_rev geometry(linestring, 4326)[] DEFAULT null;
	lv_p0_rev geometry(linestring, 4326)[] DEFAULT '{}';
	lv_p1_rev geometry(linestring, 4326)[] DEFAULT '{}';
	tlv_q_rev geometry(linestring, 4326)[] DEFAULT null;
	ttlv_q_rev text;
	lv_d_rev geometry(linestring, 4326)[] DEFAULT null;
	tlv_d_rev geometry(linestring, 4326)[] DEFAULT '{}';
	ttlv_d_rev text;
	tlv_p0_rev geometry(linestring, 4326)[] DEFAULT '{}';
	ttlv_p0_rev text;
	lk_process_180_s2 integer[] DEFAULT '{}';
	lk_prev_s1 integer[] DEFAULT '{}';
	lk_next_s1 integer[] DEFAULT '{}';
	--lv_distance_r float[];
	linestring_r geometry(linestring, 4326);
	tpoint_p0 geometry(point, 4326);
	tpoint_p1 geometry(point, 4326);
	
	tinvalid int :=0;
	iflag int;
	tags hstore;
	tpoints text;
	tazimuths text;
	tresultat json;
	resultat text[];
BEGIN
	nb_points = ST_NPoints(linestring);
	nb_points_m = nb_points-1;
	tags='"building" => "multipolygon", 
	"QA" => "oq_polygon_ortho"'::hstore;
	raise info 'tags %', tags;
	Perform (public.OQ_grptag(tags, grptag, sgrptag)).*;

	RAISE INFO 'tags %, grptag % sgrptag %', tags, grptag, sgrptag;

	raise info 'Deb test valid poly,  % Npoints % linestring %', id, ST_NPoints(linestring), ST_AsText(linestring,7);

	SELECT public.OQ_Report_Invalid_Polygon(tags, grptag, linestring) into tresultat ;
	RAISE INFO 'tresultat % flag %',tresultat, (tresultat->>'flag');
	k:=(tresultat->>'flag');
	IF k <> 0 THEN
		RETURN tresultat;
	END IF;

	IF ST_IsClosed(linestring) = False OR ST_IsValid(ST_Polygon(linestring, 4326)) is false
	THEN polygon=null;
	ELSE polygon=ST_Polygon(linestring, 4326);
	END IF;
	
	SELECT (public.OQ_Calc_Classify_Angles(linestring)).* 
	INTO k_angle_deb, k_angle_end, l_point, lv_azimuth, lp_angle, lp_tpolygon;
	
	-- Angle classification Totals

	FOR kl IN k_angle_deb..nb_points_m 
	LOOP	
		lv_d_rev= null;
		IF lp_tpolygon[kl]='nd' THEN tnd=tnd+1;
		ELSIF lp_tpolygon[kl]='ir' THEN tir=tir+1;
		ELSIF lp_tpolygon[kl]='rr' THEN trr=trr+1;
		ELSIF lp_tpolygon[kl]='r' THEN tr=tr+1;
		ELSIF lp_tpolygon[kl]='oo' THEN too=too+1;
		ELSIF lp_tpolygon[kl]='o' THEN tto=tto+1;
		ELSIF lp_tpolygon[kl]='i' THEN ti=ti+1;
		ELSIF lp_tpolygon[kl]='ii' THEN tii=tii+1;
		ELSE RAISE INFO 'total not selected, %, (%)', kl, lp_tpolygon[kl];
		END IF;
	END LOOP;
	
	l_point_r=l_point;
	lv_azimuth_r = lv_azimuth;
	lp_angle_r = lp_angle;

	
	/*
		From rotRadians measure of correction, rotates the way segment from the center poinnt 
							+ P1
						  / |
					  /     |
		P0 + - - (+)- - - - + P1 rev  (+) == Pivot
		rev     /           |
			  /             |
		P0 +  			    | 
		   |                |
		   |                |
		   +                |
	   Pm1 +  -  -	 -   -  + 	   

	-------- linestring - Orthogonal correction --------
	-- list of points to consider 
	-- nearly 180 degres points are considered simple points on a straight line. In Step 1, they are ignored for the orthogonalisation process. In step 2, they are aligned to points processed in step 1.
	-- Step 1 Stack points to process for angle corrrection
	-- Step 2 Stack points 180 to process in step 2, aligned to prev - next referenced points

	-- list of points to process 
	-- Step 1 points near 90	lk_process_s1 
	-- Step 2 points near 180	lk_process_s2
	-- For S2 points, References to prev - next S1 point
	*/
	
	SELECT (public.OQ_OrthogonalProcessPoints(1, tolerance_max, lp_angle)).* INTO lk_process_s1, lk_process_180_s2, lk_prev_s1, lk_next_s1;
	
	
	nb_lk_process_s1=array_length(lk_process_s1, 1);
	p_last=nb_lk_process_s1;
	p_last_m1=nb_lk_process_s1-1;
	p_last_m2=nb_lk_process_s1-2;

	linestring_r=linestring;	
	tpoints='';
	tazimuths='';
	FOR kl IN 1..nb_points
	LOOP
		tpoints=tpoints || format(', %s', ST_AsText(l_point_r[kl],7));
	END LOOP;
			
	-- seq>1 loop x time to test converge to orthogonal solution
	FOR seq IN 1..1 
	LOOP
		-- reconciliation of process_point vs lp_point array
		-- ks1 = key in lk_process_s1 array, 
		-- kl  = value in process_point array - correspond to key in lp_point array;
		ks1=0;
		FOREACH kl IN ARRAY lk_process_s1
		LOOP
			ks1=ks1+1;
			-- loop in lp_point_process to determine pm1, p0, p1, p2 for points near end - deb of lp_point_process
			IF kl=(p_last_m2) THEN 
				pm1=lk_process_s1[ks1-1];
				p0=lk_process_s1[p_last_m2];
				p1=lk_process_s1[p_last_m1];
				p2=lk_process_s1[p_last];
			ELSIF kl=p_last_m1 THEN 
				pm1=lk_process_s1[ks1-1];
				p0=lk_process_s1[p_last_m1];
				p1=lk_process_s1[p_last];
				p2=lk_process_s1[1];
			ELSIF kl=p_last THEN 
				pm1=lk_process_s1[p_last_m1];
				p0=lk_process_s1[p_last];
				p1=lk_process_s1[1];
				p2=lk_process_s1[2];
			ELSIF kl=1 THEN 
				pm1=lk_process_s1[p_last];
				p0=lk_process_s1[1];
				p1=lk_process_s1[2];
				p2=lk_process_s1[3];
			ELSE 
				pm1=lk_process_s1[ks1-1];
				p0=lk_process_s1[ks1];
				p1=lk_process_s1[ks1+1];
				p2=lk_process_s1[ks1+2];
			END IF;
			RAISE INFO '>> id % ks1 % kl=%, p_last_m2 %, p_last_m1 % p_last %', id, ks1, kl, p_last_m2, p_last_m1, p_last;

			RAISE INFO 'kl-SRID id % pm1 % 0 % 1 % 2 % %',id, pm1, p0, p1, p2, lk_process_s1;
			pm1=lk_process_s1[public.OQ_Circular_list_select_next(lk_process_s1,ks1,-1)];
			p0=lk_process_s1[ks1];
			p1=lk_process_s1[public.OQ_Circular_list_select_next(lk_process_s1,ks1,1)];
			p2=lk_process_s1[public.OQ_Circular_list_select_next(lk_process_s1,ks1,2)];

			RAISE INFO 'kl-rev id % - pm1 % - p0 % - p1 % - p2 % - %',id, pm1, p0, p1, p2, lk_process_s1;

			RAISE INFO 'SRID id % pm1 % 0 % 1 % 2 %',id, 
			ST_SRID(l_point_r[pm1]), ST_SRID(l_point_r[p0]), ST_SRID(l_point_r[p1]), ST_SRID(l_point_r[p2]);
			RAISE INFO 'id=% nb_lk_process_s1 % kl % ks1 %, pm1 %, p0 %, p1 %, p2 % lk_process_s1 %', id, nb_lk_process_s1, kl, ks1, pm1, p0, p1, p2, lk_process_s1;

			-- Skip revision IF both p0 and p1 are not quasi orthogonal or 180
			IF  lp_angle_r [p0]   NOT BETWEEN (90-tolerance_max) AND (90+tolerance_max)
			AND  lp_angle_r [p1]   NOT BETWEEN (90-tolerance_max) AND (90+tolerance_max)
			THEN
				lv_q_rev[kl]=ST_Makeline(ST_Collect(array[l_point_r[p0], l_point_r[p1]]));   
				CONTINUE; 
			END IF;
			IF  lp_angle_r [p0]   NOT BETWEEN (90-tolerance_max) AND (90+tolerance_max)
			THEN
				-- Starts with End angle of the vertice and reverse direction of vertice for this segment
				tpm1=pm1;
				tp0=p0;
				tp1=p1;
				tp2=p2;
				p2=tpm1;
				p1=tp0;
				p0=tp1;
				pm1=tp2;
			END IF;

			v_pm1_p0=ST_MakeLine(l_point_r[pm1], l_point_r[p0]);
			v_p0_p1 =ST_MakeLine(l_point_r[p0], l_point_r[p1]);
			v_p1_p2 =ST_MakeLine(l_point_r[p1], l_point_r[p2]);
			dist_p0_p1=ST_Length(v_p0_p1::geography);
			-- azimuths calculated with revised point coordinates
			azimuth_pm1_p0= ST_Azimuth(l_point_r[pm1]::geography,l_point_r[p0]::geography);
			azimuth_p0_pm1=ST_Azimuth(l_point_r[p0]::geography,l_point_r[pm1]::geography);
			azimuth_p0_p1= ST_Azimuth(l_point_r[p0]::geography,l_point_r[p1]::geography);
			azimuth_p1_p2= ST_Azimuth(l_point_r[p1]::geography,l_point_r[p2]::geography);
			azimuth_p2_p1= ST_Azimuth(l_point_r[p2]::geography,l_point_r[p1]::geography);
			
			degre_azimuth_pm1= degrees(azimuth_pm1_p0);
			degre_azimuth_p0= degrees(azimuth_p0_p1);
			degre_azimuth_p1= degrees(azimuth_p1_p2);
			-- diff degre takes account of the 360 degres divide
			angle_pm1_vs_p1=(abs(round(@(180-(@(degre_azimuth_p1-degre_azimuth_pm1 ) ))::numeric,1)));
			angle_p0 = (@(180-(@(degre_azimuth_p0-degre_azimuth_pm1) )));
			-- skip loop IF not quasi-rectangular
			angle_p1 = abs(@(180-(@(degre_azimuth_p1-degre_azimuth_p0) )));
			IF  abs(angle_p0) NOT BETWEEN (90-tolerance_max) AND (90+tolerance_max)
			-- skip angles not quasi orthogonal 
			THEN CONTINUE;
			END IF;

			-- Pivot quasi-ortho angles revision
			pcentre_p0_p1=ST_LineInterpolatePoint(ST_MakeLine(l_point_r[p0], l_point_r[p1]), 0.5);
			
			l_tangent_p0=ST_MakeLine(l_point_r[p0], pcentre_p0_p1);
			length_tangent_p0=ST_Length(l_tangent_p0::geography);
			lv_q_rev[kl]=ST_Makeline(ST_Collect(array[l_point_r[p0], pcentre_p0_p1, l_point_r[p1]])); 

			IF abs(angle_p0)>90.05 THEN 
				rotradians=public.OQ_OrthogonalRotation(0.01, 10, azimuth_pm1_p0,	azimuth_p0_p1);
				
				IF rotradians<0 THEN				
					lv_p0_rev[p0]=ST_Rotate(ST_MakeLine(array[l_point_r[p0], pcentre_p0_p1, l_point_r[p1]])::geometry, rotradians,pcentre_p0_p1::geometry);
					l_point_r[p0]=ST_PointN(lv_p0_rev[p0],1);
					l_point_r[p1]=ST_PointN(lv_p0_rev[p0],3);
				END IF;
			ELSIF abs(angle_p0)<89.95 THEN 
				tpoint_p0=l_point_r[p0];
				rotradians=public.OQ_OrthogonalRotation(0.01, 10, azimuth_pm1_p0,	azimuth_p0_p1);
				IF rotradians>0 THEN				
					lv_p0_rev[p0]=ST_Rotate(ST_MakeLine(array[l_point_r[p0], pcentre_p0_p1, l_point_r[p1]])::geometry, rotradians,pcentre_p0_p1::geometry);
					l_point_r[p0]=ST_PointN(lv_p0_rev[p0],1);
					l_point_r[p1]=ST_PointN(lv_p0_rev[p0],3);
				END IF;				
				degre_azimuth_p0= degrees(azimuth_p0_p1);
				degre_azimuth_p1= degrees(azimuth_p1_p2);
				
				degre_azimuth_p0= degrees(ST_Azimuth(ST_SetSRID(l_point_r[p0],4326)::geography, ST_SetSRID(l_point_r[p1],4326)::geography));
				degre_azimuth_p1= degrees(ST_Azimuth(ST_SetSRID(l_point_r[p1],4326)::geography, ST_SetSRID(l_point_r[p2],4326)::geography));
				angle_p0 = abs(@(180-(@(degre_azimuth_p0-degre_azimuth_pm1) )));
				-- skip loop IF not quasi-rectangular
				angle_p1 = abs(@(180-(@(degre_azimuth_p1-degre_azimuth_p0) )));
			END IF;

			linestring_r=ST_SetPoint(linestring_r, p0-1, l_point_r[p0]);		
			linestring_r=ST_SetPoint(linestring_r, p1-1, l_point_r[p1]);		
			
			-- End of loop for one vertice, revise angle measures
			lv_azimuth_r[pm1] = ST_Azimuth(ST_SetSRID(l_point_r[pm1],4326)::geography, ST_SetSRID(l_point_r[p0],4326)::geography);
			lv_azimuth_r[p0] = ST_Azimuth(ST_SetSRID(l_point_r[p0],4326)::geography, ST_SetSRID(l_point_r[p1],4326)::geography);
			lv_azimuth_r[p1] = ST_Azimuth(ST_SetSRID(l_point_r[p1],4326)::geography, ST_SetSRID(l_point_r[(p1+1)],4326)::geography);
			lp_angle_r [p0] = abs(round(@(180-(@(degrees(lv_azimuth_r[pm1])-degrees(lv_azimuth[p0]) ) ))::numeric,1));
			lp_angle_r [p1] = abs(round(@(180-(@(degrees(lv_azimuth_r[p0])-degrees(lv_azimuth[p1]) ) ))::numeric,1));
	
		END LOOP;
					
		
		tpoints='';
		tazimuths='';
		FOR kl IN 1..nb_points_m LOOP
			tpoints=tpoints || format(', %s', ST_AsText(l_point_r[kl],7));
		END LOOP;
	END LOOP;
	
	-- S2. 180 deg. angles processed after S1
	RAISE INFO '>180 dim lk_prev_s1 % %', array_length(lk_process_180_s2,1), lk_process_180_s2;
	FOREACH kl IN ARRAY lk_process_180_s2
	LOOP
		--RAISE INFO '>180 -> id= %, kl % ', id, kl;
		--ks2=ks2+1;
		RAISE INFO 'id(%) p-process % ', id,  lk_process_s1;
		RAISE INFO 'S2.p180 id=% kl % prev % next % ', id, lk_process_180_s2, lk_prev_s1, lk_next_s1;
		pm1=lk_prev_s1[kl];
		p0=kl;
		p1=lk_next_s1[kl];
		raise info '>180 id % kl % pm1 % p0 % p1 % ', id, kl, pm1, p0, p1;
		raise info '>180 pts pm1 % p0 % p1 %',  ST_AsText(l_point_r[pm1]), ST_AsText(l_point_r[p0]), ST_AsText(l_point_r[p1]);
		l_tangent_p0=ST_MakeLine(l_point_r[pm1], l_point_r[p1]);
		tpoint_p0=l_point_r[p0];
	
		v_to_l_tangent=ST_ClosestPoint(l_tangent_p0::geometry, l_point_r[p0]::geometry);
		l_point_r[p0]=v_to_l_tangent; 
		IF p0=1 THEN
			l_point_r[nb_points]=l_point_r[1];
		END IF;

		lv_d_rev[p0]=ST_Makeline(ST_Collect(array[tpoint_p0, l_point_r[p0]]));
		linestring_r=ST_SetPoint(linestring_r, p0 - 1, l_point_r[p0]);

	END LOOP;

	-- Final process - Report variables
	-----------------------------------------

	FOREACH kl IN ARRAY lk_process_s1
	LOOP
		tlv_q_rev=array_append(tlv_q_rev, lv_q_rev[kl]);
		tlv_p0_rev=array_append(tlv_p0_rev, lv_p0_rev[kl]);
	END LOOP;

	FOREACH kl IN ARRAY lk_process_180_s2
	LOOP
		tlv_d_rev=array_append(tlv_d_rev, lv_d_rev[kl]);
	END LOOP;

	ttlv_q_rev=ST_AsText(ST_Collect(tlv_q_rev), 7);
	ttlv_p0_rev=ST_AsText(ST_Collect(tlv_p0_rev), 7);
	IF ttlv_q_rev='{}' then ttlv_q_rev='MULTILINESTRING(())'; 
	END IF;
	ttlv_d_rev=ST_AsText(ST_Collect(tlv_d_rev), 7);
	IF ttlv_d_rev='{}' then ttlv_d_rev='MULTILINESTRING(())'; 
	END IF;

	-- polygons - assures that last.point=first.point
	if k_angle_deb=1 THEN
		l_point_r[nb_points]=l_point_r[1]; 	
		linestring_r=ST_SetPoint(linestring_r, ST_NumPoints(linestring_r) - 1, l_point_r[1]);
	END IF;

	IF (ST_IsClosed(linestring)= false OR nb_points<4)
		and (exist(tags, 'building') or exist(tags, 'landuse') OR exist(tags, 'leisure')
		 or  exist(tags, 'natural')  or exist(tags, 'man_made'))
	THEN tpolygon=format('%s_v',sgrptag);
	ELSIF (nb_points=4)  
		 and (exist(tags, 'building') or exist(tags, 'landuse') OR exist(tags, 'leisure')
		 or   exist(tags, 'natural')  or exist(tags, 'man_made'))
	THEN tpolygon=format('%s_s',sgrptag);
	ELSIF ST_isvalid(polygon)=true and ST_Area(polygon::geography)<2.0
	THEN tpolygon=format('%s_2m2',sgrptag);
	ELSIF tv > 0 THEN tpolygon= format('%s_v',sgrptag);
	ELSIF t2m2 > 0 THEN tpolygon=format('%s_2m2',sgrptag);
	ELSIF ts > 0 THEN tpolygon=format('%s_s',sgrptag);
	--ELSIF (tto+ti) = nb_points_m THEN tpolygon='o';
	ELSIF ((tto+tr)>4) and (tto+tr+ti) = nb_points_m THEN tpolygon='r';
	ELSIF grptag<>'building' THEN tpolygon='nd';
	-- flag building polygon only
	ELSIF tir > 0 THEN tpolygon = 'FB_irreg';
	--ELSIF ((too+tto+ti) = nb_points_m) THEN tpolygon = 'FB_oo';
	--ELSIF ((tr+trr)>4) and ((tr+trr+ti) = nb_points_m) THEN tpolygon = 'r';
	ELSIF ((tto+tr+too+trr)>4) and ((tto+tr+too+trr+ti+tii) = nb_points_m) THEN tpolygon = 'rr';
	ELSIF ((tr+tto) = nb_points_m) THEN tpolygon = 'FB_irreg';
	ELSIF ((trr+tr)>0) THEN tpolygon = 'FB_irreg';
	else tpolygon='nd';
	END IF;
	IF substring(tpolygon FROM 1 FOR 2) in ('FB','FO','rr','oo','ii') THEN iflag=1;
	ELSE iflag=0;
	END IF;
	
	FOR kl IN k_angle_deb..nb_points_m
	LOOP
		IF kl=nb_points_m THEN l=k_angle_end;
		else  l=kl+1;
		END IF;
		lp_degre_r[kl]= degrees(ST_Azimuth(ST_SetSRID(ST_Pointn(linestring_r, kl),4326)::geography, 
			ST_SetSRID(ST_Pointn(linestring_r, l),4326)::geography));
	END LOOP;

	-- revision degree and angle for pm1, p0, p1, p2
	FOR kl IN k_angle_deb..nb_points_m
	LOOP
		IF kl=1 THEN pm1=nb_points_m;
		else  pm1=kl-1;
		END IF;
		p0=kl;
		lp_angle_r [kl] = abs(round(@(180-(@(degrees(lv_azimuth_r[pm1])-degrees(lv_azimuth_r[p0]) ) ))::numeric,1));
		
	END LOOP;

	FOREACH ks1 IN ARRAY lk_process_s1
	LOOP
		kl=lk_process_s1[ks1];
		RAISE INFO 'PtQr %-% % % % %',id,kl, ST_AsText(l_point[kl]), ST_AsText(l_point_r[kl]), lp_angle_r [kl],  ST_AsText(tlv_q_rev[kl]);
	END LOOP;

	FOREACH kl IN ARRAY lk_process_180_s2
	LOOP
		RAISE INFO 'PtQd %-% % % % %',id,kl, ST_AsText(l_point[kl]), ST_AsText(l_point_r[kl]), lp_angle_r [kl],  ST_AsText(tlv_d_rev[kl]);
	END LOOP;
	
	FOR kl in 1..(nb_points)
	LOOP
		IF lv_q_rev[kl] = null THEN ttlv_q_rev='';
		ELSE ttlv_q_rev=ST_AsText(lv_q_rev[kl],7);
		END IF;
		IF lv_d_rev[kl] = null THEN ttlv_d_rev='';
		ELSE ttlv_d_rev=ST_AsText(lv_d_rev[kl],7);
		END IF;
		IF lv_p0_rev[kl] = null THEN ttlv_p0_rev='';
		ELSE ttlv_p0_rev=ST_AsText(lv_p0_rev[kl],7);
		END IF;
	END LOOP;

	
	FOR kl IN k_angle_deb..nb_points_m LOOP
		raise info 'kl % point % angle % point_r % angle_r %', kl, ST_AsText(l_point[kl],7), round(lp_angle[kl]::numeric,1), ST_AsText(l_point_r[kl],7), round(lp_angle_r[kl]::numeric,1);		
	END LOOP;

	npoints = nb_points::text;
	tresultat=format('{  "grptag":"%s", "flag":"%s","npoints": "%s", "tpolygon": "%s", "nb_angles": %s, "angles": "%s", "angles_r": "%s", "lp_tpolygon": "%s", "linestring": "%s", "linestring_r": "%s", "segments_q_rev": "%s", "segments_d_rev": "%s", "segments_p0_rev": "%s", "lk_S1":"%s", "lk_180_S2": "%s"}', grptag, iflag, npoints, tpolygon, (nb_points_m-ti), lp_angle, lp_angle_r, lp_tpolygon, ST_AsText(linestring, 7), ST_AsText(linestring_r, 7), ttlv_q_rev, ttlv_d_rev, ttlv_p0_rev, lk_process_s1, lk_process_180_s2);
	RETURN tresultat;
END
$PROC$ LANGUAGE plpgsql;


