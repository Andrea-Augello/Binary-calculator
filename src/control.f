: DISPLAY_RESULT
	STATUS @
	CURRENT_VALUE @
	SHOW ;

: SET_OPERATION
	GET_OP# OP_SET SWAP
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
	UNTIL 
	DROP ;

: GET_OPERATION
	BEGIN
		READ_KEYPRESS DUP
		0 <> OVER ?DIGIT INVERT AND	\ Input is not null and is not a digit
		IF
			SET_OPERATION
			TRUE								\ exit loop
		ELSE
			DROP								\ discard invalid/null input
			FALSE								\ stay in loop
		THEN
	UNTIL ;

: WAIT_KEYPRESS
	BEGIN
		PEEK_KEYPRESS 0 <>				\ busy loop until a key is pressed
	UNTIL ;

: MAIN_LOOP 
	BEGIN 
		OPERATION @ 0 <> 					\ check if a valid operation has been set
												\ the only way for no operation to be set
												\ is if the previous operation was EQUALS
		IF										\ If it has it gets the right operand and
												\ computes the result.
			PREPARE_NEXT
			GET_NUMBER 
 			COMPUTE_RESULT
			CLEAR_OPERATION
		ELSE
			PEEK_KEYPRESS ?DIGIT
			IF
				PREPARE_NEXT
				GET_NUMBER
			THEN
		THEN	
		GET_OPERATION

		OPERATION @ ['] EQUALS =		\ The operations for equals were offloaded
												\ to this module
		IF
			DISPLAY_RESULT
			CLEAR_OPERATION
			WAIT_KEYPRESS
		THEN
	0 UNTIL ;

\ MAIN_LOOP
