; Move loader to a safe location
LD DE, $0B   ; the offset of the block to be moved
             ; relatively to the address after CALL minus 1
INC E        ; add 1 to reset the Z flag
CALL $1FC6   ; this is essentially LD HL, PC
ADD HL, DE   ; now HL points to the begginning of the loader
LD DE, $F800 ; destination
LD BC, $002C ; the size of the remaining part after JP
LDIR
JP $F800

; Load the image
LD DE, ($5CF4)   ; restore the FDD head position
LD BC, $0905     ; load 9 sectors of compressed image
LD HL, $8000     ; destination address (32768)
CALL $3D13       ;
CALL $8000       ; decompress the image

; Load the data
LD DE, ($5CF4)   ; restore the FDD head position again
LD BC, $2505     ; load 37 sectors of the data
LD HL, $6000     ; destination address (24576)
CALL $3D13       ;

; Move the data back to where it's supposed to be
LD HL, $6000   ; this is where we loaded the data
LD DE, $5B00   ; this is where it's supposed to be
LD BC, $2500   ; the size of the data
LDIR           ;

; Call the entry point via the stack pointer same as
; the original loader does
LD SP, $5D7C
RET
