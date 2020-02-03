






: JF-HERE   HERE ;
: JF-CREATE   CREATE ;
: JF-FIND   FIND ;
: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

: [']   ' LIT , ; IMMEDIATE
: '   JF-WORD JF-FIND >CFA ; 

: CELL+  4 + ;

: ALIGNED   3 + 3 INVERT AND ;
: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

: DOES>CUT   LATEST @ >CFA @ DUP JF-HERE @ > IF JF-HERE ! ; 

: CREATE   JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT)  ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ; 
: (DODOES-COMP)  (DODOES-INT) ['] LIT , , ['] FIP! , ; 
: DOES>COMP   ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT   (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES>   STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE


HEX
FE000000				 	CONSTANT PERI_BASE
1	 						CONSTANT OUTPUT
0							CONSTANT INPUT
PERI_BASE 200000 + 	CONSTANT GPIO_BASE
GPIO_BASE 1C +     	CONSTANT GPSET0
GPIO_BASE 28 +     	CONSTANT GPCLR0
GPIO_BASE 34 +			CONSTANT GPLEV0
GPIO_BASE 40 +			CONSTANT GPEDS0
GPIO_BASE 58 +			CONSTANT GPFEN0	
GPIO_BASE 94 +			CONSTANT GPPUD
GPIO_BASE 98 +			CONSTANT GPPUDCLK0
PERI_BASE 3000 +	 	CONSTANT TIMER_BASE
TIMER_BASE 4 +			CONSTANT TIMER_CNT

: ABS
	DUP NEGATE DUP 0 > IF NIP ELSE DROP THEN ;

: PIN ;
: MASK
	SWAP LSHIFT ;
: ON  1 MASK GPSET0 ! ;
: OFF 1 MASK GPCLR0 ! ;
: ENABLE
	>R 								
	A /MOD
	SWAP >R
	4 * GPIO_BASE + DUP @ 		
	R> 3 * DUP 						
	7 MASK INVERT ROT AND 		
	SWAP R> MASK OR 				
	SWAP ! ; 						

DECIMAL

: MILLISECONDS 1000 * ;
: SECONDS 1000000 * ;
: CURRENT_TIME
	TIMER_CNT @ ;
: DELAY
	CURRENT_TIME
	BEGIN
		DUP CURRENT_TIME
		- ABS
		>R OVER R>	<=
	UNTIL 
	DROP DROP ;


: GET
	CELLS + @ ;
8 CONSTANT WORD_SIZE 

VARIABLE CURRENT_VALUE
VARIABLE LAST_VALUE
VARIABLE STATUS
VARIABLE OPERATION

: ADDITION ['] + ;
: SUBTRACTION ['] - ;
: MULTIPLICATION ['] * ;
: DIVISION ['] / ;
: EQUALS -1 ;

CREATE OP_SET ADDITION , SUBTRACTION , MULTIPLICATION , DIVISION , EQUALS ,


: ?OVERFLOW [ 1 WORD_SIZE  LSHIFT 1 - ] LITERAL > STATUS @ SWAP 
	IF 
		1 OR  
	ELSE
		[ 1 INVERT ] LITERAL AND
	THEN 
	STATUS ! ;
: ?NEGATIVE [ 1 31 LSHIFT ]  LITERAL AND 0 <> STATUS @ SWAP
	IF
		2 OR
	ELSE
		[ 2 INVERT ] LITERAL AND
	THEN
	STATUS ! ;

: TRUNCATE DUP ?OVERFLOW [ 1 WORD_SIZE LSHIFT 1 - ] LITERAL AND ;

: EXTEND_SIGN [ 1 WORD_SIZE 1 - LSHIFT ] LITERAL DUP ROT XOR SWAP - DUP ?NEGATIVE ;

: STORE_VALUE TRUNCATE EXTEND_SIGN CURRENT_VALUE ! ;

: COMPUTE_RESULT 
	LAST_VALUE @ CURRENT_VALUE @ OPERATION @ EXECUTE STORE_VALUE ;

: PREPARE_NEXT 
	CURRENT_VALUE @ LAST_VALUE ! ;



0 CURRENT_VALUE !
0 LAST_VALUE !
0 STATUS !
ADDITION OPERATION !
8 CONSTANT DISPLAY_SIZE
CREATE DISPLAY 21 , 20 , 16 , 12 , 7 , 8 , 25 , 24 ,
23 CONSTANT OVERFLOW
18 CONSTANT NEGATIVE

: LSB_MASK
	2 /MOD SWAP	ROT
	DISPLAY SWAP GET
	LSHIFT ;
	
: DISPLAY_MASK
	0 0 					
	BEGIN
		DUP 1 + >R
		ROT LSB_MASK
		ROT OR 			
		R> DUP
		DISPLAY_SIZE >=
	UNTIL
	DROP NIP ;			

: CLEAR
	[ 1 DISPLAY_SIZE LSHIFT 1 - DISPLAY_MASK ] LITERAL 	
	GPCLR0 ! 
	OVERFLOW OFF
	NEGATIVE OFF ;

: SHOW
	CLEAR 
	DISPLAY_MASK GPSET0 ! 
	DUP 1 AND OVERFLOW LSHIFT GPSET0 !
	2 / 1 AND NEGATIVE LSHIFT GPSET0 ! ;

: DISPLAY_SETUP 
	0
	BEGIN
		DUP 1 + >R
		DISPLAY SWAP GET
		OUTPUT ENABLE
		R> DUP
		DISPLAY_SIZE >=
	UNTIL
	DROP 
	OVERFLOW OUTPUT ENABLE
	NEGATIVE OUTPUT ENABLE
	CLEAR	
;

DISPLAY_SETUP
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

: ?DIGIT
	DIGIT_MASK AND 0 <>  ;

: READ_OP
	5 0 
	BEGIN
		DUP >R
		1 OP_KEYS ROT GET LSHIFT
		ROT DUP ROT AND
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
		
: GET_DIGIT
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
: DISPLAY_RESULT
	STATUS @
	CURRENT_VALUE @
	SHOW ;

: SET_OPERATION
	READ_OP OP_SET SWAP
	GET OPERATION ! ;

: APPEND
	1 LSHIFT + ;

: GET_NUMBER 				
								
	CLEAR
	0 CURRENT_VALUE !
	0
	BEGIN
		>R 
		PEEK_KEYPRESS DUP
		0 <> 					
		IF
			?DIGIT 
	 		IF 
		 		R> 1 + >R 
				READ_KEYPRESS
		 		GET_DIGIT CURRENT_VALUE @ APPEND 
		 		STORE_VALUE
				DISPLAY_RESULT
	 		ELSE 
				R> DROP WORD_SIZE >R 	
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
		0 <> OVER ?DIGIT INVERT AND	
		IF
			SET_OPERATION
			1									
		ELSE
			DROP								
			0									
		THEN
		100 MILLISECONDS DELAY 
	UNTIL ;

: MAIN_LOOP 
	BEGIN 
	
		GET_NUMBER 
		OPERATION @ 0 <> 					
		IF
 			COMPUTE_RESULT
			0 OPERATION !
		ELSE
		THEN	
			GET_OPERATION

		OPERATION @ EQUALS =
		IF
			DISPLAY_RESULT
			0 OPERATION !
			BEGIN
				PEEK_KEYPRESS				
			UNTIL
		ELSE
		THEN
			PREPARE_NEXT


	0 UNTIL ;


