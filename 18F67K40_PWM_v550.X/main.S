;
; Author: dan1138
; Target: PIC18F67K40
; 
; Created on October 3, 2021, 9:57 PM
;
;                                                                   PIC18F67K40
;             +------------------+             +------------------+             +------------------+             +------------------+
;          <> :  1 RE1/ANE1      :          <> : 17 RF1/ANF1      :          <> : 33 RC2           :          <> : 49 RD7/AND7      :
;          <> :  2 RE0/ANE0      :          <> : 18 RF0/ANF0      :          <> : 34 RC3           :          <> : 50 RD6/AND6      :
;          <> :  3 RG0/ANG0      :          <> : 19 RG7/ANG7      :          <> : 35 RC4           :          <> : 51 RD5/AND5      :
;          <> :  4 RG1/ANG1      :          <> : 20 RG6/ANG6      :          <> : 36 RC5           :          <> : 52 RD4/AND4      :
;          <> :  5 RG2/ANG2      :          <> : 21 RA3/ANA3      :      PGD <> : 37 RB7/ANB7/PGD  :          <> : 53 RD3/AND3      :
;          <> :  6 RG3/ANG3      :          <> : 22 RA2/ANA2      :      3v3 -> : 38 VDD           :          <> : 54 RD2/AND2      :
;      VPP -> :  7 RG5/MCLR      :          <> : 23 RA1/ANA1      :          <> : 39 RA7/ANA7/OSC1 :          <> : 55 RD1/AND1      :
;          <> :  8 RG4/ANG4      :          <> : 24 RA0/ANA0      :          <> : 40 RA6/ANA6/OSC2 :          <> : 56 RH3           :
;      GND -> :  9 VSS           :          <> : 25 RH1/ADCACT    :      GND -> : 41 VSS           :          <> : 57 RH2           :
;      3v3 -> : 10 VDD           :          <> : 26 RH0           :      PGC <> : 42 RB6/ANB6/PGC  :          <> : 58 RD0/AND0      :
;          <> : 11 RF7/ANF7      :          <> : 27 RA5/ANA5      :          <> : 43 RB5/ANB5      :          <> : 59 RE7/ANE7      :
;          <> : 12 RF6/ANF6      :          <> : 28 RA4/ANA4      :          <> : 44 RB4/ANB4      :          <> : 60 RE6/ANE6      :
;          <> : 13 RF5/ANF5      :     PWM1 <> : 29 RC1/SOSCI     :          <> : 45 RB3/ANB3      :          <> : 61 RE5/ANE5      :
;          <> : 14 RF4/ANF4      :          <> : 30 RC0/SOSCO     :          <> : 46 RB2/ANB2      :          <> : 62 RE4/ANE4      :
;          <> : 15 RF3/ANF3      :          <> : 31 RC6           :          <> : 47 RB1/ANB1      :          <> : 63 RE3/ANE3      :
;          <> : 16 RF2/ANF2      :          <> : 32 RC7           :          <> : 48 RB0/ANB0      :          <> : 64 RE2/ANE2      :
;             +------------------+             +------------------+             +------------------+             +------------------+
;                                                                     TQFP-64
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-presetVec=0h,-phi_int_vec=08h,-plo_int_vec=18h -Wa,-a
;
    PROCESSOR   18F67K40
    PAGEWIDTH   132
    RADIX       dec
;
; Include device specific special function register definitions
;
#include <xc.inc>
;
; Setup all configuration word bits except DEBUG, let the IDE take care of that one.
;
  CONFIG  FEXTOSC = OFF, RSTOSC = HFINTOSC_64MHZ, CLKOUTEN = OFF, CSWEN = ON
  CONFIG  FCMEN = ON, MCLRE = EXTMCLR, PWRTE = OFF, LPBOREN = OFF, BOREN = SBORDIS
  CONFIG  BORV = VBOR_2P45, ZCD = OFF, PPS1WAY = OFF, STVREN = ON
  CONFIG  XINST = OFF, WDTCPS = WDTCPS_31, WDTE = OFF, WDTCWS = WDTCWS_7, WDTCCS = SC
  CONFIG  WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
  CONFIG  WRT4 = OFF, WRT5 = OFF, WRT6 = OFF, WRT7 = OFF
  CONFIG  WRTC = OFF, WRTB = OFF, WRTD = OFF
  CONFIG  SCANE = OFF, LVP = ON, CP = OFF, CPD = OFF
  CONFIG  EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
  CONFIG  EBTR4 = OFF, EBTR5 = OFF, EBTR6 = OFF, EBTR7 = OFF, EBTRB = OFF
