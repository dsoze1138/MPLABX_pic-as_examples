;
; File:     main.S
; Target:   PIC16F18313
; Author:   dan1138
; Date:     2020-10-19
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;    -Wl,-DCODE=2 -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
    PROCESSOR 16F18313
    PAGEWIDTH   132
    RADIX       DEC
;
#include <xc.inc>

; PIC16F18313 Configuration Bit Settings

config FEXTOSC = OFF    ; FEXTOSC External Oscillator mode Selection bits (Oscillator not enabled)
config RSTOSC = HFINT32 ; Power-up default value for COSC bits (HFINTOSC with 2x PLL (32MHz))
config CLKOUTEN = OFF   ; Clock Out Enable bit (CLKOUT function is disabled; I/O or oscillator function on OSC2)
config CSWEN = ON       ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
config FCMEN = ON       ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)
config MCLRE = ON       ; Master Clear Enable bit (MCLR/VPP pin function is MCLR; Weak pull-up enabled )
config PWRTE = OFF      ; Power-up Timer Enable bit (PWRT disabled)
config WDTE = OFF       ; Watchdog Timer Enable bits (WDT disabled; SWDTEN is ignored)
config LPBOREN = OFF    ; Low-power BOR enable bit (ULPBOR disabled)
config BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled)
config BORV = LOW       ; Brown-out Reset Voltage selection bit (Brown-out voltage (Vbor) set to 2.45V)
config PPS1WAY = OFF    ; PPSLOCK bit One-Way Set Enable bit (The PPSLOCK bit can be set and cleared repeatedly (subject to the unlock sequence))
config STVREN = ON      ; Stack Overflow/Underflow Reset Enable bit (Stack Overflow or Underflow will cause a Reset)
config DEBUG = OFF      ; Debugger enable bit (Background debugger disabled)
config WRT = OFF        ; User NVM self-write protection bits (Write protection off)
config LVP = ON         ; Low Voltage Programming Enable bit (Low voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored.)
config CP = OFF         ; User NVM Program Memory Code Protection bit (User NVM code protection disabled)
config CPD = OFF        ; Data NVM Memory Code Protection bit (Data NVM code protection disabled)
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
    movwf   WREG_save       ; This context saving and restore may 
    swapf   STATUS,W        ; not be required for the PIC16F18313
    movwf   STATUS_save     ; It's here as an example just in
    movf    PCLATH,W        ; case you need it.
    movwf   PCLATH_save
;
IsrHandler:
;
IsrExit:
    movf    PCLATH_save,W   ; This context saving and restore may
    movwf   PCLATH          ; not be required for the PIC16F18313
    swapf   STATUS_save,W   ; It's here as an example just in
    movwf   STATUS          ; case you need it.
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                  ; Return from interrupt
;
; Initialize the PIC hardware
;
Start:
    clrf    INTCON              ; Disable all interrupt sources
    banksel PIE0
    clrf    PIE1
    clrf    PIE2
    clrf    PIE3
    clrf    PIE4

    ; Make PORTA inputs
    banksel TRISA
    movlw   0b11111111         ;
    movwf   TRISA

    ; Set all ADC inputs for digital I/O
    banksel ANSELA
    movlw   0b00000000
    movwf   ANSELA

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
; Function to count 256
;
Count256:
    BANKSEL count
    clrf    BANKMASK(count)
Count256Loop:
    decfsz  BANKMASK(count),F
    goto    Count256Loop
    return
;
; Set PORTA bit 0 as an output then set low 
; spin loop for count of 256 then set high 
; and spin loop for count of 256 then loop.
;
main:
    BANKSEL TRISA
    bcf     BANKMASK(TRISA),TRISA_TRISA0_POSITION   ; Make PORTA bit RA0 an output
loop:
    BANKSEL PORTA
    bcf     BANKMASK(PORTA),PORTA_RA0_POSITION      ; Make PORTA bit RA0 LOW
    call    Count256
    bsf     BANKMASK(PORTA),PORTA_RA0_POSITION      ; Make PORTA bit RA0 HIGH
    call    Count256
    goto    loop
;
; Declare Power-On-Reset entry point
;
    END     resetVec