;
; File:     main.S
; Target:   PIC16F1704
; Author:   dan1138
; Date:     2021-12-27
; Compiler: MPASMWIN(v5.87)
; IDE:      MPLABX v5.35
;
; 
;                            PIC16F1704
;                   +------------:_:------------+
;         5v0 ->  1 : VDD                   VSS : 14 <- GND
;             <>  2 : RA5           PGD/AN0/RA0 : 13 <> PGS
;             <>  3 : RA4/AN3       PGC/AN1/RA1 : 12 <> PGC
;         VPP ->  4 : RA3/MCLRn     ZCD/AN2/RA2 : 11 <>
;             <>  5 : RC5               AN4/RC0 : 10 <>
;             <>  6 : RC4               AN5/RC1 :  9 <>
;             <>  7 : RC3/AN7           AN6/RC2 :  8 <>
;                   +---------------------------:
;                              DIP-14
; Description:
;   This is an example of a MPASMWIN(v5.87) assembly language application.
;
;   What this appication does is trivial as it will toggle the RA2 pin 
;   output high then low with a period of about 1551 instruction cycles.
;
;   The whole point of this example is to show how to setup an assembly 
;   language project using MPLABX v5.35 and the MPASMWIN(v5.87) tool chain.
;
;
    PROCESSOR   16F1704
    LIST        n=0,c=132
    RADIX       DEC
    ERRORLEVEL -302         ; Suppress the not in bank 0 warning
;
; Define how this code will setup the system oscillator frequency
;
#define _XTAL_FREQ (8000000)
#define FCY (_XTAL_FREQ/4)
;
; Include device specific register definitions
;
#include <p16f1704.inc>
;
; CONFIG1
; __config 0x39E4
 __CONFIG _CONFIG1, 0x3FFF & _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0x3EFB
 __CONFIG _CONFIG2, 0x3FFF & _WRT_OFF & _PPS1WAY_OFF & _ZCDDIS_ON & _PLLEN_OFF & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

;
; Skip macros
;
skipnc  MACRO
    btfsc   STATUS,C
  ENDM

skipc  MACRO
    btfss   STATUS,C
  ENDM

skipnz  MACRO
    btfsc   STATUS,Z
  ENDM

skipz  MACRO
    btfss   STATUS,Z
  ENDM
;
; Power-On-Reset entry point
;
Por_Vec CODE    0x0000
    global  resetVec
resetVec:
    PAGESEL Start
    goto    Start
;
;   Interrupt vector and handler
Isr_Vec CODE    0x0004
    GLOBAL  IsrHandler
;
IsrHandler:
;
IsrExit:
    retfie                      ; Return from interrupt
;
; Initialize the PIC hardware
;
Start:
    clrf    INTCON              ; Disable all interrupt sources
    banksel PIE1
    clrf    PIE1
    clrf    PIE2
    clrf    PIE3

    banksel OSCCON
    movlw   0x70                ; Set system oscillator to internal at 8MHz
    movwf   OSCCON

    ; Make PORTA and PORTC inputs
    banksel TRISA
    movlw   b'11111111'         ;
    movwf   TRISA
    movwf   TRISC

    ; Set all ADC inputs for digital I/O
    banksel ANSELA
    movlw   b'00000000'
    movwf   ANSELA
    movwf   ANSELC

    pagesel main
    goto    main
;
; Main application data
;
MainData UDATA
    global  count
count:  RES     1               ;reserve 1 byte for main application to count in
;
; Main application code
;
MainCode    CODE
;
; Function to count 256
;
Count256:
    BANKSEL count
    clrf    count
Count256Loop:
    decfsz  count,F
    goto    Count256Loop
    return
;
; Set PORTA bit 2 as an output then set low 
; spin loop for count of 256 then set high 
; and spin loop for count of 256 then loop.
;
main:
    BANKSEL TRISA
    bcf     TRISA,TRISA2   ; Make PORTA bit RA2 an output
loop:
    BANKSEL PORTA
    bcf     PORTA,RA2      ; Make PORTA bit RA2 LOW
    call    Count256
    BANKSEL PORTA
    bsf     PORTA,RA2      ; Make PORTA bit RA2 HIGH
    call    Count256
    goto    loop
;
; 
;
    END