;
; Define how we expect the code to setup the system clock frequency
;
#define FSYS (64000000)
#define FCY  (FSYS/4)
;
;   Reset vector
    PSECT   resetVec,global,reloc=2,class=CODE,delta=1
;
resetVec:
    goto    Start
;
;   High priority interrupt vector
    PSECT   hi_int_vec,global,reloc=2,class=CODE,delta=1
;
    goto    HighIsrHandler
;
;   Data space use by low priority interrupt handler to save context
    PSECT   LowIsr_data,global,class=COMRAM,space=1,delta=1,lowdata,noexec
;
    GLOBAL  WREG_save,STATUS_save,BSR_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
BSR_save:       DS  1
;
;   Low priority interrupt vector and handler
    PSECT   lo_int_vec,global,reloc=2,class=CODE,delta=1
;
LowIsrVec:
    movff   WREG,WREG_save
    movff   STATUS,STATUS_save
    movff   BSR,BSR_save
;
LowIsrHandler:
;
LowIsrExit:
    movff   BSR_save,BSR
    movff   STATUS_save,STATUS
    movff   WREG_save,WREG
    retfie  0   ; Return from interrupt
;
;   High priority interrupt handler
    PSECT   HighIsr_code,global,reloc=2,class=CODE,delta=1
;
HighIsrHandler:
    retfie  1   ; Fast return from interrupt
;
;   Startup code used at power on reset
    PSECT   start_code,global,reloc=2,class=CODE,delta=1
    global  Start
;
Start:
;
;   Disable all interrupt sources
;
    clrf    INTCON,c
    banksel PIE0
    clrf    BANKMASK(PIE0),b
    clrf    BANKMASK(PIE1),b
    clrf    BANKMASK(PIE2),b
    clrf    BANKMASK(PIE3),b
    clrf    BANKMASK(PIE4),b
    clrf    BANKMASK(PIE5),b
    clrf    BANKMASK(PIE6),b
    clrf    BANKMASK(PIE7),b
    clrf    BANKMASK(PIE8),b
    clrf    BANKMASK(PIE9),b
;
; Configure CCP1 to output 4KHz square wave on RC1
;
;
;   Make RC1 an output, low on start
;
    banksel (LATC)
    bcf     BANKMASK(LATC),LATC_LATC1_POSITION,b
    banksel (TRISC)
    bcf     BANKMASK(TRISC),TRISC_TRISC1_POSITION,b
    banksel (SLRCONC)
    bcf     BANKMASK(SLRCONC),SLRCONC_SLRC1_POSITION,b
;
; Assign CCP1 to RC1
;
    banksel (RC1PPS)
    movlw   0x05            ; magic number from data shhet for CCP1 output
    movwf   BANKMASK(RC1PPS),b
;
; Setup TIMER2 for 4KHz period
;
    movlw   0x40
    movwf   T2CON,c         ; Set TIMER2 prescal as 1:16
    movlw   (FCY/(16*4000))-1
    movwf   T2PR,c          ; Set period to 4KHz
    movlw   1
    movwf   T2CLKCON,c      ; Slect FOSC/4 as TIMER2 clock source
;
; Setup CCP1 as PWM
;
    movlw   0x1C
    movwf   CCP1CON,c       ; set CCP1 as PWM with left aligned duty cycle register
    clrf    CCPR1H,c
    clrf    CCPR1L,c
;
; Set duty cycle to 50%
;
    movf    T2PR,w,c
    addlw   1
    movwf   CCPR1H,c
    rrcf    CCPR1H,c
    rrcf    CCPR1L,c
;
; Enable CCP1 PWM
;
    bsf     CCP1CON,CCP1CON_EN_POSITION,c
;
; Turn on TIMER2
;
    bsf     T2CON,T2CON_ON_POSITION,c
;
    goto    main
;
;
;   Main application code
    PSECT   main_code,global,reloc=2,class=CODE,delta=1
    global  main
;
main:
;
    banksel PIR5
    bcf     PIR5,PIR5_TMR2IF_POSITION,b
AppLoop:
    btfss   PIR5,PIR5_TMR2IF_POSITION,b
    bra     AppLoop
    bcf     PIR5,PIR5_TMR2IF_POSITION,b
    goto    AppLoop
;
    END     resetVec
