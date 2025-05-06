; File:   main.asm
; Author: dan1138
; Target: PIC16F1936
; Compiler: MPASMWIN v5.51
; IDE: MPLABX v5.35
;
; Created on May 6 2025, 7:42 AM
;
;                               PIC16F1936
;                        +---------:_:---------+
;             VPP RE3 -> :  1 MCLRn     PGD 28 : <> RB7 PGD
;                 RA0 <> :  2           PGC 27 : <> RB6 PGC
;                 RA1 <> :  3               26 : <> RB5
;                 RA2 <> :  4               25 : <> RB4
;                 RA3 <> :  5               24 : <> RB3
;                 RA4 <> :  6               23 : <> RB2
;                 RA5 <> :  7               22 : <> RB1
;             GND VSS -> :  8               21 : <> RB0
;                 RA7 <> :  9 OSC1          20 : <- VDD 5v0
;                 RA6 <> : 10 OSC2          19 : <- VSS GND
;                 RC0 <> : 11 SOSCO         18 : <> RC7
;                 RC1 <> : 12 SOSCI         17 : <> RC6
;                 RC2 <> : 13               16 : <> RC5
;                 RC3 <> : 14               15 : <> RC4
;                        +---------------------+
;                                DIP-28
;
; Description:
;   This is an example template of setting up a MPASMWIN main application source code file.
;
;
;
    errorlevel  -302    ; suppress Register in operand not in bank 0 warning
    PROCESSOR 16F1936
    list        n=0,c=250
    RADIX       dec
;
; Define the system oscillator frequency this code will setup
#define _XTAL_FREQ 32000000
;
; Defines for target specific special function registers
#include <p16f1936.inc>
;
; PIC16F1936 Configuration Bit Settings
;
; CONFIG1
 __CONFIG _CONFIG1, 0x3FFF & _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
 __CONFIG _CONFIG2, 0x3FFF & _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LVP_ON
;
; Power-On-Reset entry point
resetVec    CODE    0x0000
    global  resetVec
resetVec:
    PAGESEL main                ;jump to the main routine
    goto    main
;
; Interrupt vector entry point
interruptVec CODE   0x0004
    global  interruptVec
interruptVec:
    retfie
;
; Application
    udata_shr   ; define data commeon to all banks
    global  commonTemp
commonTemp: RES  1
 
    udata       ; define data in one bank
    global  bankedTemp
bankedTemp: RES  1
 
    code        ; main application entry point
    global  main
main:
    clrf    INTCON      ; disable all interrupts
    banksel OSCCON
    movlw   0x70;       ; select INTOSC as 8MHz
    movwf   OSCCON
    bsf     OSCCON,SPLLEN ; enable 4x PLL to get 32MHz system clock
;
; Application process loop
    global  AppLoop
AppLoop:
 
    goto    AppLoop
 
    end