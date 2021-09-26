; Date: 2021-SEPTEMBER-25
; File: main.c 
; Target: PIC16F1507
; MPLABX: v5.50
; Compiler: pic-as(v2.32)
;  
; Description:
;
;   Test macros for OPTION and TRIS opcodes.
;  
;                      PIC16F1507
;              +----------:_:----------+
;    PWR ->  1 : VDD               VSS : 20 <- GND
;        <>  2 : RA5/T1CKI PGD/AN0/RA0 : 19 <> PGD
;        <>  3 : RA4/AN3   PGC/AN1/RA1 : 18 <> PGC
;    VPP ->  4 : RA3/VPP       AN2/RA2 : 17 <> 
;        <>  5 : RC5/CWG1A     AN4/RC0 : 16 <> 
;        <>  6 : RC4/CWG1B     AN5/RC1 : 15 <> 
;        <>  7 : RC3/AN6       AN6/RC2 : 14 <> 
;        <>  8 : RC6/AN8      AN10/RB4 : 13 <>
;        <>  9 : RC7/AN9      AN11/RB5 : 12 <> 
;        <> 10 : RB7               RB6 : 11 <>
;              +-----------------------:
;                       DIP-20
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h
;
    PROCESSOR   16F1507
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
; CONFIG1
  CONFIG  FOSC = INTOSC, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, BOREN = OFF, CLKOUTEN = OFF

; CONFIG2
  CONFIG  WRT = OFF, STVREN = ON, BORV = LO, LPBOR = OFF, LVP = ON
;
; Macros for deprecated opcodes TRIS and OPTION
;
; Warning:  The MPLAB simulator does not support these opcodes for the PIC16F15xx controllers.
;           They do actually work in the PIC16F1503 controller tested.
;           Likely they work in all the controllers in the PIC16F15xx family
;           but you should verify this for your specific target.
;
_tris MACRO PORT
  if ((PORT >= 0x0C) AND (PORT <= 0x0E))
    dw  ((PORT-7)+0x0060)
  endif
    ENDM

_option MACRO PORT
    dw  (0x0062)
    ENDM
;
; Reset vector
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    goto    Start
;
; Application start
;
    PSECT   code
Start:
    banksel OSCCON
    movlw   0x3a        ; System oscillator set to 500 KHz
    movwf   OSCCON

    movlw   0xD7        ; Set TIMER0 clock source to FOSC/4, TIMER0 overflows ever 524.288 milliseconds
    _option

    movlw   0xF0
    _tris   PORTC

    banksel ANSELC
    movwf   ANSELC
    banksel LATC
    movwf   LATC
    goto    AppLoop
;
; Application loop
;
AppLoop:
    banksel LATC
    movlw   1
    xorwf   LATC,F
    call    Delay
    goto    AppLoop     ;loop forever
;
; Spin wait
;
Delay:
    clrf    FSR0L
    clrf    FSR0H
    bsf     FSR0H,7
Delay_1:
    call    Delay_2
    incfsz  FSR0L,F
    goto    Delay_1
    incfsz  FSR0H,F
    goto    Delay_1
    return
Delay_2:
    btfss   INTCON,INTCON_TMR0IF_POSITION
    goto    Delay_3
    bcf     INTCON,INTCON_TMR0IF_POSITION
    movlw   2
    xorwf   LATC,F
    return
Delay_3:
    nop
    nop
    return
;
    end     ResetVector