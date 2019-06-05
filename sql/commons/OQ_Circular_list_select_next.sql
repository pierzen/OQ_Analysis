DROP FUNCTION public.OQ_Circular_list_select_next(in circular_list integer[], kp integer, variation integer) ;

CREATE OR REPLACE FUNCTION public.OQ_Circular_list_select_next(in circular_list integer[], kp integer, variation integer) 
RETURNS integer AS $PROC$
DECLARE
	-- Search circular process list for next previous kp
	-- variation = +- for next cell to select (ie. kp-1, kp+1)
	nb_process integer;
	kp_next integer;
BEGIN
	nb_process=array_length(circular_list, 1);
	IF kp>nb_process THEN
		RAISE WARNING 'OQ_Circular_list_select_next, kp % GT list dim (%)', kp, nb_process;
	END IF;
	IF (kp+variation)<1 THEN
		kp_next=nb_process+(kp+variation);
	ELSIF (kp+variation)>nb_process THEN
		kp_next=kp+variation-nb_process;
	ELSE kp_next=kp+variation;
	END IF;
	RAISE INFO 'find_next dim(%) kp % next % diff % kp_next %', nb_process, kp, variation, (kp+variation), kp_next;
	RETURN kp_next;
END
$PROC$ LANGUAGE plpgsql;
