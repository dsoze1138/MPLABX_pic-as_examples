;
; File:     main.S
; Target:   PIC12F675
; Author:   dan1138
; Date:     2026-04-23
; Compiler: pic-as(v3.10)
; IDE:      MPLABX v6.60
;
; Description:
;
;   Example project for the PIC12F675 controller using the pic-as(v2.41) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h,-pFacConst=3ffh
;
;                          PIC12F675
;              +-------------:_:-------------+
;     GND -> 1 : VDD                     VSS : 8 <- 5v0
;         <> 2 : GPIO5/T1CKI   PGD/AN0/GPIO0 : 7 <> PGD 
;         <> 3 : GPIO4/AN3     PGC/AN1/GPIO1 : 6 <> PGC 
;     VPP -> 4 : GPIO3/VPP     INT/AN2/GPIO2 : 5 <>
;              +-----------------------------:
;                           DIP-8

    PROCESSOR   12F675
    PAGEWIDTH   132
    RADIX       DEC


; PIC12F675 Configuration Bit Settings

; Assembly source line config statements
; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
  CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)

// config statements should precede project file includes.
#include <xc.inc>

#define _XTAL_FREQ 4000000
#define FCY (_XTAL_FREQ/4)

;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec,start,start2
resetVec:
    btfsc   STATUS,STATUS_RP0_POSITION  ; skip if we have not tried to get the calibration value
    goto    start2                      ; branch if calibration value not availablee
    goto    start               ;jump to the start up routine

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
    banksel STATUS_save
    movwf   STATUS_save
    movf    PCLATH,W
    movwf   PCLATH_save
    pagesel IsrVec
;
;
    movf    PCLATH_save,W
    movwf   PCLATH
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                      ; Return from interrupt
;
; Get the facyory Fosc calibration constant
start:
    bsf     STATUS,STATUS_RP0_POSITION
    call    GetFactoryCal       ; get the calibration value
    movwf   OSCCAL              ; calibrate internal oscillator
start2:
    PAGESEL main                ; Start main application
    goto    main
;
; 
; Initialize main application
    PSECT   MainCode,global,class=CODE,delta=2
main:
    clrf    INTCON              ;starting point
    BANKSEL TRISIO
    movlw   0xFF
    movwf   TRISIO              ; Make GPIO inputs
    bsf     OPTION_REG,OPTION_REG_PSA_POSITION  ; assign prescaker to WDT
    bcf     OPTION_REG,OPTION_REG_T0CS_POSITION ; assign Fosc/4 as TIMER0 clock source
    BANKSEL ANSEL
    clrf    ANSEL               ; Trun off ADC analog inputs
    BANKSEL CMCON
    movlw   0x07
    movwf   CMCON               ; Turn off comparator analog inputs
;
; Application process init
;
    bsf     INTCON,INTCON_T0IE_POSITION
    bsf     INTCON,INTCON_GIE_POSITION
;
; Application process loop
;
loop:
    goto    loop                    ; 2 cycles, loop takes 4 cycles total.
;     
;
;   Factory Fosc callibration value in RETLW
    PSECT   FacConst,global,class=CODE,delta=2
    GLOBAL  GetFactoryCal
GetFactoryCal:

    END     resetVec            ; Tell the linker the entry point