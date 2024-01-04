;
; File:     start.S
; Target:   PIC10F202
; Author:   dan1138
; Date:     2024-JAN-09
; Compiler: pic-as(v2.45)
; IDE:      MPLABX v6.15
;
; Description:
;
;   Example project for the PIC10F202 controller using the pic-as(v2.45) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=01ffh
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
  CONFIG  WDTE = OFF            ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF              ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON            ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Temp
Temp:       DS      1
;
; See: https://stackoverflow.com/questions/77732552/no-source-code-lines-were-found-at-current-pc-0xc7-use-program-memory-view-to-s
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    movwf   OSCCAL      ;Set factory default for the oscillator calibration
    ;osccal register is at 05h

    movlw   11000000B
    option              ;to turn off T0CKI
    movlw   11111101B   ;set GP1 to output direction
    tris    GPIO
    clrf    Temp
    
Loop:
    BCF     GPIO,GPIO_GP1_POSITION
    BSF     GPIO,GPIO_GP1_POSITION
    movlw   255
    movwf   Temp
    goto    Loop        ;loop forever
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