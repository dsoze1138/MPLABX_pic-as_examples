;
; File:     main.S
; Target:   PIC16F505
; Author:   dan1138
; Date:     2024-12-13
; Compiler: pic-as(v2.46)
; IDE:      MPLABX v6.20
;
; Description:
;
;   Example project for the PIC16F505 controller wake from sleep on change of RB0,1,3,4.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=03ffh
;
;                           PIC16F505
;                   +----------:_:----------+
;             ->  1 : VDD               Vss : 14 <- 5v0
;             <>  2 : RB5/OSC1      PGD/RB0 : 13 <> ICSP_PGD
;        WAKE ->  3 : RB4/OSC2      PGC/RB1 : 12 <> ICSP_PGC
;    ICSP_VPP ->  4 : RB3/MCLR          RB2 : 11 -> LED
;             <>  5 : RC5/T0CKI         RC0 : 10 <> 
;             <>  6 : RC4               RC1 : 9  <> 
;             <>  7 : RC3               RC2 : 8  <> 
;                   +-----------------------:
;                            DIP-14

    PROCESSOR   16F505
    PAGEWIDTH   132
    RADIX       DEC

; Define system oscillator frequency this code will setup
#define _XTAL_FREQ 4000000

#include <xc.inc>

; PIC16F505 Configuration Bit Settings
  CONFIG  OSC = IntRC_RB4EN     ; Oscillator Selection bits (Internal RC oscillator/RB4 function on RB4/OSC2/CLKOUT pin)
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Code protection off)
  CONFIG  MCLRE = OFF           ; RB3/MCLR Pin Function Select bit (GP3/MCLR pin function is digital input, MCLR internally tied to VDD)


  skipnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
  ENDM

  skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
  ENDM
;
; Power-On-Reset wrap around entry point
;
    PSECT   StartCode,global,class=CODE,delta=2
StartCode:
    movwf   OSCCAL
    movlw   PORTB_RB2_MASK
    btfsc   STATUS,STATUS_RBWUF_POSITION
    xorwf   RB2_State,F         ; Wake from change on PORTB
    PAGESEL main                ;jump to the main routine
    goto    main
;
; Declare bytes in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  RB2_State
RB2_State:   DS  1

;
; main application
    PSECT   MainCode,global,class=CODE,delta=2
main:
    movlw   (PORTB_RB4_MASK | PORTB_RB3_MASK | PORTB_RB1_MASK | PORTB_RB0_MASK)
    TRIS    PORTB               ; Set RB4,RB3,RB1,RB0 as input
    movlw   0x1F
    OPTION                      ; Enable wake from speel, enable PORTB weak pull-ups, TIMER0 clock is FOSC/4
    clrf    PORTB
    bsf     PORTB,2
    bcf     PORTB,2
    movf    PORTB,W
    clrwdt
;
; applicaiton process loop
loop:
    movf    PORTB,W
    xorwf   RB2_State,W
    andlw   PORTB_RB2_MASK
    xorwf   PORTB,F    
    movf    PORTB,W
    sleep
    nop
    goto    loop                ;read again
;
; The PIC16F505 reset vector is the highest 
; instruction word in the code space.
;
; This is used to load the WREG with the factory 
; oscillator calibration value then  the program 
; counter rollover to zero to start the code.
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVec
ResetVec:
    END     ResetVec