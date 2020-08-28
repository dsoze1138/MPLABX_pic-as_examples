; 
; Code example from section 4.  A Basic Example For Mid-range Devices
;
; From document: http://ww1.microchip.com/downloads/en/DeviceDoc/XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;    -Wl,-DCODE=2,-presetVec=0h -Wa,-a -Wl,-Map=test.map 
;
    PROCESSOR 16F1937

#include <xc.inc>

;configuration word 1
 CONFIG FOSC=INTOSC         // Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
 CONFIG WDTE=OFF,PWRTE=OFF  // WDT & PWRT disabled
 CONFIG MCLRE=ON            // MCLR/VPP pin function is MCLR
 CONFIG CP=OFF,CPD=OFF      // Program & data memory unprotected
 CONFIG BOREN=ON            // Brown-out Reset enabled
 CONFIG CLKOUTEN=OFF        // CLKOUT function is disabled
 CONFIG IESO=ON             // Internal/External Switchover mode enabled
 CONFIG FCMEN=ON            // Fail-Safe Clock Monitor enabled
;configuration word 2
 CONFIG WRT=OFF             // Write protection off
 CONFIG VCAPEN=OFF          // All VCAP pin functionality disabled
 CONFIG PLLEN=ON            // 4x PLL enabled
 CONFIG STVREN=ON           // Stack Over/underflow will cause a Reset
 CONFIG BORV=LO             // Brown-out Reset Voltage low trip point
 CONFIG LVP=ON              // Low-voltage programming enabled

  skipnc  MACRO
    btfsc   STATUS,0
  ENDM

;objects in bank 0 memory
    PSECT   udata_bank0
max:
    DS      1                   ;reserve 1 byte for max
tmp:
    DS      1                   ;reserve 1 byte for tmp
    PSECT   resetVec,class=CODE,delta=2
resetVec:
    PAGESEL main                ;jump to the main routine
    goto    main

/* find the highest PORTA value read, storing this into the object max */
    PSECT   code
main:
    PAGESEL loop                ;ensure subsequent jumps are correct
    BANKSEL max                 ;starting point
    clrf    BANKMASK(max)
    BANKSEL ANSELA              ;write 0 to select digital input for port
    clrf    BANKMASK(ANSELA)
loop:
    BANKSEL PORTA               ;read and store port value
    movf    BANKMASK(PORTA),w
    BANKSEL tmp
    movwf   BANKMASK(tmp)
    subwf   max^(tmp&0ff80h),w  ;is this value larger than max?
    skipnc
    goto    loop                ;no - read again
    movf    BANKMASK(tmp),w     ;yes - record this new high value
    movwf   BANKMASK(max)
    goto    loop                ;read again
    END     resetVec 