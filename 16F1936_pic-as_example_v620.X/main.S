; File:   main.c
; Author: dan1138
; Target: PIC16F1936
; Compiler: pic-as v3.00
; IDE: MPLABX v6.20
; 
; Created on May 5 2025, 1:22 PM
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
;   This is an example template of setting up a pic-as main appliation source code file.
; 
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;    -Wl,-DCODE=2,-presetVec=0h,-pinterruptVec=4h -Wa,-a
;
    PROCESSOR 16F1936
    PAGEWIDTH   250
    RADIX       dec
;
; Define the system oscillator frequency this code will setup
#define _XTAL_FREQ 32000000

; PIC16F1936 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Memory Code Protection (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
  CONFIG  IESO = ON             ; Internal/External Switchover (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  VCAPEN = OFF          ; Voltage Regulator Capacitor Enable (All VCAP pin functionality is disabled)
  CONFIG  PLLEN = ON            ; PLL Enable (4x PLL enabled)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable (Low-voltage programming enabled)

// config statements should precede project file includes.
#include <xc.inc>
;
; Power-On-Reset entry point
    PSECT   resetVec,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL main                ;jump to the main routine
    goto    main
;
; Interrupt vector entry point
    PSECT   interruptVec,class=CODE,delta=2
    global  interruptVec
interruptVec:
    retfie
;
; Application 
    PSECT   udata_shr   ; define data commeon to all banks
    global  commonTemp
commonTemp: ds  1

    PSECT   udata       ; define data in one bank
    global  bankedTemp
bankedTemp: ds  1

    PSECT   code        ; main application entry point
    global  main
main:
    clrf    INTCON      ; disable all interrupts
    banksel OSCCON
    movlw   0x70;       ; select INTOSC as 8MHz
    movwf   OSCCON
    bsf     OSCCON,OSCCON_SPLLEN_POSITION ; enable 4x PLL to get 32MHz system clock
;
; Application process loop
    global  AppLoop
AppLoop:

    goto    AppLoop

    end    resetVec 