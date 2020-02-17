8 CONSTANT DISPLAY_SIZE
CREATE DISPLAY 21 , 20 , 16 , 12 , 7 , 8 , 25 , 24 ,
23 CONSTANT OVERFLOW
18 CONSTANT NEGATIVE

: LSB_MASK 				( shift n -- n/2 mask )
	DISPLAY ROT GET	\ Puts on the stack the GPIO pin that shows the next bit
	MASK SWAP			\ Computes the mask for that pin
	2 /MOD SWAP ROT	( mask n -- n/2 LSB mask )
							\ Divides n by two to prepare for the next iteration, this
	* ;					\ Multiplies the mask by the least significant bit of the
							\ number, so if the bit is 1 the mask is placed on the stack
							\ if it is 0, 0 is put, so no pin will be set to high.
							\ A multiplication is used in place of an IF statement
							\ because, with the Booth multiplication algorithm usually
							\ used in the ARM architecture this multipication is really
							\ efficient, while the branching would waste many CPU cycles

: DISPLAY_MASK ( n -- mask )
	0 0 					\ adds an empy mask and a loop counter to the stack
	BEGIN
		DUP 1 + >R
		ROT LSB_MASK	( n mask loop_counter -- mask n/2 n_mask )
		ROT OR 			\ adds the newly computed mask to the previous result
		R> DUP
		DISPLAY_SIZE >=
	UNTIL
	DROP NIP ;			

: CLEAR ( -- )
	[ DISPLAY_SIZE MASK 1 - DISPLAY_MASK ] LITERAL 	\ mask with every display bit set to 1
	OFF	
	OVERFLOW MASK OFF
	NEGATIVE MASK OFF ;

: SHOW ( status n -- )  
	CLEAR 
	DISPLAY_MASK ON 
	OVERFLOW OVER 1 AND #MASK ON
	NEGATIVE SWAP 2 / 1 AND #MASK ON ;

: DISPLAY_SETUP 
	0
	BEGIN
		DUP 1 + >R
		DISPLAY SWAP GET
		OUTPUT SET_FUNC
		R> DUP
		DISPLAY_SIZE >=
	UNTIL
	DROP 
	OVERFLOW OUTPUT SET_FUNC
	NEGATIVE OUTPUT SET_FUNC
	CLEAR	
;

DISPLAY_SETUP
