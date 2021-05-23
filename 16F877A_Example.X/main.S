;
; File:     main.S
; Target:   PIC16F877A
; Author:   dan1138
; Date:     2020-11-02
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example blinky project for the PIC16F877A controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options:
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
    PROCESSOR   16F877A
    PAGEWIDTH   132
    RADIX       DEC
;
#include <xc.inc>

; PIC16F877A Configuration Bit Settings

; 'C' source line config statements

; CONFIG
 config FOSC = HS        ; Oscillator Selection bits (HS oscillator)
 config WDTE = OFF       ; Watchdog Timer Enable bit (WDT disabled)
 config PWRTE = OFF      ; Power-up Timer Enable bit (PWRT disabled)
 config BOREN = OFF      ; Brown-out Reset Enable bit (BOR disabled)
 config LVP = OFF        ; Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
 config CPD = OFF        ; Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
 config WRT = OFF        ; Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
 config CP = OFF         ; Flash Program Memory Code Protection bit (Code protection off)
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
;
;   ***** SPECIAL VARIABLE DEFINITIONS
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  del1, del2, del3, del4
;
del1:    DS      1
del2:    DS      1
del3:    DS      1
del4:    DS      1
;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL Start
    goto    Start

;
;   Data space use by interrupt handler to save context
    PSECT   Isr_Data,global,class=COMMON,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save,PCLATH_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
PCLATH_save:    DS  1
;
;   Interrupt vector and handler
    PSECT   Isr_Vec,global,class=CODE,delta=2
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_save
    swapf   STATUS,W
    movwf   STATUS_save
    movf    PCLATH,W
    movwf   PCLATH_save
;
IsrHandler:
;
IsrExit:
    movf    PCLATH_save,W
    movwf   PCLATH
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                      ; Return from interrupt
;
;   Section used for main code
    PSECT   MainCode,global,class=CODE,delta=2
;
; Initialize the PIC hardware
;
Start:
    BANKSEL(TRISB)
    clrf    TRISB   ; PORT B OUTPUT

    BANKSEL(ADCON1)
    movlw   0x06
    movwf   ADCON1
    BANKSEL(CMCON)
    movlw   0x07
    movwf   CMCON

    BANKSEL(OPTION_REG)
    movlw   0xC7        ; TIMER0 clock source FOSC/4, TIMER0 uses prescaler, prescale 1:256
    movwf   OPTION_REG

    goto    LOOP
; remaining code goes here


LOOP:
    BANKSEL(PORTB)
    movlw   0x00
    movwf   PORTB
    call    delay
    movlw   0x0f
    movwf   PORTB
    call    delay
    goto    LOOP

delay:
    BANKSEL(del1)               ;Max deley when all are load to 255 is 50s
    movlw   2
    movwf   BANKMASK(del1)
d2:
    movlw   0xff
    movwf   BANKMASK(del2)
d1:
    movlw   0xff
    movwf   BANKMASK(del3)
d3:
    decfsz  BANKMASK(del3),F
    goto    d3
    decfsz  BANKMASK(del2),F
    goto    d1
    decfsz  BANKMASK(del1),F
    goto    d2

    return
;
; Declare Power-On-Reset entry point
;
    END     resetVec