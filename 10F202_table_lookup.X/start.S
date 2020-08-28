;
; File:     start.S
; Target:   PIC10F202
; Author:   dan1138
; Date:     2020-07-25
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC10F202 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pTableInCode=1h,-pResetVec=1ffh,-Map=10F202_table_lookup.map
;
; Notes:
;   Needed to add the "-DCODE=2" parameter because the pic-as(v2.20) integration with the MPLABX IDE
;   still has bugs. See: https://www.microchip.com/forums/FindPost/1150913
;
    PROCESSOR   10F202
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config WDTE = OFF       ; Watchdog Timer (WDT disabled)
 config CP = OFF         ; Code Protect (Code protection off)
 config MCLRE = ON       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
    global  Main
Start:
    goto    Main

;
; The PIC10F202 reset vector is the highest 
; instruction word in the code space.
;
; This is used to load the WREG with the factory 
; oscillator calibration value then  the program 
; counter rollover to zero to start the code.
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:

    end     ResetVector