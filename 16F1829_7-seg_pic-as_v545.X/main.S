;
; File:     main.S
; Target:   PIC16F1829
; Author:   dan1138
; Date:     2021-01-13
; Compiler: pic-as(v2.31)
; IDE:      MPLABX v5.45
;
;
;                               PIC16F1829
;                    +-------------:_:-----------+
;          5v0 ->  1 : VDD                   VSS : 20 <- GND
;              <>  2 : RA5/CPP2      PGD/AN0/RA0 : 19 <> ICD_PGD
;          POT <>  3 : RA4/AN3       PGC/AN1/RA1 : 18 <> ICD_PGC
;     ICD_MCLR ->  4 : RA3/MCLR     CCP3/AN2/RA2 : 17 <> SWn
;        SEG_F <>  5 : RC5/CPP1          AN4/RC0 : 16 <> SEG_A
;        SEG_E <>  6 : RC4               AN5/RC1 : 15 <> SEG_B
;        SEG_D <>  7 : RC3/AN7           AN6/RC2 : 14 <> SEG_C
;        SEG_G <>  8 : RC6/AN8      SDI/AN10/RB4 : 13 <> DIGIT1
;       SEG_DP <>  9 : RC7/AN9/SDO   RX/AN11/RB5 : 12 <> DIGIT2
;       DIGIT4 <> 10 : RB7/TX            SCK/RB6 : 11 <> DIGIT3
;                    +---------------------------+
;                                DIP-20
;
; Description:
;
;   Code tested using the DM164130-9 PICkit 3 Low Pin Count Demo Board.
;
;   This is code to demonstrate one method to multiplex
;   two digits in two 7-segment LED displays.
;
;   For a common cathode LED display:
;     A segment is ON when the SEG(A-G) output is HIGH.
;
;     A digit is on when the DIGIT(1,2,3,4) output is HIGH.
;     Only one DIGIT output can be HIGH at a time.
;
;
;   For a common anode LED display:
;     A segment is ON when the SEG(A-G) output is LOW.
;
;     A digit is on when the DIGIT(1,2,3,4) output is LOW.
;     Only one DIGIT output can be LOW at a time.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options:
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
    PROCESSOR   16F1829
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Memory Code Protection (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
  CONFIG  IESO = ON             ; Internal/External Switchover (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is disabled)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  PLLEN = OFF           ; PLL Enable (4x PLL disabled)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)
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
    GLOBAL  WREG_Save,STATUS_Save,PCLATH_Save,Segments,Tick
;
WREG_Save:   DS 1
STATUS_Save: DS 1
PCLATH_Save: DS 1
Segments:    DS 4
Tick:        DS 1
;
;   Interrupt vector and handler
    PSECT   Isr_Vec,global,class=CODE,delta=2
;
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_Save
    movf    STATUS,W
    movwf   STATUS_Save
    movf    PCLATH,W
    movwf   PCLATH_Save

    pagesel $
    btfsc   INTCON,INTCON_TMR0IE_POSITION
    btfss   INTCON,INTCON_TMR0IF_POSITION
    goto    ISR_EXIT
    bcf     INTCON,INTCON_TMR0IF_POSITION
    movf    Tick,W
    skipz
    decf    Tick,F

#ifdef LED_COMMON_CATHODE    
    banksel LATB
    movlw   0x00
    movwf   LATC                    ; Turn off all LED segments
    movlw   (1<<4)
    btfsc   LATB,7
    movlw   (1<<6)                  ; if DIGIT4 was on select DIGIT3
    btfsc   LATB,6
    movlw   (1<<5)                  ; if DIGIT3 was on select DIGIT2
    btfsc   LATB,5
    movlw   (1<<4)                  ; if DIGIT2 was on select DIGIT1
    btfsc   LATB,4
    movlw   (1<<7)                  ; if DIGIT1 was on select DIGIT4
    movwf   LATB                    ; Select LED display to be on

    btfsc   LATB,4
    movf    Segments+0,W            ; Load DIGIT1 segments for display
    btfsc   LATB,5
    movf    Segments+1,W            ; Load DIGIT2 segments for display
    btfsc   LATB,6
    movf    Segments+2,W            ; Load DIGIT3 segments for display
    btfsc   LATB,7
    movf    Segments+3,W            ; Load DIGIT4 segments for display
    xorwf   LATC                    ; Turn on LED segments for selected digit
#else
    banksel LATB
    movlw   0xFF
    movwf   LATC                    ; Turn off all LED segments
    movlw   ~(1<<4)
    btfss   LATB,7
    movlw   ~(1<<6)                 ; if DIGIT4 was on select DIGIT3
    btfss   LATB,6
    movlw   ~(1<<5)                 ; if DIGIT3 was on select DIGIT2
    btfss   LATB,5
    movlw   ~(1<<4)                 ; if DIGIT2 was on select DIGIT1
    btfss   LATB,4
    movlw   ~(1<<7)                 ; if DIGIT1 was on select DIGIT4
    movwf   LATB                    ; Select LED display to be on

    btfss   LATB,4
    movf    Segments+0,W            ; Load DIGIT1 segments for display
    btfss   LATB,5
    movf    Segments+1,W            ; Load DIGIT2 segments for display
    btfss   LATB,6
    movf    Segments+2,W            ; Load DIGIT3 segments for display
    btfss   LATB,7
    movf    Segments+3,W            ; Load DIGIT4 segments for display
    xorwf   LATC                    ; Turn on LED segments for selected digit
