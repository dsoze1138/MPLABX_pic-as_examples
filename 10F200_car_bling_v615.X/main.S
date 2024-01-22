;
; File:     main.S
; Target:   PIC10F200
; Author:   dan1138
; Date:     2024-JAN-22
; Compiler: pic-as(v2.45)
; IDE:      MPLABX v6.15
;
; Description:
;
;   Example project for the PIC10F200 controller using the pic-as(v2.45) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pResetVec=0ffh
;
; See: https://forum.microchip.com/s/topic/a5CV40000000FzxMAE/t393766
;
    PROCESSOR   10F200
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
  CONFIG  WDTE = OFF            ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF              ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON            ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
;
; Declare bytes in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Delay_ms, Delay_t0, Delta_t
Delay_ms:   DS  1
Delay_t0:   DS  1
Delta_t:    DS  1
;

;
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:
    movwf   OSCCAL      ;Set factory default for the oscillator calibration
    ;osccal register is at 05h

    movlw   0xC1        ; TIMER0 clock is FOSC/4, prescale 1:4
    option
    movlw   0x08        ;set GP0,GP1,GP2 to output direction
    tris    GPIO
    goto    Loop
;
; This delay functiion will spin for 1 to 256 milliseconds.
; TIMER0 is used to count elapse time. This is tricky to do
; with a baseline controller like a PIC10F200 as there are 
; no opcodes that can add or subtract constants from the WREG.
;
; Input:    WREG (delay 1 to 256 milliseconds)
; Output:   none
; Uses:     WREG
;           Delay_ms
;           Delay_0
;           Delat_t
; Returns:  WREG set to zero
;
Delay:
    movwf   Delay_ms        ; Save numberof milliseconds to delay
    movf    TMR0,W          ; Save the TIMER0 count
    movwf   Delay_t0        ; At start of delay
    movlw   250             ; Number of TIMER0 counts per milliscond
    movwf   Delta_t
Delay_loop:
    movf    Delay_t0,W      ; Find the numer of TIMER0 counts
    subwf   TMR0,W          ; since last sample.
    subwf   Delta_t,W       ; Check if TIMER0 has counted enough.
    btfsc   STATUS,STATUS_C_POSITION
    goto    Delay_loop      ; Loop if not long enough.
    movf    Delta_t,W
    addwf   Delay_t0,F      ; Adjust for next delay loop.
    decfsz  Delay_ms        ; Decrement delay count
    goto    Delay_loop      ; Loop if not delay enough.
    retlw   0               ; Exit delay
;
; Application loop
;
Loop:
; Left side
    movlw   GPIO_GP0_MASK   ; Left side on
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   0               ; Left side off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   GPIO_GP0_MASK   ; Left side on
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   0               ; Left side off
    movwf   GPIO
    movlw   150
    call    Delay
;
; Right side
    movlw   GPIO_GP1_MASK   ; Right side on
    movwf   GPIO
    movlw   250
    call    Delay

    movlw   0               ; Right side off
    movwf   GPIO
    movlw   150
    call    Delay
;
; Tail light
    movlw   GPIO_GP2_MASK   ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   GPIO_GP2_MASK   ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   GPIO_GP2_MASK   ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   GPIO_GP2_MASK   ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   150
    call    Delay

    goto    Loop        ;loop forever
;
; The PIC10F200 reset vector is the highest 
; instruction word in the code space.
;
; This is used to load the WREG with the factory 
; oscillator calibration value then  the program 
; counter rollover to zero to start the code.
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:

    end     ResetVector