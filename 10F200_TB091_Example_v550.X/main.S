;' 
;' File:     main.S
;' Target:   PIC10F200
;' Author:   dan1138
;' Date:     2022-JUN-20
;' Compiler: pic-as(v2.35)
;' IDE:      MPLABX v5.50
;' 
;' Description:
;' 
;'  Example code for TB091
;'      https://ww1.microchip.com/downloads/en/Appnotes/91091A.pdf
;' 
;'  The code simulates an encoder with 256 "edges" per rotation.
;'  This is usually called a 64 count encoder.
;' 
;' 
;'                                 PIC10F200
;'                        +-----------:_:-----------+
;'                     -- : 1 N/C       NCLRn/GP3 8 : <- SW1/ICD_VPP
;'                 5v0 -> : 2 VDD             VSS 7 : <- GND
;'         Q_Out_Index <> : 3 GP2/T0CKI       N/C 6 : --
;' ICD_PGC/Q_Out_B     <> : 4 GP1/PGC     PGD/GP0 5 : <> Q_Out_A/ICD_PGD
;'                        +-------------------------+
;'                                   DIP-8
;' 
;'                                 PIC10F200
;'                        +-----------:_:-----------+
;'     ICD_PGD/Q_Out_A <> : 1 GP0/PGD   MCLRn/GP3 6 : <- SW1/ICD_VPP
;'                 GND -> : 2 VSS             VDD 5 : <- 5v0
;'     ICD_PGC/Q_Out_B <> : 3 GP1/PGC   T0CKI/GP2 4 : <> Q_Out_Index
;'                        +-------------------------+
;'                                   SOT-23
;' 
;' Add this line in the project properties box "pic-as Global Options -> Additional options": 
;' 
;'   -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=0ffh
;' 
    PROCESSOR   10F200
    PAGEWIDTH   132
    RADIX       dec
;' 
;' Include target specific definitions for special function registers
;' 
#include <xc.inc>
;' 
;' Set the configuration word
;' 
 config WDTE = OFF       ;' Watchdog Timer (WDT disabled)
 config CP = OFF         ;' Code Protect (Code protection off)
 config MCLRE = OFF      ;' Master Clear Enable (GP3/MCLR pin function is GPIO)
;' 
;' Declare RAM
;' 
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  QuadOut, QuadState, TMR0_State
QuadOut:    DS      1
QuadState:  DS      1
TMR0_State: DS      1
;' 
;' 
;' 
#define TMR0_ROLLOVER_BIT_MASK (1<<7)
;' 
;' Power On Reset startup code
;' 
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    movwf   OSCCAL      ;' Set factory default for the oscillator calibration

    movlw   11000000B   ;' TIMER0 clock is FOSC/4, prescale is 1:2
    option              ;' to turn off T0CKI

;' CMCON0 is at 07h, but it exists only for the PIC10F206
#ifdef CMCON0
    movlw   01110001B   ;' bit 3 to 0 for turning comparator off
    movwf   CMCON0
#endif

    movlw   11111000B   ;' set GP0,GP1,GP2 as outputs
    tris    GPIO
    goto    main
;' 
;' Lookup Quadrature output
;' 
LookUpGrayCode:
    movf    QuadState,W
    andlw   0x03
    addwf   PCL,F
    retlw   0
    retlw   1
    retlw   3
    retlw   2
;' 
;' Wait for TIMER0 rollover bit position to toggle
;' 
Delay:
    movf    TMR0,W
    xorwf   TMR0_State,W
    andlw   TMR0_ROLLOVER_BIT_MASK
    btfsc   STATUS,STATUS_Z_POSITION
    goto    Delay
    xorwf   TMR0_State,F
    retlw 0
;' 
;' Main application
;' 
main:
    clrf    QuadOut
    clrf    QuadState
    movf    TMR0,W
    andlw   TMR0_ROLLOVER_BIT_MASK
    movwf   TMR0_State
;' 
;' Application process loop
;' 
Loop:
    movf    QuadOut,W
    movwf   GPIO                ;' Update quadrature outputs
    movlw   -1                  ;' If SW1 pressed rotate Counter Clock Wise
    btfss   GPIO,3
    movlw   1                   ;' If SW1 released rotate Clock Wise
    addwf   QuadState,F         ;' Update quadrature state
    call    LookUpGrayCode
    movwf   QuadOut
    movf    QuadState,F
    btfsc   STATUS,STATUS_Z_POSITION
    bsf     QuadOut,2
    call    Delay
    goto    Loop
;' 
;' The PIC10F200 reset vector is the highest 
;' instruction word in the code space.
;' 
;' This is used to load the WREG with the factory 
;' oscillator calibration value then  the program 
;' counter rollover to zero to start the code.
;' 
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:

    end     ResetVector