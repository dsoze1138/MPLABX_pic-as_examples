;
; File:     main.S
; Target:   PIC10F322
; Author:   dan1138
; Date:     2022-APR-19
; Compiler: pic-as(v2.36)
; IDE:      MPLABX v6.00
;
; Description:
;
;   Example project for the PIC10F322 controller using the pic-as(v2.36) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pIsr_vec=4h
;
    PROCESSOR   10F322
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config FOSC = INTOSC    ; Oscillator Selection bits (INTOSC oscillator: CLKIN function disabled)
 config BOREN = OFF      ; Brown-out Reset Enable (Brown-out Reset disabled)
 config WDTE = OFF       ; Watchdog Timer Enable (WDT disabled)
 config PWRTE = OFF      ; Power-up Timer Enable bit (PWRT disabled)
 config MCLRE = OFF      ; MCLR Pin Function Select bit (MCLR pin function is digital input, MCLR internally tied to VDD)
 config CP = OFF         ; Code Protection bit (Program memory code protection is disabled)
 config LVP = OFF        ; Low-Voltage Programming Enable (Low-voltage programming disabled)
 config LPBOR = ON       ; Brown-out Reset Selection bits (BOR enabled)
 config BORV = LO        ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
 config WRT = OFF        ; Flash Memory Self-Write Protection (Write protection off)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Counter
Counter:    DS      1
;
; Reset vector
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    goto    Start
;
;   Data space use by interrupt handler to save context
    PSECT   Isr_data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
;
;   Interrupt vector and handler
    PSECT   Isr_vec,global,class=CODE,delta=2
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_save
    swapf   STATUS,W
    movwf   STATUS_save
;
IsrHandler:
;
IsrExit:
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                      ; Return from interrupt
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

    end     ResetVector
