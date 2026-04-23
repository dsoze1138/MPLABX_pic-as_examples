;
; File:     main.S
; Target:   PIC16f84A
; Author:   dan1138
; Date:     2025-05-19
; Compiler: pic-as(v3.00)
; IDE:      MPLABX v6.20
;
; Description:
;
;   Example project for the PIC16F84A controller using the pic-as(v3.00) tool chain.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-pPor_Vec=0h
;
;                           PIC16F84A
;                   +----------:_:----------+
;             <>  1 : RA2               RA1 : 18 <> 
;             <>  2 : RA3               RA0 : 17 <> 
;             <>  3 : RA4/T0CKI        OSC1 : 16 <- RC network (DS35007C-page 23)
;    ICSP_VPP ->  4 : MCLR             OSC2 : 15 -> Fosc/4
;         GND ->  5 : GND               VDD : 14 <- 5v0
;             <>  6 : RB0/INT       PGD/RB7 : 13 <> ICSP_PGD
;             <>  7 : RB1           PGC/RB6 : 12 <> ICSP_PGC
;             <>  8 : RB2               RB5 : 11 <> 
;             <>  9 : RB3               RB4 : 10 <> 
;                   +-----------------------:
;                            DIP-18

    PROCESSOR   16F84A
    PAGEWIDTH   132
    RADIX       DEC

#include <xc.inc>

; PIC16F84A Configuration Bit Settings

  CONFIG  FOSC = EXTRC      ; Oscillator Selection bits (RC oscillator)
  CONFIG  WDTE = OFF        ; Watchdog Timer (WDT disabled)
  CONFIG  PWRTE = OFF       ; Power-up Timer Enable bit (Power-up Timer is disabled)
  CONFIG  CP = OFF          ; Code Protection bit (Code protection disabled)

;objects in bank 0 memory
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  D1,D2,D3        ; make symbols visable in debugger view

D1:     DS      1
D2:     DS      1
D3:     DS      1

;
; Power-On-Reset entry point
;
    PSECT   Por_Vec,global,class=CODE,delta=2
resetVec:

    global  loop1, delay    ; make symbols visable in debugger view
loop1:
    clrw
    call delay
    goto loop1
 
delay:
    movlw 200
    movwf D3
    movlw 3
    movwf D2
    movlw 1
    movwf D1
    decfsz D1
    goto $-1
    decfsz D2
    goto $-5
    decfsz D3
    goto $-9
    return

    END     resetVec