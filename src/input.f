5 CONSTANT #OPS
2 CONSTANT #DIGITS
CREATE OP_KEYS 5 , 6 , 13 , 19 , 26 ,
CREATE DIGIT_KEYS 9 , 11 ,


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

OP_KEYS_SETUP
DIGIT_KEYS_SETUP

