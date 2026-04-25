;
; File:     main.S
; Target:   PIC16F1579
; Author:   dan1138
; Date:     2026-04-24
; Compiler: pic-as(v3.10)
; IDE:      MPLABX v6.30
;
; Description:
;
;   Example project for the PIC16F1579 controller using the pic-as(v3.10) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
;                         PIC16F1579
;              +-------------:_:-------------+
;     GND ->  1 : VDD                     VSS : 20 <- 5v0
;         <>  2 : RA5             PGD/AN0/RA0 : 19 <> PGD 
;         <>  3 : RA4/AN3         PGC/AN1/RA1 : 18 <> PGC 
;     VPP ->  4 : RA3/VPP         INT/AN2/RA2 : 17 <>
;    PWM1 <>  5 : RC5/PWM1            AN4/RC0 : 16 <>
;         <>  6 : RC4                 AN5/RC1 : 15 <>
;         <>  7 : RC3/AN7             AN6/RC2 : 14 <>
;         <>  8 : RC6/AN8            AN10.RB4 : 13 <>
;         <>  9 : RC7/AN9            AN11/RB5 : 12 <>
;         <> 10 : RB7                     RB6 : 11 <>
;              +-----------------------------:
;                           DIP-20
;
; Notes:
;   An issues exists with the PWMx simulation model, there is an undocumented bit in the PWMxCON register,
;   The data sheet documents bit 6 of this register as "unimplemented" but the simulation model 
;   implements this as an output enable. When this bit is zero the simulator does not drive the output.
;
;   At this time it is unknown if this is how the real hardware works.
;
;   This may be only a bug in the simulation model and the real hardware behaves as described in the data sheet.
;
#define _XTAL_FREQ 4000000
#define FCT (_XTAL_FREQ/4)

    PROCESSOR   16F1579
    PAGEWIDTH   132
    RADIX       DEC

; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection Bits (INTOSC oscillator; I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  PPS1WAY = OFF         ; PPSLOCK bit One-Way Set Enable bit (PPSLOCKED Bit Can Be Cleared & Set Repeatedly)
  CONFIG  PLLEN = OFF           ; PLL Enable (4x PLL disabled)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LPBOREN = OFF         ; Low Power Brown-out Reset enable bit (LPBOR is disabled)
  CONFIG  DEBUG = OFF           ; In-Circuit Debugger Mode (In-Circuit Debugger disabled, ICSPCLK and ICSPDAT are general purpose I/O pins)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable (Low-voltage programming enabled)

#include <xc.inc>

#define _XTAL_FREQ 4000000
#define FCY (_XTAL_FREQ/4)

;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
resetVec:
    global  resetVec
    goto    start               ;jump to the start up routine

;
;   Data space use by interrupt handler to save context
    PSECT   Isr_Data,global,class=RAM,space=1,delta=1,noexec
;
;
;   Interrupt vector and handler
    PSECT   Isr_Vec,global,class=CODE,delta=2
    GLOBAL  IsrVec
;
IsrVec:
    retfie                      ; Return from interrupt
;
; 
start:
    PAGESEL main                ; Start main application
    goto    main
;
; 
; Initialize main application
    PSECT   MainCode,global,class=CODE,delta=2
main:
    clrf    INTCON              ;starting point
;
; Application process init
;
    call    PWM1_Init
;
; Application process loop
;
loop:
    goto    loop                ; 
;
; PWM1 Initialization
#define PWM1_PERIOD (_XTAL_FREQ/4/4000)
PWM1_Init:
    banksel ANSELC
    clrf    ANSELC

    banksel TRISC
    bcf     TRISC,TRISC_TRISC5_POSITION

    banksel RC5PPS
    movlw   3
    movwf   RC5PPS

    banksel PWM1PRL
    movlw   LOW(PWM1_PERIOD)
    movwf   PWM1PRL
    movlw   HIGH(PWM1_PERIOD)
    movwf   PWM1PRH

    movlw   LOW(PWM1_PERIOD)
    movwf   PWM1PRL
    movlw   HIGH(PWM1_PERIOD)
    movwf   PWM1PRH

    clrf    PWM1OFL
    clrf    PWM1OFH

    movlw   LOW(PWM1_PERIOD/2)
    movwf   PWM1DCL
    movlw   HIGH(PWM1_PERIOD/2)
    movwf   PWM1DCH

    clrf    PWM1OFCON

    movlw   PWM1LDCON_LDA_MASK
    movwf   PWM1LDCON

    movlw   0x20
    movwf   PWM1CLKCON

    movlw   PWM1CON_EN_MASK | PWM1CON_OE_MASK
    movwf   PWM1CON

    return

    END     resetVec            ; Tell the linker the entry point