HEX
FE000000 CONSTANT PERI_BASE
1	 CONSTANT OUTPUT
PERI_BASE 200000 + CONSTANT GPIO_BASE
GPIO_BASE 1C +     CONSTANT GPSET0
GPIO_BASE 28 +     CONSTANT GPCLR0

: PIN ;
: MASK ( position n -- mask )SWAP LSHIFT ;
: ON  1 MASK GPSET0 ! ;
: OFF 1 MASK GPCLR0 ! ;
: ENABLE ( pin# func -- )
	>R \ puts the function# on the return stack for ease of handling
	A /MOD ( pin# -- 3bitset# gpfsel# )
	SWAP >R
	4 * GPIO_BASE + DUP @ \ gets the current content of gpfsel
	R> 3 * DUP \ masking offset
	7 MASK INVERT ROT AND \ sets to zero the bits linked to the pin
	R> ROT LSHIFT OR \ sets the bits linked to the pin to func
	SWAP ! ; \ writes the new value into gpfsel


DECIMAL
