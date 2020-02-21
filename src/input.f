5 					CONSTANT #OPS
2 					CONSTANT #DIGITS
#OPS #DIGITS + CONSTANT #KEYS

CREATE KEYS	5 , 6 , 13 , 19 , 26 ,	\ Operations	( + - * / = )
				9 , 11 ,						\ Digits			( 0 1 )

: KEYS_MASK 
	0 0						\ 0-set mask and loop counter
	BEGIN
		DUP 1 + >R
		KEYS SWAP GET 		\ On each cycle gets the pin# of the 
								\ (loop number)th button
		MASK OR				\ Computes the mask for the current pin and adds it to 
								\ the mask computed so far
		R> DUP
		#KEYS >=
	UNTIL
	DROP NIP ;

: KEYS_MASK [ KEYS_MASK ] LITERAL ;

: GET_KEY ( GPEDS0@ -- KEY_NUM )
	-1 0 								\ By default, if no digit matches, 
										\ an invalid code ( -1 ) is returned
	BEGIN
		DUP >R						\ Stores in the return stack a copy of the
										\ loop counter, the other one will be consumed
		KEYS SWAP GET MASK		\ Computes mask for digit_keys[loop_counter]
		ROT DUP 						\ Brings GPEDS0@ on top of the stack and makes
										\ a copy
		ROT AND 0 <>				\ Compares GPEDS0@ with the previously 
										\ computed mask
		IF 
			NIP R@					\ Removes the previous digit value
										\ and replaces it with the loop counter
		ELSE
			SWAP
		THEN
		R> 1 + 
		DUP
		#KEYS >=
	UNTIL
	DROP NIP ;

: PEEK_KEYPRESS							
	KEYS_MASK 
	GPEDS0 @ AND 
	DUP 0 <>
	IF
		1 MILLISECONDS DELAY		\ Makes sure the button has properly been
		GPLEV0 @ INVERT AND 		\ released, else a keypress could be read twice 
	THEN
	DUP 0 <>
	IF
		GET_KEY 
	ELSE								\ Returns an invalid code without having to go
		DROP	-1						\ through GET_KEY for faster execution.
	THEN ;						

: CLEAR_KEYPRESS
	KEYS_MASK GPEDS0 ! ;			\ Only clears event related to the input pins

: ?VALID	( KEY_NUM -- T/F )	\ Returns true if KEY_NUM is in the
	DUP 0 >=							\ allowed range.
	SWAP #KEYS <  AND ;

: ?DIGIT ( KEY_NUM -- T/F )
	#OPS >=  ;
: ?OPERATION ( KEY_NUM -- T/F )
	#OPS < ;

: READ_KEYPRESS
	PEEK_KEYPRESS
	DUP ?VALID
	IF
		1 MILLISECONDS DELAY		\ Debouncing, delay found by trial and error
		CLEAR_KEYPRESS 
	THEN ;

\ The following two words will ALWAYS leave on the stack a valid value to be used
\ for following operations, even with malformed input, so proper care should be
\ taken to validate the input before calling these routines

: KEY>OPERATION ( KEY_NUM -- Operation_number )
	#OPS MOD ;

: KEY>DIGIT ( KEY_NUM -- Digit )
	#OPS - #DIGITS MOD ;

: KEYS_SETUP 
	0
	BEGIN
		DUP 1 + >R				\ Puts on the return stack an incrememtned copy of the
									\ loop counter
		KEYS SWAP GET DUP		\ Puts on the stack twice the pin number for this 
									\ iteration 
		INPUT SET_FUNC			\ Sets the pin as in input
		DOWN SET_PUD			\ Sets the pull for the pin
		R> DUP 
		#KEYS >=
	UNTIL
	DROP ;

: FALLING_EDGE_DETECT_SET
	GPFEN0 @ KEYS_MASK OR  GPFEN0 ! ;

: INPUT_SETUP 
	KEYS_SETUP
	FALLING_EDGE_DETECT_SET 
	CLEAR_KEYPRESS ;
