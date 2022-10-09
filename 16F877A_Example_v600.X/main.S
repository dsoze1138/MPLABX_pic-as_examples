;
; File:     main.S
; Target:   PIC16F877A
; Author:   dan1138
; Date:     2020-10-09
; Compiler: pic-as(v2.40)
; IDE:      MPLABX v6.00
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

skipc   MACRO
    btfss   STATUS,STATUS_C_POSITION
        ENDM

skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
        ENDM

skipz   MACRO
    btfss   STATUS,STATUS_Z_POSITION
        ENDM
;
; Branch macros
;
bnz     MACRO arg
    btfss   STATUS,STATUS_Z_POSITION
    goto    arg
        ENDM

bz      MACRO arg
    btfsc   STATUS,STATUS_Z_POSITION
    goto    arg
        ENDM

bnc     MACRO arg
    btfss   STATUS,STATUS_C_POSITION
    goto    arg
        ENDM

bc      MACRO arg
    btfsc   STATUS,STATUS_C_POSITION
    goto    arg
        ENDM
;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL INICIO
    goto    INICIO

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

ms_20:
        clrf   TMR0
        movlw  80
        xorwf  TMR0,w
        bnz    $-3
        return
;
; Initialize the PIC hardware
;

INICIO: bsf     STATUS,STATUS_RP0_POSITION
        bcf     STATUS,STATUS_RP1_POSITION
        movlw   0b00000000
        movwf   TRISB
        movlw   0b00000111
        movwf   OPTION_REG
        bcf     STATUS,STATUS_RP0_POSITION
        bcf     STATUS,STATUS_RP1_POSITION
        clrf    PORTB
        bsf     PORTB,0
        call    ms_20
        bcf     PORTB,0
        call    ms_20
        goto    m0
    
m0:     bsf     PORTB,0
        call    ms_20
        bcf     PORTB,0
        call    ms_20
        goto    m0
;
; Declare Power-On-Reset entry point
;
    END     resetVec