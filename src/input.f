5 CONSTANT #OPS
2 CONSTANT #DIGITS
CREATE OP_KEYS 5 , 6 , 13 , 19 , 26 ,
CREATE DIGIT_KEYS 9 , 11 ,

: OP_MASK 
	0 0						\ 0-set mask and loop counter
	BEGIN
		DUP 1 + >R
		OP_KEYS SWAP GET 	\ On each cycle gets the pin# of the 
								\ (loop number)th button
		MASK OR			\ Computes the mask for the current pin and adds it to the
								\ mask computed so far
		R> DUP
		#OPS >=
	UNTIL
	DROP NIP ;

: OP_MASK [ OP_MASK ] LITERAL ;

: DIGIT_MASK 				\ Same as OP_MASK
	0 0
	BEGIN
		DUP 1 + >R
		DIGIT_KEYS SWAP GET 
		MASK OR
		R> DUP
		#DIGITS >=
	UNTIL
	DROP NIP ;

: DIGIT_MASK [ DIGIT_MASK ] LITERAL ;

: PEEK_KEYPRESS							
	[ OP_MASK DIGIT_MASK OR ] LITERAL 
	GPEDS0 @ AND 
	DUP 0 <>
	IF
		1 MILLISECONDS DELAY
		GPLEV0 @ INVERT AND 			\ Makes sure the button has properly been 
	THEN ;								\ released, else a keypress could be read twice

: CLEAR_KEYPRESS
	[ OP_MASK DIGIT_MASK OR ] LITERAL
	GPEDS0 ! ;

: READ_KEYPRESS
	PEEK_KEYPRESS
	DUP 0 <>
	IF
		1 MILLISECONDS DELAY				\ Debouncing, delay found by trial and error
		CLEAR_KEYPRESS 
	THEN ;

: ?DIGIT ( GPEDS0@ -- T/F )
	DIGIT_MASK AND 0 <>  ;

: GET_OP#			\	( GPEDS0@ -- operation )
	-1 0 										\ By default, if no op matches, 
												\ an invalid code ( -1 ) is returned
	BEGIN
		DUP >R								\ Stores in the return stack a copy of the
												\ loop counter, the other one will be consumed
		OP_KEYS SWAP GET MASK			\ Computes the mask for op_keys[loop_counter]
		ROT DUP 								\ Brings GPEDS0@ on top of the stack and makes
												\ a copy
		ROT AND 0 <>						\ Compares GPEDS0@ with the previously 
												\ computed mask
		IF 
			NIP								\ Removes the previous operation value
			R> DUP >R						\ and replaces it with the loop counter
		ELSE
			SWAP
		THEN
		R> 1 + 
		DUP
		#OPS >=
	UNTIL
	DROP NIP ;
		
: GET_DIGIT ( GPEDS0@ -- 0/1 )
	-1 0 										\ By default, if no digit matches, 
												\ an invalid code ( -1 ) is returned
	BEGIN
		DUP >R								\ Stores in the return stack a copy of the
												\ loop counter, the other one will be consumed
		DIGIT_KEYS SWAP GET MASK		\ Computes mask for digit_keys[loop_counter]
		ROT DUP 								\ Brings GPEDS0@ on top of the stack and makes
												\ a copy
		ROT AND 0 <>						\ Compares GPEDS0@ with the previously 
												\ computed mask
		IF 
			NIP								\ Removes the previous digit value
			R> DUP >R						\ and replaces it with the loop counter
		ELSE
			SWAP
		THEN
		R> 1 + 
		DUP
		#DIGITS >=
	UNTIL
	DROP NIP ;

: OP_KEYS_SETUP 
	0
	BEGIN
		DUP 1 + >R
		OP_KEYS SWAP GET 
		DUP
		INPUT ENABLE
		DOWN SET_PUD
		R> DUP 
		#OPS >=
	UNTIL
	DROP ;

: DIGIT_KEYS_SETUP 
	0
	BEGIN
		DUP 1 + >R
		DIGIT_KEYS SWAP GET 
		DUP
		INPUT ENABLE
		DOWN SET_PUD
		R> DUP 
		#DIGITS >=
	UNTIL
	DROP ;

: FALLING_EDGE_DETECT_SET
	DIGIT_MASK OP_MASK OR GPFEN0 ! ;

: INPUT_SETUP 
	OP_KEYS_SETUP
	DIGIT_KEYS_SETUP
	FALLING_EDGE_DETECT_SET ;

INPUT_SETUP
