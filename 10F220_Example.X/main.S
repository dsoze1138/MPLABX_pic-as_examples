;
; File:     main.S
; Target:   PIC10F220
; Author:   dan1138
; Date:     2020-10-08
; Compiler: pic-as(v2.31)
; IDE:      MPLABX v5.45
;
; Description:
;
;   Example project for the PIC10F220 controller using the pic-as(v2.31) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-pStartCode=0h,-pResetVec=0ffh
;
    PROCESSOR   10F220
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config IOSCFS = 1       ; Internal Oscillator Frequency Select bit (8 MHz)
 config MCPU = OFF       ; Master Clear Pull-up Enable bit (Pull-up disabled)
 config WDTE = OFF       ; Watchdog Timer Enable bit (WDT disabled)
 config CP = OFF         ; Code protection bit (Code protection off)
 config MCLRE = OFF      ; GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Counter
Counter:    DS      1
;
; Simple test application that clears
; a RAM location to zero, then increments
; that location until it reaches the
; value 22. Then starts again.
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    clrf    Counter
Loop:
    incf    Counter,F                   ; Increment the Counter value
    movf    Counter,W                   ; Put the Counter value in WREG
    xorlw   22                          ; Test the value, set ZERO flag when equal
    btfss   STATUS,STATUS_Z_POSITION    ; skip is ZERO flag set
    goto    Loop                        ; Loop when not equal
;
    goto    Start
;
; The PIC10F220 reset vector is the highest 
; instruction word in the code space.
;
; This is used to load the WREG with the factory 
; oscillator calibration value then  the program 
; counter rollover to zero to start the code.
;
; This example code places a GOTO instruction here.
;
; WARNING:  Programming a real part with this code
;           will erase the oscillator calibration value
;           set when the part was manufactured.
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    goto    Start

    end     ResetVector