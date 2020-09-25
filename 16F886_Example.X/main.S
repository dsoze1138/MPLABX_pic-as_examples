;
; File:     main.S
; Target:   PIC16F886
; Author:   dan1138
; Date:     2020-09-08
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC16F886 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options:
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
    PROCESSOR   16F886
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; CONFIG1
 config FOSC = INTRC_NOCLKOUT; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
 config WDTE = OFF       ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
 config PWRTE = OFF      ; Power-up Timer Enable bit (PWRT disabled)
 config MCLRE = ON       ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
 config CP = OFF         ; Code Protection bit (Program memory code protection is disabled)
 config CPD = OFF        ; Data Code Protection bit (Data memory code protection is disabled)
 config BOREN = OFF      ; Brown Out Reset Selection bits (BOR disabled)
 config IESO = OFF       ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
 config FCMEN = OFF      ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
 config LVP = OFF        ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
 config BOR4V = BOR21V   ; Brown-out Reset Selection bit (Brown-out Reset set to 2.1V)
 config WRT = OFF        ; Flash Program Memory Self Write Enable bits (Write protection off)

;
; Define macros to help with
; bank selection
;
#define BANK0  (0x000)
#define BANK1  (0x080)
#define BANK2  (0x100)
#define BANK3  (0x180)
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
; Initialize the PIC hardware
;
Start:
    clrf    INTCON              ; Disable all interrupt sources
    banksel BANK1
    clrf    PIE1
    clrf    PIE2

    movlw   0b01100000
    movwf   OSCCON              ; Set internal oscillator at 4MHz

    movlw   0b10000001          ; Pull-ups off, INT edge high to low, WDT prescale 1:1
    movwf   OPTION_REG          ; TMR0 clock edge low to high, TMR0 clock = FCY, TMR0 prescale 1:4
                                ; TIMER0 will assert the overflow flag every 256*4 (1024)
                                ; instruction cycles, with a 4MHz oscilator this ia 1.024 milliseconds.

    movlw   0b11111111         ;
    movwf   TRISA

    movlw   0b11111111         ;
    movwf   TRISB

    movlw   0b11111111         ;
    movwf   TRISC

    ; Set all ADC inputs for digital I/O
    banksel BANK3
    movlw   0b00000000
    movwf   ANSEL
    movlw   0b00000000
    movwf   ANSELH
    banksel BANK2
    clrf    CM1CON0             ; turn off comparator
    clrf    CM2CON0             ; turn off comparator
    banksel BANK1
    movlw   0b00000000
    movwf   ADCON1
    clrf    VRCON               ; turn off voltage reference
    banksel BANK0
    movlw   0b10000000
    movwf   ADCON0

    pagesel main
    goto    main
;
; Main application data
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  count
count:  DS      1               ;reserve 1 byte for TOMER0 rollover count
;
; Main application code
;
    PSECT   MainCode,global,class=CODE,delta=2
;
; Function to Wait for TIMER0 to rollover 250 times
;
WaitOnTimer0:
    movlw   250
    BANKSEL count
    movwf   BANKMASK(count)
WaitT0a:
    bcf     INTCON,INTCON_TMR0IF_POSITION
WaitT0b:
    btfss   INTCON,INTCON_TMR0IF_POSITION
    goto    WaitT0b
    decfsz  BANKMASK(count),F
    goto    WaitT0a
    return
;
; Set PORTA bit 0 as an output then set low wait
; for 250 rollovers of TIMER0 and set hihg and
; wait another 250 rollovers of TIMER0 then loop
;
main:
    BANKSEL TRISA
    bcf     BANKMASK(TRISA),TRISA_TRISA0_POSITION   ; Make PORTA bit RA0 an output
loop:
    BANKSEL PORTA
    bcf     BANKMASK(PORTA),PORTA_RA0_POSITION      ; Make PORTA bit RA0 LOW
    call    WaitOnTimer0
    bsf     BANKMASK(PORTA),PORTA_RA0_POSITION      ; Make PORTA bit RA0 HIGH
    call    WaitOnTimer0
    goto    loop
;
; Declare Power-On-Reset entry point
;
    END     resetVec