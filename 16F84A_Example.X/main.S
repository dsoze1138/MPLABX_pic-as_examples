;
; File:     main.S
; Target:   PIC16f84A
; Author:   dan1138
; Date:     2020-08-20
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC16F84A controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-pResetVec=0h,-pIsr_vec=4h
;
;                           PIC16F84A
;                   +----------:_:----------+
;             <>  1 : RA2               RA1 : 18 <> 
;             <>  2 : RA3               RA0 : 17 <> 
;             <>  3 : RA4/T0CKI        OSC1 : 16 <- 4MHz crystal
;    ICSP_VPP ->  4 : MCLR             OSC2 : 15 -> 4MHz crystal     
;         GND ->  5 : GND               VDD : 14 <- 5v0
;             <>  6 : RB0/INT       PGD/RB7 : 13 <> ICSP_PGD
;             <>  7 : RB1           PGC/RB6 : 12 <> ICSP_PGC
;             <>  8 : RB2               RB5 : 11 <> 
;             <>  9 : RB3               RB4 : 10 <> 
;                   +-----------------------:
;                            DIP-18

    PROCESSOR   16F84A
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; PIC16F84A Configuration Bit Settings

 config FOSC = HS        ; Oscillator Selection bits (HS oscillator)
 config WDTE = OFF       ; Watchdog Timer (WDT disabled)
 config PWRTE = OFF      ; Power-up Timer Enable bit (Power-up Timer is disabled)
 config CP = OFF         ; Code Protection bit (Code protection disabled)

  skipnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
  ENDM

  skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
  ENDM

;objects in bank 0 memory
    PSECT   udata_bank0
max:
    DS      1                   ;reserve 1 byte for max
tmp:
    DS      1                   ;reserve 1 byte for tmp
;
; Power-On-Reset entry point
;
    PSECT   ResetVec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL main                ;jump to the main routine
    goto    main

;
;   Data space use by interrupt handler to save context
    PSECT   Isr_data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
PCLATH_save:    DS  1
;
;   Interrupt vector and handler
    PSECT   Isr_vec,global,class=CODE,delta=2
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_save
    swapf   STATUS,W
    movwf   STATUS_save
    movf    PCLATH,W
    movwf   PCLATH_save
;
IsrHandler:
;
IsrExit:
    movf    PCLATH_save,W
    movwf   PCLATH
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,F
    retfie                      ; Return from interrupt
    

/* find the highest PORTB value read, storing this into the object max */
    PSECT   code
main:
    BANKSEL TRISB               ;starting point
    movlw   0xFF
    movwf   BANKMASK(TRISB)     ;
    BANKSEL max
    clrf    BANKMASK(max)
loop:
    BANKSEL PORTB               ;read and store port value
    movf    BANKMASK(PORTB),w
    BANKSEL tmp
    movwf   BANKMASK(tmp)
    subwf   max^(tmp&0ff80h),w  ;is this value larger than max?
    skipnc
    goto    loop                ;no - read again
    movf    BANKMASK(tmp),w     ;yes - record this new high value
    movwf   BANKMASK(max)
    goto    loop                ;read again
    END     resetVec