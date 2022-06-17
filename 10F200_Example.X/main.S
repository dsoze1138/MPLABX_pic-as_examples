;
; File:     main.S
; Target:   PIC10F200
; Author:   dan1138
; Date:     2020-07-25
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC10F200 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=0ffh
;
    PROCESSOR   10F200
    PAGEWIDTH   132
    RADIX       dec
    EXPAND
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;<editor-fold defaultstate="collapsed" desc="Skip macros">
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
;</editor-fold>
;
; Set the configuration word
;
 config WDTE = OFF       ; Watchdog Timer (WDT disabled)
 config CP = OFF         ; Code Protect (Code protection off)
 config MCLRE = ON       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
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
    skipz                               ; skip is ZERO flag set
    goto    Loop                        ; Loop when not equal
;
    goto    Start
;
; The PIC10F200 reset vector is the highest 
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