;
; File:     main.S
; Target:   PIC16F1704
; Author:   dan1138
; Date:     2021-12-27
; Compiler: pic-as(v2.32)
; IDE:      MPLABX v5.50
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
;   This is an example of a pic-as(v2.32) assembly language application.
;
;   What this appication does is trivial as it will toggle the RA2 pin 
;   output high then low with a period of about 1551 instruction cycles.
;
;   The whole point of this example is to show how to setup an assembly 
;   language project using MPLABX v5.50 and the pic-as(v2.32) tool chain.
;
; Notes:
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;    -Wl,-DCODE=2 -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
    PROCESSOR 16F1704
    PAGEWIDTH   132
    RADIX       DEC
;
; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection Bits (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable (Brown-out Reset enabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
  CONFIG  IESO = ON             ; Internal/External Switchover Mode (Internal/External Switchover Mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  PPS1WAY = OFF         ; Peripheral Pin Select one-way control (The PPSLOCK bit can be set and cleared repeatedly by software)
  CONFIG  ZCDDIS = ON           ; Zero-cross detect disable (Zero-cross detect circuit is disabled at POR)
  CONFIG  PLLEN = OFF           ; Phase Lock Loop enable (4x PLL is enabled when software sets the SPLLEN bit)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LPBOR = OFF           ; Low-Power Brown Out Reset (Low-Power BOR is disabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable (Low-voltage programming enabled)
;
; Define how this code will setup the system oscillator frequency
;
#define _XTAL_FREQ (8000000)
#define FCY (_XTAL_FREQ/4)
;
; Include device specific register definitions
;
#include <xc.inc>
;
; Skip macros
;
skipnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
  ENDM

skipc  MACRO
    btfss   STATUS,STATUS_C_POSITION
  ENDM

skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
  ENDM

skipz  MACRO
    btfss   STATUS,STATUS_Z_POSITION
  ENDM
;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL Start
    goto    Start
;
;   Interrupt vector and handler
    PSECT   Isr_Vec,global,class=CODE,delta=2
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
    movlw   0b11111111          ;
    movwf   TRISA
    movwf   TRISC

    ; Set all ADC inputs for digital I/O
    banksel ANSELA
    movlw   0b00000000
    movwf   ANSELA
    movwf   ANSELC

    pagesel main
    goto    main
;
; Main application data
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  count
count:  DS      1               ;reserve 1 byte for main application to count in
;
; Main application code
;
    PSECT   MainCode,global,class=CODE,delta=2
;
; Function to count 256
;
Count256:
    BANKSEL count
    clrf    BANKMASK(count)
Count256Loop:
    decfsz  BANKMASK(count),F
    goto    Count256Loop
    return
;
; Set PORTA bit 2 as an output then set low 
; spin loop for count of 256 then set high 
; and spin loop for count of 256 then loop.
;
main:
    BANKSEL TRISA
    bcf     BANKMASK(TRISA),TRISA_TRISA2_POSITION   ; Make PORTA bit RA2 an output
loop:
    BANKSEL PORTA
    bcf     BANKMASK(PORTA),PORTA_RA2_POSITION      ; Make PORTA bit RA2 LOW
    call    Count256
    BANKSEL PORTA
    bsf     BANKMASK(PORTA),PORTA_RA2_POSITION      ; Make PORTA bit RA2 HIGH
    call    Count256
    goto    loop
;
; Declare Power-On-Reset entry point
;
    END     resetVec