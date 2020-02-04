5 CONSTANT #OPS
2 CONSTANT #DIGITS
CREATE OP_KEYS 5 , 6 , 13 , 19 , 26 ,
CREATE DIGIT_KEYS 9 , 11 ,

: OP_MASK 
	0 0
	BEGIN
		DUP 1 + >R
		1 OP_KEYS ROT GET LSHIFT OR
		R> DUP
		#OPS >=
	UNTIL
	DROP NIP ;

OP_MASK CONSTANT OP_MASK

: DIGIT_MASK 
	0 0
	BEGIN
		DUP 1 + >R
		1 DIGIT_KEYS ROT GET LSHIFT OR
		R> DUP
		#DIGITS >=
	UNTIL
	DROP NIP ;

DIGIT_MASK CONSTANT DIGIT_MASK

: PEEK_KEYPRESS
	[ OP_MASK DIGIT_MASK OR ] LITERAL
	GPEDS0 @ AND ;

: CLEAR_KEYPRESS
	[ OP_MASK DIGIT_MASK OR ] LITERAL
	GPEDS0 ! ;

: READ_KEYPRESS
	PEEK_KEYPRESS
	CLEAR_KEYPRESS ;

: ?DIGIT ( GPEDS0@ -- T/F )
	DIGIT_MASK AND 0 <>  ;

: READ_OP ( GPEDS0@ -- operation )
	-1 0 										\ by default, if no op matches, 
												\ an invalid code ( -1 ) is returned
	BEGIN
		DUP >R								\ stores in the return stack a copy of the
												\ loop counter, the other one will be consumed
		1 OP_KEYS ROT GET LSHIFT		( GPEDS0 selected_op tentative_op_mask )
		ROT DUP ROT AND					( selected_op GPEDS0 T/F )
		IF 
			DROP
			R> DUP >R
			NIP
		THEN
		R> 1 + 
		DUP
		#OPS >=
	UNTIL
	DROP ;
		
: GET_DIGIT ( GPEDS0@ -- 0/1 )
	DUP
	DIGIT_KEYS 0 GET 1 MASK 
	AND
	IF
		DROP 0
	ELSE
		DIGIT_KEYS 1 GET 1 MASK	AND
		IF
			1
		THEN
	THEN  ;

: OP_KEYS_SETUP 
        0
        BEGIN
                DUP 1 + >R
                OP_KEYS SWAP GET 
                INPUT ENABLE
                R> DUP 
                #OPS >=
        UNTIL
        DROP 
;

: DIGIT_KEYS_SETUP 
        0
        BEGIN
                DUP 1 + >R
                DIGIT_KEYS SWAP GET 
                INPUT ENABLE
                R> DUP 
                #DIGITS >=
        UNTIL
        DROP 
;

: 150_OPS_DELAY 
	0
	BEGIN
		1 + DUP
		150 >=
	UNTIL
	DROP ;

: SET_PULLDOWN
	1 GPPUD !
	150_OPS_DELAY
	DIGIT_MASK OP_MASK OR DUP INVERT SWAP
	GPPUDCLK0 @ OR GPPUDCLK0 !
	150_OPS_DELAY
	0 GPPUD !
	GPPUDCLK0 @ AND GPPUDCLK0 ! ;
	
: FALLING_EDGE_DETECT_SET
	DIGIT_MASK OP_MASK OR GPFEN0 ! ;

: INPUT_SETUP 
	 OP_KEYS_SETUP
	 DIGIT_KEYS_SETUP
	 SET_PULLDOWN
	 FALLING_EDGE_DETECT_SET ;

INPUT_SETUP
