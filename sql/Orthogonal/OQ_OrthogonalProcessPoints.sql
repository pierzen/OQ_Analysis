DROP FUNCTION public.OQ_OrthogonalProcessPoints(integer, float, double precision[]);

CREATE OR REPLACE FUNCTION public.OQ_OrthogonalProcessPoints(k_angle_deb integer, tolerance_max float, lp_angle double precision[]) 
RETURNS TABLE (lk_process_s1 integer[], lk_process_180_s2 integer[], lk_prev_s1 integer[], lk_next_s1 integer[])
AS $PROC$
DECLARE
	nb_points_m integer;
	nb_angles_m integer;
	nb_lk_process_s1 integer;
	lk_process_s1 integer[];
	lk_process_180_s2 integer[] DEFAULT '{}';
	lk_prev_s1 integer[] DEFAULT '{}';
	lk_next_s1 integer[] DEFAULT '{}';
BEGIN
	-- list of points to process 
	-- Step 1 points near 90	lk_process_s1 
	-- Step 2 points near 180	lk_process_s2
	-- For S2 points, References to prev - next S1 point

	nb_points_m=array_length(lp_angle,1)-1;
	nb_angles_m=nb_points_m-k_angle_deb+1;
	-- For unclosed linestring, k_angle_deb=2
	FOR kl IN k_angle_deb..nb_angles_m
	LOOP
		raise info '% % %', kl, k_angle_deb, nb_angles_m;
		IF lp_angle [kl] NOT BETWEEN (180-tolerance_max) AND (180+tolerance_max) THEN 
			lk_process_s1=array_append(lk_process_s1,kl);
			lk_prev_s1[kl]=kl;
			lk_next_s1[kl]=kl;
		ELSE lk_process_180_s2=array_append(lk_process_180_s2,kl);
			-- to be determined in next steps
			lk_prev_s1[kl]=0;
			lk_next_s1[kl]=0;
		END IF;
	END LOOP;

	FOR kl IN REVERSE (nb_points_m-1)..k_angle_deb 
	LOOP
		raise info 'R % % %', kl, k_angle_deb, nb_angles_m;
		IF lk_next_s1[kl]=0 AND lk_next_s1[kl+1]>0 THEN 
			lk_next_s1[kl]=lk_next_s1[kl+1];
		END IF;
	END LOOP;
	IF k_angle_deb=1 THEN
		lk_next_s1[nb_points_m]=lk_next_s1[1];
	END IF;

	FOR kl IN (k_angle_deb+1)..nb_angles_m
	LOOP
		raise info '% % %', kl, k_angle_deb, nb_angles_m;
		IF lk_prev_s1[kl]=0 AND lk_prev_s1[kl-1]>0 THEN 
			lk_prev_s1[kl]=lk_prev_s1[kl-1];
		END IF;
		IF lk_next_s1[kl]=0 THEN 
			lk_next_s1[kl]=lk_next_s1[kl-1];
		END IF;
	END LOOP;
	IF k_angle_deb=1 THEN
		lk_prev_s1[1]=lk_prev_s1[nb_points_m];
	END IF;
	RETURN QUERY
	SELECT lk_process_s1, lk_process_180_s2, lk_prev_s1, lk_next_s1;
END
$PROC$ LANGUAGE 'plpgsql' VOLATILE;
