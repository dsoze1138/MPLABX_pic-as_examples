
; Author: dan1138
; Target: PIC18F46K40
; 
; Created on May 16, 2021, 11:57 AM
; 
; For a confusing description of how XC8 passes parameters
; to an assembly language function see:
;
;     MPLAB® XC8 C Compiler User’s Guide for PIC, 
;     document number 50002737C, page 109 sections:
;      5.7.5  Function Parameters
;      5.7.5.1  Compiled Stack Parameters
;     
; extern void func(unsigned char arg1, unsigned char arg2);
;
#include <xc.inc>

    psect   func_code,local,class=CODE,reloc=2 ; PIC18

    global _func                ; The C compiler uses the _<name> to invoke the function.
    extrn  _func$1              ; This _<name>$1 symbol is defined somehow by the linker,
                                ; it is the address of the start of the argument list
                                ; for the Compiled Stack Parameters.
_func:
        movwf   LATA,c          ; arg1, byte in WREG
        movf    _func$1+0,w,c   ; arg2, byte in access RAM
        movwf   LATA,c
        return