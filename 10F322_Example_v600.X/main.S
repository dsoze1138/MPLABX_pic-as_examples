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
; In the project properties box "pic-as Global Options -> Additional options" 
;
; Add this line: 
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
    global  COUNT1,COUNT2
COUNT1:    DS      1
COUNT2:    DS      1
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
; Simple test application that toggle PORTA bit 0
;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
; PORTS
    clrf    PORTA
    clrf    LATA
    clrf    ANSELA
    movlw   00h ; RA0/RA1=OUT
    movwf   TRISA
    movlw   01h
loop:
    xorwf   LATA,1
    call    delay
    goto    loop

delay:
inner:
    decfsz  COUNT1,1
    goto    inner
    decfsz  COUNT2,1
    goto    inner
    return

    end     ResetVector
