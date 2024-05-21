;
; File:     main.S
; Target:   PIC16F84A
; Author:   dan1138
; Date:     2024-05-18
; Compiler: pic-as v2.45
; IDE:      MPLABX v6.15
;
; Add this line in the project properties box, pic-as Global Options -> Additional options:
;   -Wa,-a -Wl,-pPor_Vec=0h,-pIsr_Vec=4h
;
; Description:
;
;   Stopwatch, two digit multiplexed 7-segment LED displays
;   See: https://www.edaboard.com/threads/pic16f84a-seven-segment.410963/post-1773686
;
;                           PIC16F84A
;                   +----------:_:----------+
; (Digit2)EN2 <>  1 : RA2               RA1 : 18 <> EN1(Digit1)
; (Reset)BTN2 <>  2 : RA3               RA0 : 17 <> BTN1(Start/Stop)
;             <>  3 : RA4/T0CKI        OSC1 : 16 <- 4MHz crystal
;    ICSP_VPP ->  4 : MCLR             OSC2 : 15 -> 4MHz crystal
;         GND ->  5 : GND               VDD : 14 <- 5v0
;       LED_a <>  6 : RB0/INT       PGD/RB7 : 13 <> LED_dp /ICSP_PGD
;       LED_b <>  7 : RB1           PGC/RB6 : 12 <> LED_g  /ICSP_PGC
;       LED_c <>  8 : RB2               RB5 : 11 <> LED_f
;       LED_d <>  9 : RB3               RB4 : 10 <> LED_e
;                   +-----------------------:
;                            DIP-18

    PROCESSOR   16F84A
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; PIC16F84A Configuration Bit Settings
  CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator)
  CONFIG  WDTE = OFF            ; Watchdog Timer (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (Power-up Timer is disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Code protection disabled)
;
; Skip macros
;
skpndc  MACRO
    btfsc   STATUS,STATUS_DC_POSITION
        ENDM

skpdc   MACRO
    btfss   STATUS,STATUS_DC_POSITION
        ENDM
skpnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
        ENDM

skpc   MACRO
    btfss   STATUS,STATUS_C_POSITION
        ENDM

skpnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
        ENDM

skpz   MACRO
    btfss   STATUS,STATUS_Z_POSITION
        ENDM
;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
    global  resetVec
resetVec:
    goto    main
;
;   Data space use by interrupt handler to save context
    PSECT   Isr_Data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save,PCLATH_save
    GLOBAL  Segments
;
WREG_save:      ds      1
STATUS_save:    ds      1
PCLATH_save:    ds      1
Segments:       ds      2
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
    btfsc   INTCON,INTCON_TMR0IE_POSITION
    btfss   INTCON,INTCON_TMR0IF_POSITION
    goto    TMR0_Exit
TMR0_ISR:
    bcf     INTCON,INTCON_TMR0IF_POSITION
    pagesel TMR0_ISR
    banksel PORTB
    clrf    PORTB

    btfss   PORTA,2
    goto    TMR0_EN2
TMR0_EN1:
    bcf     PORTA,2
    bsf     PORTA,1
    movf    Segments+0,W
    goto    TMR0_Done
TMR0_EN2:
    bcf     PORTA,1
    bsf     PORTA,2
    movf    Segments+1,W
TMR0_Done:
    movwf   PORTB
TMR0_Exit:
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
;objects in bank 0 memory, note PIC16F84 does not have banked memory
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    GLOBAL  T0_Sample,TicksInTenthSecCount,TenthSecondCountBCD
    GLOBAL  LED_BCD
    GLOBAL  SW_Flags
    GLOBAL  BTN_sample,BTN_stable,BTN_change,BTN_bounce

T0_Sample:      ds      1
#define T0_COUNTS_PER_TICK 125
#define TICKS_PER_TENTH_SEC 25
TenthSecondCountBCD:  ds    2
TicksInTenthSecCount: ds    1
#define SW_Reset      SW_Flags,0
#define SW_RESET_MASK 0x01
#define SW_Start      SW_Flags,1
#define SW_START_MASK 0x02
SW_Flags:       ds      1
#define DEBOUNCE_COUNT  2
#define BTN1_POSITION   0
#define BTN1_MASK       0x01
#define BTN2_POSITION   1
#define BTN2_MASK       0x02
BTN_sample:     ds      1
BTN_stable:     ds      1
BTN_change:     ds      1
BTN_bounce:     ds      1
LED_BCD:        ds      1
;
; Applicaiton initialization
    PSECT   MainCode,global,class=CODE,delta=2
main:
    clrf    INTCON
    BANKSEL TRISB
    movlw   0x00
    movwf   TRISB
    movlw   0x09                ; RA0,RA3 inputs
    movwf   TRISA
    movlw   0x84                ; TMR0 clock source Fosc/4, TMR0 prescale 1:32
    movwf   OPTION_REG

    banksel TMR0
    clrf    TMR0
    clrf    T0_Sample
    movlw   TICKS_PER_TENTH_SEC
    movwf   TicksInTenthSecCount
    clrf    TenthSecondCountBCD+0
    clrf    TenthSecondCountBCD+1
    clrf    LED_BCD ; debug for simulator
    clrf    Segments+0
    clrf    Segments+1
    bcf     INTCON,INTCON_TMR0IF_POSITION
    bsf     INTCON,INTCON_TMR0IE_POSITION       ; enable 7-segment display multiplexing
    bsf     INTCON,INTCON_GIE_POSITION

    clrf    BTN_sample
    clrf    BTN_stable
    clrf    BTN_change
    clrf    BTN_bounce
    clrf    SW_Flags
;
; Applicaiton process loop
AppLoop:
    movf    T0_Sample,W
    subwf   TMR0,W
    sublw   T0_COUNTS_PER_TICK
    skpnc
    goto    AppLoop
    movlw   T0_COUNTS_PER_TICK
    addwf   T0_Sample,F
;
; debounce switches
    call    BTN_Poll
    iorlw   0
    skpnz               ; Skip is button changed state
    goto    Count4msTicks
;
; Process button inputs
    movf    BTN_stable,W
    andwf   BTN_change,F
    btfsc   BTN_change,BTN2_POSITION
    bsf     SW_Reset    ; buttin 2 changed to pressed
    movlw   SW_START_MASK
    btfsc   BTN_change,BTN1_POSITION
    xorwf   SW_Flags,F  ; buttin 1 changed to pressed
    clrf    BTN_change
;
; Process reset state
    btfss   SW_Reset
    goto    Count4msTicks
    clrf    TenthSecondCountBCD+0
    clrf    TenthSecondCountBCD+1
    clrf    LED_BCD ; debug for simulator
    bcf     SW_Reset
    bcf     SW_Start
Count4msTicks:
;
; count 4ms ticks
    decfsz  TicksInTenthSecCount,F
    goto    AppLoop
    movlw   TICKS_PER_TENTH_SEC
    movwf   TicksInTenthSecCount
;
; Show seconds
    swapf   TenthSecondCountBCD+0,W
    call    Lookup7seg
    xorwf   Segments+0,W
    andlw   0x7F
    xorwf   Segments+0,F
;
; Show tens of seconds
    movf    TenthSecondCountBCD+1,W
    call    Lookup7seg
    xorwf   Segments+1,W
    andlw   0x7F
    xorwf   Segments+1,F
;
; Process start state
    btfss   SW_Start
    goto    AppLoop
;
; count tenths of seconds in a packed 4-digit BCD array, LSD first
    clrf    FSR     ; debug for simulator
    incf    TenthSecondCountBCD+0,W
    addlw   0x06
    skpndc          ; debug for simulator
    incfsz  FSR     ; debug for simulator
    skpndc
    goto    IncBCD_CarryD0
    addlw   -0x06
    goto    IncBCD_B0done
IncBCD_CarryD0:
    addlw   0x60
    skpnc
    goto    IncBCD_CarryD1
    addlw   -0x60
IncBCD_B0done:
    movwf   TenthSecondCountBCD+0
    goto    IncBCD_done
IncBCD_CarryD1:
    movwf   TenthSecondCountBCD+0
    incf    TenthSecondCountBCD+1,W
    addlw   0x06
    skpndc
    goto    IncBCD_CarryD2
    addlw   -0x06
    goto    IncBCD_B1done
IncBCD_CarryD2:
    addlw   0x60
    skpnc
    goto    IncBCD_CarryD3
    addlw   -0x60
    goto    IncBCD_B1done
IncBCD_CarryD3:
    nop
IncBCD_B1done:
    movwf   TenthSecondCountBCD+1
IncBCD_done:
;
; Debug so simulator can show LED count in real time
    decfsz  FSR
    goto    AppLoop
    swapf   TenthSecondCountBCD+0,W
    andlw   0x0F
    movwf   FSR
    swapf   TenthSecondCountBCD+1,W
    andlw   0xF0
    iorwf   FSR,W
    movwf   LED_BCD
    goto    AppLoop
;
; poll buttons
; Returns: WREG = 0, no buttons changed
;          WREG = 1, buttons changed
BTN_Poll:
    clrw
    btfsc   PORTA,0
    iorlw   BTN1_MASK
    btfsc   PORTA,3
    iorlw   BTN2_MASK
    xorwf   BTN_sample,W
    skpnz
    goto    BTN_debounce
    xorwf   BTN_sample,F
    movlw   DEBOUNCE_COUNT
    movwf   BTN_bounce
    retlw   0
BTN_debounce:
    movf    BTN_bounce,F
    skpnz
    goto    BTN_debounce_done
    decfsz  BTN_bounce,F
    retlw   0
BTN_debounce_done:
    movf    BTN_sample,W
    xorwf   BTN_stable,W
    skpnz
    retlw   0
    iorwf   BTN_change,F
    xorwf   BTN_stable,F
    retlw   1
;
; Look up BCD to 7-segments
;
Lookup7seg:
    andlw   0x0F
    movwf   PCLATH
    xorlw   HIGH(BCD2SEG)
    xorwf   PCLATH,F
    xorwf   PCLATH,W
    addlw   LOW(BCD2SEG)
    skpnc
    incf    PCLATH,F
    movwf   PCL
;
BCD2SEG:
    retlw 0x3F  ; 0
    retlw 0x06  ; 1
    retlw 0x5B  ; 2
    retlw 0x4F  ; 3
    retlw 0x66  ; 4
    retlw 0x6D  ; 5
    retlw 0x7D  ; 6
    retlw 0x07  ; 7
    retlw 0x7F  ; 8
    retlw 0x67  ; 9
    retlw 0     ; A
    retlw 0     ; b
    retlw 0     ; C
    retlw 0     ; d
    retlw 0     ; E
    retlw 0     ; F

    END