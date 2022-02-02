; Date: 2022-FEB-01
; File: main.S
; Target: PIC16F18877
; MPLABX: v5.50
; Compiler: pic-as(v2.35)
;  
; Description:
;
;   Example appliction for PIC16F18877.
;   Toggle LED1 one time after a spin wait, about 300 milliseconds.
;   Toggle LED2 once after TIMER0 overflows 10 times, about 330 milliseconds.
;   The flashing of the LEDs will drift in and out of phase.
;   
;                        PIC16F18877
;                 +----------:_:----------+
;       VPP ->  1 : RE3/MCLR/VPP  PGD/RB7 : 40 <> PGD
;           <>  2 : RA0           PGC/RB6 : 39 <> PGC
;           <>  3 : RA1               RB5 : 38 <>
;           <>  4 : RA2               RB4 : 37 <>
;           <>  5 : RA3               RB3 : 36 <> 
;           ->  6 : RA4               RB2 : 35 <> 
;           ->  7 : RA5               RB1 : 34 <> LED2
;           <>  8 : RE0               RB0 : 33 <> LED1
;           <>  9 : RE1               VDD : 32 <- PWR
;           <> 10 : RE2               VSS : 31 <- GND
;       PWR -> 11 : VDD               RD7 : 30 <> 
;       GND -> 12 : VSS               RD6 : 29 <> 
;           <> 13 : RA7/OSC1          RD5 : 28 <> 
;           <> 14 : RA6/OSC2          RD4 : 27 <> 
;           <> 15 : RC0/SOSCO         RC7 : 26 <> 
;           <> 16 : RC1/SOSCI         RC6 : 25 <> 
;           <> 17 : RC2               RC5 : 24 <>
;           <> 18 : RC3               RC4 : 23 <> 
;           <> 19 : RD0               RD3 : 22 <> 
;           <> 20 : RD1               RD2 : 21 <> 
;                 +-----------------------:
;                          DIP-40
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pISR_Vec=4h
;
    PROCESSOR   16F18877
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
  CONFIG  FEXTOSC = OFF, RSTOSC = HFINT32, CLKOUTEN = OFF, CSWEN = ON, FCMEN = ON
  CONFIG  MCLRE = ON, PWRTE = OFF, LPBOREN = OFF, BOREN = OFF, BORV = LO, ZCD = OFF, PPS1WAY = OFF, STVREN = ON
  CONFIG  WDTCPS = WDTCPS_31, WDTE = OFF, WDTCWS = WDTCWS_7, WDTCCS = SC
  CONFIG  WRT = OFF, SCANE = available, LVP = ON
  CONFIG  CP = OFF, CPD = OFF
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
    banksel PIE0
    clrf    PIE0
    clrf    PIE1
    clrf    PIE2
    clrf    PIE3
    clrf    PIE4
    clrf    PIE5
    clrf    PIE6
    clrf    PIE7
    clrf    PIE8

    banksel OSCCON1
    movlw   0x62        ; System oscillator set to 8MHz
    movwf   OSCCON1

    banksel T0CON1
    movlw   0x48        ; Set TIMER0 clock source to FOSC/4, scale 1:256 TIMER0 overflows every 32.768 milliseconds
    movwf   T0CON1
    banksel T0CON0
    movlw   0x80        ; Start TIMER0
    movwf   T0CON0

    banksel ANSELB
    clrf    ANSELB
    banksel TRISB
    movlw   0xF0
    movwf   TRISB
    banksel LATB
    movwf   LATB

    banksel TMR0L
    clrf    TMR0L
    movlw   0xFF
    movwf   TMR0H
    banksel PIR0
    bcf     PIR0,PIR0_TMR0IF_POSITION

    clrf    FSR1L
    movlw   10
    subwf   FSR1L,F
    goto    AppLoop
;
; Application loop
;
AppLoop:
    banksel LATB
    movlw   1
    xorwf   LATB,F      ; Toggle LED1
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
; Note: This delay always takes the same number
;       of instruction cycles for each of
;       three possible paths.
;
Delay_2:
    banksel PIR0
    btfss   PIR0,PIR0_TMR0IF_POSITION
    goto    Delay_3
    bcf     PIR0,PIR0_TMR0IF_POSITION
    banksel FSR1L
    movlw   10
    incfsz  FSR1L,F
    goto    Delay_4
    subwf   FSR1L,F
    movlw   2
    xorwf   LATB,F      ; Toggle LED2
    return
Delay_3:
    nop
    nop
    nop
    nop
    nop
Delay_4:
    nop
    nop
    return
;
    end     ResetVector