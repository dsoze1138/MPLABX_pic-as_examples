;
; File:     main.S
; Target:   PIC16F688
; Author:   dan1138
; Date:     2020-08-20
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC16F688 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
;                        PIC16F688
;              +------------:_:------------+
;     GND -> 1 : VDD                   VSS : 14 <- 5v0
;         <> 2 : RA5/T1CKI     PGD/AN0/RA0 : 13 <> PGD 
;         <> 3 : RA4/AN3       PGC/AN1/RA1 : 12 <> PGC 
;     VPP -> 4 : RA3/VPP           AN2/RA2 : 11 <>
;         <> 5 : RC5/RXD           AN4/RC0 : 10 <> 
;         <> 6 : RC4/TXD           AN5/RC1 : 9  <> 
;         <> 7 : RC3/AN7           AN6 RC2 : 8  <> 
;              +---------------------------:
;                         DIP-14

    PROCESSOR   16F688
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; PIC16F688 Configuration Bit Settings
    config FOSC = INTOSCIO  ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA4/OSC2/CLKOUT pin, I/O function on RA5/OSC1/CLKIN)
    config WDTE = OFF       ; Watchdog Timer Enable bit (WDT disabled)
    config PWRTE = OFF      ; Power-up Timer Enable bit (PWRT disabled)
    config MCLRE = ON       ; MCLR Pin Function Select bit (MCLR pin function is MCLR)
    config CP = OFF         ; Code Protection bit (Program memory code protection is disabled)
    config CPD = OFF        ; Data Code Protection bit (Data memory code protection is disabled)
    config BOREN = OFF      ; Brown Out Detect (BOR disabled)
    config IESO = ON        ; Internal External Switchover bit (Internal External Switchover mode is enabled)
    config FCMEN = OFF      ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)

  skipnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
  ENDM

  skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
  ENDM
;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL main                ;jump to the main routine
    goto    main

;
;   Data space use by interrupt handler to save context
    PSECT   Isr_Data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save
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
; Toggle output bit every 4 instruction cycles.
; 
    PSECT   MainCode,global,class=CODE,delta=2
main:
    clrf    INTCON              ;starting point
    BANKSEL OSCCON
    movlw   0x60
    movwf   BANKMASK(OSCCON)    ; Set FRC to 4MHz
    BANKSEL TRISA
    movlw   0xFF
    movwf   BANKMASK(TRISA)     ; Make PORTA outputs
    movwf   BANKMASK(TRISC)     ; Make PORTC outputs
    BANKSEL ANSEL
    clrf    ANSEL               ; Trun off ADC analog inputs
    BANKSEL CMCON0
    movlw   0x07
    movwf   BANKMASK(CMCON0)    ; Turn off comparator analog inputs
;
; Application process init
;
    BANKSEL PORTA
    movlw   0
;
; Application process loop
;
loop:
    xorlw   (1<<PORTA_RA2_POSITION) ; 1 cycle,  toggle PORTA, RA2 bit position
    movwf   PORTA                   ; 1 cycle,  write to PORTA
    goto    loop                    ; 2 cycles, loop takes 4 cycles total.
;     
    END     resetVec            ; Tell the linker the entry point