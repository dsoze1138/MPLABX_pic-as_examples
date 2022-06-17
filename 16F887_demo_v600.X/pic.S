;
; File:     pic.S
; Target:   PIC16F887
; Author:   dan1138
; Date:     2022-03-31
; Compiler: pic-as(v2.35)
; IDE:      MPLABX v6.00
;
; Add this line in the project properties box,pic-as Global Options -> Additional options:
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h,-pedata=2100h
;
    PROCESSOR   16F887
    PAGEWIDTH   132
    RADIX       DEC
;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F887. This file contains the basic code               *
;   building blocks to build upon.                                    *
;                                                                     *
;   Refer to the MPLAB® XC8 PIC® Assembler User's Guide for mode      *
;   information on features of the assembler (Document DS50002974B).  *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:      pic.S                                             *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: xc.inc                                           *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


#include <xc.inc>


; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin,I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O,HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR21V        ; Brown-out Reset Selection bit (Brown-out Reset set to 2.1V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

;**********************************************************************
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    PAGESEL main
    goto    main
;
;   Glogal Data space 
    PSECT   Common_Data,global,class=COMMON,space=1,delta=1,noexec
;
    GLOBAL  w_temp,status_temp,pclath_temp
;
DISPLAY_U:      DS      1
DISPLAY_D:      DS      1
VAR:            DS      1
w_temp:         DS      1        ; variable used for context saving
status_temp:    DS      1        ; variable used for context saving
pclath_temp:    DS      1        ; variable used for context saving
;
;   Interrupt vector and handler
    PSECT   Isr_Vec,global,class=CODE,delta=2
    GLOBAL  IsrVec
;
IsrVec:
    movwf   w_temp            ; save off current W register contents
    movf    STATUS,w          ; move status register into W register
    movwf   status_temp       ; save off contents of STATUS register
    movf    PCLATH,w      ; move pclath register into w register
    movwf   pclath_temp   ; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere
    
    btfss   PIR1,PIR1_ADIF_POSITION
    goto    AD_INT_FIM
    bcf     PIR1,PIR1_ADIF_POSITION
    rrf     ADRESH,F
    bcf     ADRESH,1       ; 7
    movf    ADRESH,W
    call    TABELA
    movwf   VAR
    sublw   0b00100101      ;25 em bcd,respetivo aos 2.5V
    btfss   STATUS,STATUS_Z_POSITION ;flag z,testar se ativou
    goto    AD_INT_FIM
    movlw   0b00111001      ;39 em bcd,respetivo aos nossos números de alunos
    movwf   VAR
    
    
AD_INT_FIM:
    
    btfss   INTCON,INTCON_INTF_POSITION
    goto    FIM_INT
    bcf     INTCON,INTCON_INTF_POSITION
    bsf     ADCON0,ADCON0_GO_POSITION
    
FIM_INT:

    movf    pclath_temp,w     ; retrieve copy of PCLATH register
    movwf   PCLATH            ; restore pre-isr PCLATH register contents
    movf    status_temp,w     ; retrieve copy of STATUS register
    movwf   STATUS            ; restore pre-isr STATUS register contents
    swapf   w_temp,f
    swapf   w_temp,w          ; restore pre-isr W register contents
    retfie                    ; return from interrupt

;
; Main application code
;
    PSECT   MainCode,global,class=CODE,delta=2
main:
    bsf     STATUS,STATUS_RP1_POSITION
    bsf     STATUS,STATUS_RP0_POSITION
    bsf     ANSEL,ANSEL_ANS0_POSITION
    bcf     ANSELH,ANSELH_ANS12_POSITION
    
    bcf     STATUS,STATUS_RP1_POSITION
    bsf     STATUS,STATUS_RP0_POSITION
    clrf    TRISC
    bsf     PIE1,PIE1_ADIE_POSITION
    
    bcf     STATUS,STATUS_RP0_POSITION
    movlw   0b00000001 
    movwf   ADCON0
    bcf     PIR1,PIR1_ADIF_POSITION
    bsf     INTCON,INTCON_INTE_POSITION
    bcf     INTCON,INTCON_INTF_POSITION
    bsf     INTCON,INTCON_PEIE_POSITION
    bsf     INTCON,INTCON_GIE_POSITION
    
    clrf    VAR
loop:
    ;  VAR = U U U U  D D D D 
    ;PORTC = 1 0 X X  D D D D
    movf    VAR,W
    movwf   DISPLAY_D
    bsf     DISPLAY_D,1; 7
    bcf     DISPLAY_D,0; 6
    movf    DISPLAY_D,W
    movwf   PORTC
    
    ;PORTC = 0 1 X X  U U U U
    movf    VAR,W
    movwf   DISPLAY_U
    swapf   DISPLAY_U,F
    bcf     DISPLAY_U,1; 7
    bsf     DISPLAY_U,0; 6
    movf    DISPLAY_U,W
    movwf   PORTC
    
    GOTO loop

; remaining code goes here

TABELA:
    addwf PCL,f 
    RETLW 0x0
    RETLW 0x0
    RETLW 0x1
    RETLW 0x1
    RETLW 0x2
    RETLW 0x2
    RETLW 0x2
    RETLW 0x3
    RETLW 0x3
    RETLW 0x4
    RETLW 0x4
    RETLW 0x4
    RETLW 0x5
    RETLW 0x5
    RETLW 0x5
    RETLW 0x6
    RETLW 0x6
    RETLW 0x7
    RETLW 0x7
    RETLW 0x7
    RETLW 0x8
    RETLW 0x8
    RETLW 0x9
    RETLW 0x9
    RETLW 0x9
    RETLW 0x10
    RETLW 0x10
    RETLW 0x11
    RETLW 0x11
    RETLW 0x11
    RETLW 0x12
    RETLW 0x12
    RETLW 0x13
    RETLW 0x13
    RETLW 0x13
    RETLW 0x14
    RETLW 0x14
    RETLW 0x14
    RETLW 0x15
    RETLW 0x15
    RETLW 0x16
    RETLW 0x16
    RETLW 0x16
    RETLW 0x17
    RETLW 0x17
    RETLW 0x18
    RETLW 0x18
    RETLW 0x18
    RETLW 0x19
    RETLW 0x19
    RETLW 0x20
    RETLW 0x20
    RETLW 0x20
    RETLW 0x21
    RETLW 0x21
    RETLW 0x21
    RETLW 0x22
    RETLW 0x22
    RETLW 0x23
    RETLW 0x23
    RETLW 0x23
    RETLW 0x24
    RETLW 0x24
    RETLW 0x25
    RETLW 0x25
    RETLW 0x25
    RETLW 0x26
    RETLW 0x26
    RETLW 0x27
    RETLW 0x27
    RETLW 0x27
    RETLW 0x28
    RETLW 0x28
    RETLW 0x29
    RETLW 0x29
    RETLW 0x29
    RETLW 0x30
    RETLW 0x30
    RETLW 0x30
    RETLW 0x31
    RETLW 0x31
    RETLW 0x32
    RETLW 0x32
    RETLW 0x32
    RETLW 0x33
    RETLW 0x33
    RETLW 0x34
    RETLW 0x34
    RETLW 0x34
    RETLW 0x35
    RETLW 0x35
    RETLW 0x36
    RETLW 0x36
    RETLW 0x36
    RETLW 0x37
    RETLW 0x37
    RETLW 0x38
    RETLW 0x38
    RETLW 0x38
    RETLW 0x39
    RETLW 0x39
    RETLW 0x39
    RETLW 0x40
    RETLW 0x40
    RETLW 0x41
    RETLW 0x41
    RETLW 0x41
    RETLW 0x42
    RETLW 0x42
    RETLW 0x43
    RETLW 0x43
    RETLW 0x43
    RETLW 0x44
    RETLW 0x44
    RETLW 0x45
    RETLW 0x45
    RETLW 0x45
    RETLW 0x46
    RETLW 0x46
    RETLW 0x46
    RETLW 0x47
    RETLW 0x47
    RETLW 0x48
    RETLW 0x48
    RETLW 0x48
    RETLW 0x49
    RETLW 0x49
    RETLW 0x50


; example of preloading EEPROM locations
    psect	edata,global,class=EEDATA,space=3,delta=2,noexec
    DB  5,4,3,2,1

    END     resetVec            ; directive 'end of program'
