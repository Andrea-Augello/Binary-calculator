8 CONSTANT DISPLAY_SIZE
CREATE DISPLAY 21 , 20 , 16 , 12 , 7 , 8 , 25 , 24 ,
23 CONSTANT OVERFLOW
18 CONSTANT NEGATIVE

: LSB_MASK 				( shift n -- n/2 mask )
	2 /MOD SWAP	ROT	( shift n -- n/2 LSB shift )
	DISPLAY SWAP GET  ( n/2 LSB shift -- n/2 LSB display[shift] )
	LSHIFT ;
	
: DISPLAY_MASK ( n -- mask ) 
	0 0 			( n -- n mask loop_counter )
	BEGIN
		DUP 1 + >R
		ROT LSB_MASK	( n mask loop_counter -- mask n/2 n_mask )
		ROT OR 			\ adds the newly computed mask to the previous result
		R> DUP
		DISPLAY_SIZE <=
	UNTIL
	DROP NIP ;			

: CLEAR ( -- )
	 1 DISPLAY_SIZE LSHIFT 1 - DISPLAY_MASK  	\ mask with every display bit set to 1
	GPCLR0 ! 
	OVERFLOW OFF
	NEGATIVE OFF ;

: SHOW ( status n -- )  
	CLEAR 
	DISPLAY_MASK GPSET0 ! 
	DUP 1 AND OVERFLOW LSHIFT GPSET0 !
	2 AND NEGATIVE LSHIFT GPSET0 ! ;

: DISPLAY_SETUP 
	0
	BEGIN
		DUP 1 + >R
		DISPLAY SWAP GET
		OUTPUT ENABLE
		R> DUP
		DISPLAY_SIZE <=
	UNTIL
	DROP 
	CLEAR	
;

\ DISPLAY_SETUP
