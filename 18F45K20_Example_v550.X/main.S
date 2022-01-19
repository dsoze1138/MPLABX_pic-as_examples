; 
; This is an example of how the PIC-AS(v2.35) assembler does C preprocessor macro
; processing in a comment line and put the mangled output in the list file.
;
; The shows that adding a double quote character after the semicolon in a comment 
; is a hack around to prevent this.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-Map=main.map -Wl,-presetVec=0h
;
    PROCESSOR 18F45K20

#include <xc.inc>

  CONFIG  FOSC = INTIO67, FCMEN = OFF, IESO = OFF, PWRT = OFF
  CONFIG  BOREN = SBORDIS, BORV = 18, WDTEN = OFF, WDTPS = 32768
  CONFIG  CCP2MX = PORTC, PBADEN = ON, LPT1OSC = OFF, HFOFST = ON
  CONFIG  MCLRE = ON, STVREN = ON, LVP = ON, XINST = OFF
  CONFIG  CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
  CONFIG  CPB = OFF, CPD = OFF
  CONFIG  WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
  CONFIG  WRTC = OFF, WRTB = OFF, WRTD = OFF
  CONFIG  EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
  CONFIG  EBTRB = OFF

;objects in common (Access bank) memory 

    PSECT   udata_acs
    global  max
    global  tmp
max:
    DS      1       ;reserve 1 byte for max
tmp:
    DS      1       ;1 byte for tmp

;this must be linked to the reset vector

    PSECT   resetVec,class=CODE,reloc=2
resetVec:
    goto    main

/* find the highest PORTA value read, storing this into the object max */

    PSECT   code
main:
; CLEAR GIE AND ALL OTHER INTERRUPT ENABLES
;"CLEAR GIE AND ALL OTHER INTERRUPT ENABLES
    bcf     GIE
    bcf     PEIE
    bcf     TMR0IE
    bcf     INT0IE
    bcf     RBIE
    clrf    PIE1,c
    clrf    PIE2,c
    clrf    ANSEL,c     ;write 0 to select digital I/O for GPIO pins
    clrf    ANSELH,c

    clrf    max,c
    
loop:
    movff   PORTA,tmp   ;read and store the port value
    movf    tmp,w,c     ;is this value larger than max?
    subwf   max,w,c
    bc      loop        ;no - read again
    movff   tmp,max     ;yes - record this new high value
    goto    loop        ;read again
    END     resetVec
