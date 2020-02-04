: DISPLAY_RESULT
	STATUS @
	CURRENT_VALUE @
	SHOW ;

: SET_OPERATION
	READ_OP OP_SET SWAP
	GET OPERATION ! ;

: APPEND ( n1 n2  -- 2n2 + n1  )
	1 LSHIFT + ;

: GET_NUMBER 				\ reads digits until a full word has been inputed 
								\ or an operation is selected
	CLEAR
	0 CURRENT_VALUE !
	0
	BEGIN
		>R 
		PEEK_KEYPRESS DUP
		0 <> 					\ checks for valid input
		IF
			?DIGIT 
	 		IF 
		 		R> 1 + >R 
				READ_KEYPRESS
		 		GET_DIGIT CURRENT_VALUE @ APPEND 
		 		STORE_VALUE
				DISPLAY_RESULT
	 		ELSE 
				R> DROP WORD_SIZE >R 	\ sets the loop counter to termination condition
			THEN
		ELSE
			DROP 
		THEN 
		R> DUP WORD_SIZE >=
		100 MILLISECONDS DELAY 
	UNTIL 
	DROP ;

: GET_OPERATION
	BEGIN
		READ_KEYPRESS DUP
		0 <> OVER ?DIGIT INVERT AND	\ Input is not null and is not a digit
		IF
			SET_OPERATION
			1									\ exit loop
		ELSE
			DROP								\ discard invalid/null input
			0									\ stay in loop
		THEN
		100 MILLISECONDS DELAY 
	UNTIL ;

: MAIN_LOOP 
	BEGIN 
		OPERATION @ 0 <> 					\ check if a valid operation has been set
		IF
			PREPARE_NEXT
			GET_NUMBER 
 			COMPUTE_RESULT
			0 OPERATION !
		ELSE
			PEEK_KEYPRESS ?DIGIT
			IF
				PREPARE_NEXT
				GET_NUMBER
			ELSE
				
			THEN
		THEN	
		GET_OPERATION

		OPERATION @ EQUALS =
		IF
			DISPLAY_RESULT
			0 OPERATION !
			BEGIN
				PEEK_KEYPRESS 0 <>		\ displays result until a key is pressed
			UNTIL
		ELSE
		THEN


	0 UNTIL ;

\ MAIN_LOOP
