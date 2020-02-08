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
GPIO_BASE 98 +			CONSTANT GPPUDCLK0			\ For Pi3 and preceding
GPIO_BASE E4 +			CONSTANT	GPPUPDN0
PERI_BASE 3000 +	 	CONSTANT TIMER_BASE
TIMER_BASE 4 +			CONSTANT TIMER_CNT

: ABS ( n -- |n| )
	DUP NEGATE DUP 0 > IF NIP ELSE DROP THEN ;

: MASK ( position n -- mask )
	SWAP LSHIFT ;
: ON  1 MASK GPSET0 ! ;
: OFF 1 MASK GPCLR0 ! ;
: ENABLE ( pin# func -- )
	>R 								\ puts the function# on the return stack for ease of handling
	A /MOD 							( pin# -- 3bitset# gpfsel# )
	SWAP >R
	4 * GPIO_BASE + DUP @ 		\ gets the current content of gpfsel
	R> 3 * DUP 						\ masking offset
	7 MASK INVERT ROT AND 		\ sets to zero the bits linked to the pin
	SWAP R> MASK OR 				\ sets the bits linked to the pin to func
	SWAP ! ; 						\ writes the new value into gpfsel

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


: GET ( array, cell -- array[cell] )
	CELLS + @ ;

: 150_OPS_DELAY
   0
   BEGIN
      1 + DUP
      150 >=
   UNTIL
   DROP ;

: SET_PUD_PI3						\ ONLY VALID FOR PI3 and preceding	( GPPUDCLK0_MASK, UP/DOWN -- )
	GPPUD !
	150_OPS_DELAY
	DUP INVERT SWAP
	GPPUDCLK0 @ OR GPPUDCLK0 !
	150_OPS_DELAY
	0 GPPUD !
	GPPUDCLK0 @ AND GPPUDCLK0 ! ;

: SET_PUD				\ ( GPIO# UP/DOWN -- )
	>R
	DUP 4 RSHIFT 4 * 	\ Computes which of the three registers contains data
							\ pertaining to the selected GPIO pin
	GPPUPDN0 +			\ Correct GPPUPDN register for the selected pin
	>R
	2 *					\ shift for masking
	DUP
	3 MASK INVERT		\ Mask to clear bits
	R> DUP >R			\ Brings a copy of the GPPUPDN register on the stack
	@ AND					\ Zeroes the bits corresponding to the selected GPIO
	SWAP R> SWAP R> 	\	( Whitened GPPUPDN@, GPPUPDN#, shift, UP/DOWN )
	MASK					\ Computes the bit relative to the selected GPIO
	ROT
	OR						\ OR them to the whitened content of GPPUPDN
	SWAP ! ;
	
	

