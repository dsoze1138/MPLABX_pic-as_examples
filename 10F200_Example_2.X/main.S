;
; File:     main.S
; Target:   PIC10F200
; Author:   dan1138
; Date:     2021-MAR-10
; Compiler: pic-as(v2.31)
; IDE:      MPLABX v5.45
;
; Description:
;
;   Example 2 project for the PIC10F200 controller using the pic-as(v2.31) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=0ffh
;
    PROCESSOR   10F200
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
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Delay_v1, Delay_v2
Temp:       DS      1
Delay_v1:   DS      1
Delay_v2:   DS      1
;
; See: https://electronics.stackexchange.com/questions/550331/pic10f200-blinking-led-pic-as-assembly
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    movwf   OSCCAL      ;Set factory default for the oscillator calibration
    ;osccal register is at 05h

    movlw   11000000B
    option              ;to turn off T0CKI

#ifdef CMCON0           ;CMCON0 is at 07h, but it exists only for the PIC10F206
    movlw   01110001B   ;bit 3 to 0 for turning comparator off
    movwf   CMCON0
#endif

    movlw   11111101B   ;set GP1 to output direction
    tris    GPIO
    
Loop:
    BCF     GPIO,GPIO_GP1_POSITION
    ;gpio is at 06h ;GP1 is bit 1 (could also try 01h)
    call    Delay
    BSF     GPIO,GPIO_GP1_POSITION ;turn LED off again
    call    Delay
    goto    Loop        ;loop forever
    
Delay:
    movlw   100         ;put the decimal number 100 into w
    movwf   Delay_v1    ;put 100 in register 0Ah
    ;register 11h should be general purpose register that I can use
    ;to put in values
    movwf   Delay_v2
    ;put 100 in 12h
Delay_Loop:
    DECFSZ  Delay_v1,F
    ;decrement the register and store the result in itself
    ;and skip the next instruction if the result was zero
    goto    Delay_Loop
    
    DECFSZ  Delay_v2,F
    ;the same with the second register that I filled
    goto    Delay_Loop
    retlw 0
;
; The PIC10F200 reset vector is the highest 
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