#endif
ISR_EXIT:
    movf    PCLATH_Save,W
    movwf   PCLATH
    movf    STATUS_Save,W
    movwf   STATUS
    swapf   WREG_Save,F
    swapf   WREG_Save,W
    RETFIE
;
; Initialize the PIC hardware
;
    PSECT   StartCode,global,class=CODE,delta=2
;
    GLOBAL  Start
;
Start:
    clrf    INTCON
    banksel PIE1
    clrf    PIE1
    clrf    PIE2
    clrf    PIE3
    clrf    PIE4

    banksel OPTION_REG
    movlw   0xFF
    movwf   OPTION_REG

    banksel OSCCON                  ; Setup 32MHz system oscillator
    movlw   0xF0
    movwf   OSCCON
;
; Setup GPIO ports
;
    banksel LATA
    clrf    LATA
    clrf    LATB
    clrf    LATC
    banksel TRISA
    movlw   0xFF
    movwf   TRISA
    clrf    TRISB
    clrf    TRISC
    banksel ANSELA
    movlw   0xFF
    movwf   ANSELA                  ; make PORTA analog inputs
    bcf     ANSELA,ANSELA_ANSA2_POSITION ; Make SWn a digital input
    clrf    ANSELB                  ; make PORTB digital I/O
    clrf    ANSELC                  ; make PORTC digital I/O
;
; Setup TIMER0 to interrupt every 1.024 milliseconds
; when the system oscillator is 32MHz.
;
    banksel OPTION_REG
    bcf     OPTION_REG,OPTION_REG_TMR0CS_POSITION
    bcf     OPTION_REG,OPTION_REG_PSA_POSITION
    bcf     OPTION_REG,OPTION_REG_PS0_POSITION
    bcf     OPTION_REG,OPTION_REG_PS1_POSITION
    banksel TMR0
    clrf    TMR0
    bcf     INTCON,INTCON_TMR0IF_POSITION
    bsf     INTCON,INTCON_TMR0IE_POSITION
;
; Turn on interrupts
;
    bsf     INTCON,INTCON_GIE_POSITION

    pagesel main
    goto    main
;
; Main application data
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  DecimalPosition,Delay
;
DecimalPosition:    DS  1
Delay: DS 1
Count: ds 2
;
; Main application code
;
    PSECT   MainCode,global,class=CODE,delta=2
;
    GLOBAL  main
;
main:
;
; Setup application data
;
    banksel Delay
    movlw   4
    movwf   Delay
    clrf    Count+0
    clrf    Count+1
;
; Application process loop
;
AppLoop:
    movf    Tick,W
    skipz
    goto    AppLoop
    movlw   244
    movwf   Tick
;
; Chase decimal point through the digits
;
    movf    DecimalPosition,W
    addwf   DecimalPosition,F
    btfsc   DecimalPosition,4
    bsf     DecimalPosition,0
    bcf     Segments+0,7
    btfsc   DecimalPosition,0
    bsf     Segments+0,7
    bcf     Segments+1,7
    btfsc   DecimalPosition,1
    bsf     Segments+1,7
    bcf     Segments+2,7
    btfsc   DecimalPosition,2
    bsf     Segments+2,7
    bcf     Segments+3,7
    btfsc   DecimalPosition,3
    bsf     Segments+3,7
;
    decfsz  Delay,F
    goto    AppLoop
    movlw   4
    movwf   Delay
;
; Show HEX count in LED displays
;
    movf    Count+0,W
    call    Hex2Segments
    movwf   Segments+3
    swapf   Count+0,W
    call    Hex2Segments
    movwf   Segments+2
    movf    Count+1,W
    call    Hex2Segments
    movwf   Segments+1
    swapf   Count+1,W
    call    Hex2Segments
    movwf   Segments+0

    btfsc   DecimalPosition,0
    bsf     Segments+0,7
    btfsc   DecimalPosition,1
    bsf     Segments+1,7
    btfsc   DecimalPosition,2
    bsf     Segments+2,7
    btfsc   DecimalPosition,3
    bsf     Segments+3,7

    incfsz  Count+0,F
    goto    AppLoop
    incf    Count+1,F
    goto    AppLoop
;
; Function: Hex2Segments
;
; Input: WREG = LED segment table lookup index
;               Range: 0x00 to 0x0F
;
; Output WREG = 7 low bits are LED segments gfedcba
;
Hex2Segments:
    andlw   0x0F
    xorlw   HIGH(SegTable)
    movwf   PCLATH
    xorlw   HIGH(SegTable)
    xorwf   PCLATH,F
    addlw   LOW(SegTable)
    skipnc
    incf    PCLATH,F
    movwf   PCL

SegTable:
    RETLW   0b00111111  ; mask for digit 0
    RETLW   0b00000110  ; mask for digit 1
    RETLW   0b01011011  ; mask for digit 2
    RETLW   0b01001111  ; mask for digit 3
    RETLW   0b01100110  ; mask for digit 4
    RETLW   0b01101101  ; mask for digit 5
    RETLW   0b01111101  ; mask for digit 6
    RETLW   0b00000111  ; mask for digit 7
    RETLW   0b01111111  ; mask for digit 8
    RETLW   0b01101111  ; mask for digit 9
    RETLW   0b01110111 
    RETLW   0b01111100 
    RETLW   0b00111001 
    RETLW   0b01011110 
    RETLW   0b01111001 
    RETLW   0b01110001  
;
; Declare Power-On-Reset entry point
;
    END     resetVec
