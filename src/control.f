: APPEND ( n var -- var << 1 + n )
	DUP
	@ 2 * ROT +
	SWAP ! ;

: GET_NUMBER
	0
	BEGIN
		>R 
		READ_KEYPRESS DUP
		0 <> 
		IF
			DUP ?DIGIT 
				IF 
					R> 1 + >R 
					GET_DIGIT CURRENT_VALUE APPEND 
					STATUS CURRENT_VALUE @ SHOW 
				ELSE 
					DROP
				THEN
		ELSE
			DROP 
		THEN 
		R> DUP WORD_SIZE >=
	UNTIL 
	DROP ;
