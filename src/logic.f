8 CONSTANT WORD_SIZE 

VARIABLE CURRENT_VALUE
VARIABLE LAST_VALUE
VARIABLE STATUS
VARIABLE OPERATION

: ADDITION  + ;
: SUBTRACTION  - ;
: MULTIPLICATION  * ;
: DIVISION 			\ There's an additional check for division by zero and negative
						\ values as the FORTH implementation does not behave 
						\ appropriately for the intended use
	DUP 0 <> 
	IF
		OVER OVER	\ Makes a copy of the two operands
		XOR 0 >=		\ Checks if the two operands have a different sign
						\ If they differ the MSB of their XOR will be 1 and the 
						\ resulting value will be interpreted as a negative number
		IF
			1
		ELSE
			-1
		THEN
			ROT ABS ROT ABS /			 	\ Performs division on the absolute values
			*									\ Adjusts for sign
	ELSE
		DROP DROP [ 31 MASK 1 - ] LITERAL \ Highest positive 32 bit number
	THEN ;

: EQUALS ;	\ Does nothing, this operation is intended to never be executed and 
				\ only stands as a flag for wich another module has to take
				\ action appropriately


CREATE OP_SET ' ADDITION , ' SUBTRACTION , ' MULTIPLICATION , ' DIVISION , ' EQUALS ,

: CHECK_OVERFLOW 
	STATUS @ SWAP
	DUP
	[ WORD_SIZE 1 - MASK 1 - ] LITERAL >	\ Upper bound of interval
	SWAP
	[ WORD_SIZE 1 - MASK NEGATE ] LITERAL <	\ Lower bound of interval
	OR
	IF 
		1 OR  
	ELSE
		[ 1 INVERT ] LITERAL AND
	THEN 	
	STATUS ! ;

: CHECK_NEGATIVE 
	STATUS @ SWAP
	0 < 
	IF
		2 OR
	ELSE
		[ 2 INVERT ] LITERAL AND
	THEN
	STATUS ! ;

: TRUNCATE 				\ Sets to zero the bits outside the representable range
	[ WORD_SIZE MASK 1 - ] LITERAL AND ;

: EXTEND_SIGN 
	TRUNCATE
	[ WORD_SIZE 1 - MASK ] LITERAL 	
	DUP ROT 
	XOR SWAP 									\ Complements the (WORD_SIZE)th bit 
													\ of the input value 
	- 												\ If the input value was positive it resets
													\ the (WORD_SIZE)th bit to zero, else 
													\ the subtraction sets it back to 1 and
													\ also the following bits by borrowing
	DUP CHECK_NEGATIVE ;

: STORE_VALUE EXTEND_SIGN CURRENT_VALUE ! ;

: COMPUTE_RESULT 
	LAST_VALUE @ CURRENT_VALUE @ OPERATION @ EXECUTE 
	DUP CHECK_OVERFLOW STORE_VALUE ;

: RESULT
	STATUS @
	CURRENT_VALUE @ ;

: PREPARE_NEXT 
	CURRENT_VALUE @ LAST_VALUE ! ;

: CLEAR_OPERATION
	0 OPERATION ! ;

: LOGIC_SETUP
	0 CURRENT_VALUE !
	0 LAST_VALUE !
	0 STATUS ! 
	' ADDITION OPERATION ! ;
