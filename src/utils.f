HEX
FE000000				 	CONSTANT PERI_BASE
1	 						CONSTANT OUTPUT
0							CONSTANT INPUT
2							CONSTANT	DOWN
1							CONSTANT UP
PERI_BASE 200000 + 	CONSTANT GPIO_BASE
GPIO_BASE 1C +     	CONSTANT GPSET0
GPIO_BASE 28 +     	CONSTANT GPCLR0
GPIO_BASE 34 +			CONSTANT GPLEV0
GPIO_BASE 40 +			CONSTANT GPEDS0
GPIO_BASE 58 +			CONSTANT GPFEN0
GPIO_BASE 94 +			CONSTANT GPPUD				\ For Pi3 and preceding
GPIO_BASE 98 +			CONSTANT GPPUDCLK0		\ For Pi3 and preceding
GPIO_BASE E4 +			CONSTANT	GPPUPDN0
PERI_BASE 3000 +	 	CONSTANT TIMER_BASE
TIMER_BASE 4 +			CONSTANT TIMER_CNT

: ABS ( n -- |n| )
	DUP NEGATE DUP 0 > IF NIP ELSE DROP THEN ;

: R@
	R> R> DUP >R SWAP >R ;	\ The return stack will have an extra value due to 
									\ the call of R@

: GET ( array, cell -- array[cell] )
	CELLS + @ ;

: #MASK ( shift n -- mask )
	SWAP LSHIFT ;	

: MASK ( shift -- mask )
	1 #MASK ;

: ON  GPSET0 ! ;
: OFF GPCLR0 ! ;

DECIMAL

: MILLISECONDS 1000 * ;
: SECONDS 1000000 * ;
: CURRENT_TIME ( -- time )
	TIMER_CNT @ ;
: DELAY ( useconds -- )
	CURRENT_TIME
	BEGIN
		DUP CURRENT_TIME			( useconds start_time start_time current_time -- )
		- ABS							( useconds start_time elapsed_time -- )
		>R OVER R>	<=
	UNTIL
	DROP DROP ;

: 150_OPS_DELAY
   0
   BEGIN
      1 + DUP
      150 >=
   UNTIL
   DROP ;

: SET_PUD_PI3						\ ONLY VALID FOR PI3 and preceding	( GPPUDCLK0_MASK, UP/DOWN -- )
	3 XOR								\ In the PI 4 the value for up and down are switched
	GPPUD !
	150_OPS_DELAY
	DUP INVERT SWAP
	GPPUDCLK0 @ OR GPPUDCLK0 !
	150_OPS_DELAY
	0 GPPUD !
	GPPUDCLK0 @ AND GPPUDCLK0 ! ;

: REBASE ( ADDRESS FIELD# FIELD_SIZE -- ADDRESS+OFFSET FIELD_MOD_SIZE )
\ Given the base address for a set of GPIO registers, the field that
\ needs to be accessed, and the field size, this function will 
\ Return the register that contains the required field, and the position
\ of the field relative to this register instead of the absolute one.
	32 SWAP /				\ Computes how many fields fit into a register
	/MOD 4 *					\ Computes which register contains data pertaining to the
								\ selected field
	ROT + SWAP ;			\ Adds the offset to the base address

: WHITEN ( ADDRESS STARTING_POINT NUM_BITS -- whitened address content )
	MASK 1 -					\ Sets NUM_BITS bits to 1
	#MASK INVERT			\ Shifts those bits, by inverting this mask every other bit
								\ but those are now 1
	SWAP @ AND ;			\ Performs a logic AND between the current content of the
								\ register and the computed mask
	

: SET_REGISTER ( field_num value register field_size -- )
\ When setting the content of a GPIO related register proper care must be taken
\ to avoid modifying bits related to pins wich one isn't trying to modify, hence
\ masking procedures are performed.
\ Following a philosophy of word reusability, and to avoid a "call by text editor", 
\ a single general-purpose word is defined to work with fields of any size,
\ Specfic words will be then written for each specific register for ease of use.
	>R						\ puts field_size on the return stack
	ROT					\ Puts field_num on top of the stack
	R@						\ put a copy of field_size back on the stack
	REBASE				\ now on stack: value, address, field_num
	R@ *					\ Converts field_num into a bit shift
	2DUP R> WHITEN		\ Now on stack: value, address, field_shift whitened_address_content
	>R ROT #MASK 		\ Moves whitened_address_content to the return stack to avoid complex
							\ stack manipulation, then shifts value by field_shift positions.
	R> OR					\ Performs a logic OR between the whitened_address_content and 
							\ the shifted value.
	SWAP ! ;

: SET_FUNC ( pin# func -- ) \ Calls SET_REGISTER with the parameters for GPFSEL
	GPIO_BASE 3 SET_REGISTER ;

: SET_PUD ( pin# up/down ) \ Calls SET_REGISTER with the parameters for GPPUPDN
	GPPUPDN0 2 SET_REGISTER ;
