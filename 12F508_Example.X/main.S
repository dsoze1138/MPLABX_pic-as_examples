;
; File:     main.S
; Target:   PIC12F508
; Author:   dan1138
; Date:     2021-01-25
; Compiler: pic-as(v2.31)
; IDE:      MPLABX v5.45
;
; Description:
;
;   Example project for the PIC12F508 controller using the pic-as(v2.31) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=01ffh
;
    PROCESSOR   12F508
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
  CONFIG  OSC = IntRC           ; Oscillator Selection bits (internal RC oscillator)
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Code protection off)
  CONFIG  MCLRE = ON            ; GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is MCLR)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Counter
Counter:    DS      2
;
; Simple test application that implements a
; delay function then sets GPIO bit GB2 high
; calls the delay function, then sets GPIO 
; bit GB2 low, calls the delay function then loops.
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start, Delay, main, Loop
Start:
    clrf    Counter
    clrf    Counter+1
    goto    main
;
Delay:
    incfsz  Counter,F                   ; Increment Counter value low 8-bits
    goto    Delay
    incfsz  Counter+1,F                 ; Increment Counter value high 8-bits
    goto    Delay
    retlw   0
;
main:
    movlw   0b11011111  ; Select TIMER0 clock source as FOSC/4
    option
    movlw   0b11111011  ; GP2 as output
    tris    GPIO
;
; Toggle GPIO bit 2
;
Loop:
    bsf     GP2         ; set port bit high
    call    Delay
    bcf     GP2         ; set port bit low
    call    Delay
    goto    Loop
;
; The PIC12F508 reset vector is the highest 
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