;
; File:     main_abs.asm
; Target:   PIC10F200
; Author:   dan1138
; Date:     2024-JAN-22
; Compiler: MPASMWIN(v5.51)
; IDE:      MPLAB v8.92
;
; Description:
;
;   Example project for the PIC10F200 controller using the MPASM tool chain.
;
; See: https://forum.microchip.com/s/topic/a5CV40000000FzxMAE/t393766
;
    PROCESSOR   10F200
    LIST        n=0,c=132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <p10f200.inc>
;
; Set the configuration word
;
  __CONFIG _WDTE_OFF & _CP_OFF & _MCLRE_ON
  
  
;
; Declare bytes in RAM
;
    CBLOCK  0x10
    
Delay_ms:   1
Delay_t0:   1
Delta_t:    1
;
    ENDC
;
    org    0x00

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
    btfsc   STATUS,C
    goto    Delay_loop      ; Loop if not long enough.
    movf    Delta_t,W
    addwf   Delay_t0,F      ; Adjust for next delay loop.
    decfsz  Delay_ms,F      ; Decrement delay count
    goto    Delay_loop      ; Loop if not delay enough.
    retlw   0               ; Exit delay
;
; Application loop
;
Loop:
; Left side
    movlw   (1<<GP0)        ; Left side on
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   0               ; Left side off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   (1<<GP0)        ; Left side on
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   0               ; Left side off
    movwf   GPIO
    movlw   150
    call    Delay
;
; Right side
    movlw   (1<<GP1)        ; Right side on
    movwf   GPIO
    movlw   250
    call    Delay

    movlw   0               ; Right side off
    movwf   GPIO
    movlw   150
    call    Delay
;
; Tail light
    movlw   (1<<GP2)        ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   (1<<GP2)        ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   (1<<GP2)        ; Tail light on
    movwf   GPIO
    movlw   50
    call    Delay

    movlw   0               ; Tail light off
    movwf   GPIO
    movlw   100
    call    Delay

    movlw   (1<<GP2)        ; Tail light on
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
    org    0xFF

ResetVector:

    end
