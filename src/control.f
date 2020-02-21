: SET_OPERATION	( KEY_NUM  -- )
	KEY>OPERATION OP_SET 
	SWAP GET OPERATION ! ;

: GET_OPERATION
	BEGIN
		READ_KEYPRESS DUP
		?VALID OVER ?OPERATION AND 	\ Checks if input is a valid operation;
												\ in this phase digits are discarded.
		IF
			SET_OPERATION
			TRUE								\ exit loop
		ELSE
			DROP								\ discard invalid/null input
			FALSE								\ stay in loop
		THEN
	UNTIL ;

: APPEND ( n1 n2  -- 2n2 + n1  )
	1 LSHIFT OR ;	 		\ n2 is always a single bit, so a more efficient OR 
								\ operation is used in place of a sum.

: GET_NUMBER 				\ reads digits until a full word has been inputed 
								\ or an operation is selected.
	CLEAR_DISPLAY
	0 CURRENT_VALUE !
	0											\ initializes loop
	BEGIN
		>R 
		PEEK_KEYPRESS DUP
		?VALID 					
		IF
			?DIGIT 
	 		IF 
		 		R> 1 + >R 
				READ_KEYPRESS KEY>DIGIT 
				CURRENT_VALUE @ APPEND 
		 		STORE_VALUE 
				RESULT SHOW
	 		ELSE 
				R> DROP WORD_SIZE >R 	\ sets the loop termination condition
			THEN
		ELSE
			DROP 
		THEN 
		R> DUP WORD_SIZE >=				\ checks if all the bits have been set
	UNTIL 
	DROP ;


: WAIT_KEYPRESS
	BEGIN
		PEEK_KEYPRESS ?VALID				\ busy loop until a key is pressed
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
			IF									\ If, after an EQUALS, a digit is pressed
				PREPARE_NEXT				\ the previous result is discarded and
				GET_NUMBER					\ a new operand is expected.
			THEN
		THEN	
		GET_OPERATION						\ At this point either an operand has been
												\ inputed, or the previous result is used.
												\ In any case, it is safe to ask for an
												\ operation.

		OPERATION @ ['] EQUALS =		\ The operations for equals were offloaded
												\ to this module.
		IF										\ If EQUALS is selected the current result
			RESULT SHOW						\ is displayed,
			CLEAR_OPERATION				\ the current operations (EQUALS) is cleared
			WAIT_KEYPRESS					\ and the calculator will wait for further
		THEN									\ isntructions.
	0 UNTIL ;

: SETUP
	DISPLAY_SETUP
	INPUT_SETUP 
	LOGIC_SETUP ;

: START
	SETUP
	MAIN_LOOP ;

\ START
