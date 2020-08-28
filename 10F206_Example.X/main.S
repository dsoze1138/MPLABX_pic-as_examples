;
; File:     main.S
; Target:   PIC10F206
; Author:   dan1138
; Date:     2020-08-14
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Depends on files:
;   <InstallPathVaries>\xc8\v2.20\pic\include\xc.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\pic.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\pic_as_chip_select.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\proc\pic10f206.inc
;
; Description:
;
;   Example project for the PIC10F206 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pOscCalVec=1ffh
;
    PROCESSOR   10F206
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config MCLRE = OFF, CP = OFF, WDTE = ON
;
;
;
#define LED_GPIO    1
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Counter
Counter:    DS      1
;
; Simple test application that toggles
; GPIO bit x on every wake from sleep.
;
; The WDT timeout is at least 1280 milliseconds
; and at most 3968 milliseconds, will typically 
; be about 2300 milliseconds. It depends on the
; temperature and the VDD voltage.
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    btfss   STATUS,STATUS_nPD_POSITION  ; Skip if it's a power on
    btfsc   STATUS,STATUS_nTO_POSITION  ; Don't Skip if it's a WDT reset
    clrf    Counter                     ; Clear count for Power-On-Reset only
    movlw   0xDF                        ; Use FOSC/4 as TIMER0 clock not GPIO2
    option
    clrf    CMCON0                      ; turn off comparator, makes GPIO1 & 2 digital I/O
    bcf     OSCCAL,OSCCAL_FOSC4_POSITION; Do not drive GPIO2 with FOSC/4
    movlw   ~(1<<LED_GPIO)              ; Make the GPIO with the LED an output
    tris    GPIO
    
    andwf   GPIO,F                      ; set all output bits to zero

    incf    Counter,F                   ; Increment the sleep Counter
    movlw   (1<<LED_GPIO)               ; Bit mask of te LED bit in the GPIO port
    btfsc   Counter,0                   ; Skip if the count is even
    xorwf   GPIO,F                      ; Turn on LED
    movf    GPIO,W                      ; Read the PORT to clear any mismatch 
    sleep                               ; Goto sleep, remember: Wakeup results in a reset
    nop                                 ; Never executes, but just 
    nop                                 ; to be safe we will fill 
    nop                                 ; the pipeline.
;
Loop:
    goto    Loop                        ; Hang here waiting for a reset
;
; In the PIC10F206 the factory calibration for
; the onchip oscillator is stored as a MOVLW 0xnn
; opcode as the last instruction of code space.
; On RESET the PC is set to all ones and this
; opcode is executed, then the PC rolls over
; to zero and the first opcode of the application
; will execute.
;
    PSECT   OscCalVec,class=CODE,delta=2
    global  OscCal
OscCal:


    end     OscCal