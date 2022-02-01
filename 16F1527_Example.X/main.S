; Date: 2022-FEB-01
; File: main.S
; Target: PIC16F1527
; MPLABX: v5.50
; Compiler: pic-as(v2.35)
;  
; Description:
;
;   Example appliction for PIC16F1527.
;   Toggle LED1 one time after a spin wait, about 250 milliseconds.
;   Toggle LED2 once after TIMER0 overflows 10 times, about 330 milliseconds.
;   The flashing of the LEDs will drift in and out of phase.
;   
;
;                                                           PIC16F1527
;             +---------------+            +---------------+            +---------------+            +---------------+
;          <> :  1 RE1        :         <> : 17 RF1        :         <> : 33 RC2        :         <> : 49 RD7        :
;          <> :  2 RE0        :         <> : 18 RF0        :         <> : 34 RC3        :         <> : 50 RD6        :
;          <> :  3 RG0        :     3v3 -> : 19 AVDD       :         <> : 35 RC4        :         <> : 51 RD5        :
;          <> :  4 RG1        :     GND -> : 20 AVSS       :         <> : 36 RC5        :         <> : 52 RD4        :
;          <> :  5 RG2        :         <> : 21 RA3        : IDC_PGD <> : 37 RB7/PGD    :         <> : 53 RD3        :
;          <> :  6 RG3        :         <> : 22 RA2        :     3v3 -> : 38 VDD        :         <> : 54 RD2        :
;  ICD_VPP -> :  7 RG5/MCLR   :         <> : 23 RA1        :         <> : 39 RA7        :         <> : 55 RD1        :
;          <> :  8 RG4        :         <> : 24 RA0        :         <> : 30 RA6        :      GND-> : 56 VSS        :
;      GND -> :  9 VSS        :     GND -> : 25 VSS        :     GND -> : 41 VSS        :      3v3-> : 57 VDD        :
;      3v3 -> : 10 VDD        :     3v3 -> : 26 VDD        : ICD_PGC <> : 42 RB6/PGC    :         <> : 58 RD0        :
;          <> : 11 RF7        :         <> : 27 RA5        :         <> : 43 RB5        :         <> : 59 RE7        :
;          <> : 12 RF6        :         <> : 28 RA4        :         <> : 44 RB4        :         <> : 60 RE6        :
;          <> : 13 RF5        :    LED2 <> : 29 RC1        :         <> : 45 RB3        :         <> : 61 RE5        :
;          <> : 14 RF4        :    LED1 <> : 30 RC0        :         <> : 46 RB2        :         <> : 62 RE4        :
;          <> : 15 RF3        :         <> : 31 RC6        :         <> : 47 RB1        :         <> : 63 RE3        :
;          <> : 16 RF2        :         <> : 32 RC7        :         <> : 48 RB0        :         <> : 64 RE2        :
;             +---------------+            +---------------+            +---------------+            +---------------+
;                                                             TQFP-64
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pISR_Vec=4h
;
    PROCESSOR   16F1527
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
; Reset vector
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    goto    Start
;
; Interrupt vector
;
    PSECT   ISR_Vec,class=CODE,delta=2
    global  ISR
ISR:
    retfie
;
; Application start
;
    PSECT   code
Start:
    clrf    INTCON      ; Disable all interrupts
    banksel OSCCON
    movlw   0x3a        ; System oscillator set to 8MHz
    movwf   OSCCON

    banksel OPTION_REG
    movlw   0xD7        ; Set TIMER0 clock source to FOSC/4, TIMER0 overflows ever 32.768 milliseconds
    movwf   OPTION_REG

    banksel TRISC
    movlw   0xF0
    movwf   TRISC
    banksel LATC
    movwf   LATC

    banksel TMR0
    clrf    TMR0
    bcf     INTCON,INTCON_TMR0IF_POSITION

    clrf    FSR1L
    movlw   10
    subwf   FSR1L,F
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
;
; Toggle LED2 when TIMER0 overflows
;
Delay_2:
    btfss   INTCON,INTCON_TMR0IF_POSITION
    goto    Delay_3
    bcf     INTCON,INTCON_TMR0IF_POSITION
    movlw   10
    incfsz  FSR1L,F
    goto    Delay_4
    subwf   FSR1L,F
    movlw   2
    xorwf   LATC,F
    return
Delay_3:
    nop
    nop
    nop
Delay_4:
    nop
    nop
    return
;
    end     ResetVector