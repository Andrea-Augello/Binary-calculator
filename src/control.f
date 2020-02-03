: SET_OPERATION
	OP_SET GET_OP GET OPERATION ! ;

: APPEND ( n1 n2  -- 2n2 + n1  )
	1 LSHIFT + ;

: GET_NUMBER
	CLEAR
	0 CURRENT_VALUE !
	0
	BEGIN
		>R 
		READ_KEYPRESS DUP
		0 <> 
		IF
			DUP ?DIGIT 
	 		IF 
		 		R> 1 + >R 
		 		GET_DIGIT CURRENT_VALUE @ APPEND 
		 		STORE_VALUE
		 		STATUS @ CURRENT_VALUE @ SHOW 
	 		ELSE 
				R> DROP WORD_SIZE >R
				SET_OPERATION
			THEN
		ELSE
			DROP 
		THEN 
		R> DUP WORD_SIZE >=
	UNTIL 
	DROP ;

: GET_OPERATION
	BEGIN
		READ_KEYPRESS DUP
		0 <> OVER ?DIGIT NEGATE AND	\ Input is not null and is not a digit
		IF
			SET_OPERATION
			1									\ exit loop
		ELSE
			DROP								\ discard invalid/null input
			0									\ stay in loop
		THEN
	UNTIL ;

: MAIN_LOOP 
	BEGIN 
		GET_RESULT
		PREPARE_NEXT

		GET_NUMBER 
		OPERATION @ 0 = 					\ check if the operation hasn't already been set
		IF
			GET_OP
		THEN

	0 UNTIL ;

\ MAIN_LOOP
