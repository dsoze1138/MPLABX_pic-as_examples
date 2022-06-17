;
; File:     main.asm
; Target:   PIC12F1572
; Author:   dan1138
; Date:     2022-02-21
; Compiler: MPASMWIN v5.87
; IDE:      MPLABX v5.35
;
; Description:
;
;   Example project for the PIC12F1572 controller using the MPASMWIN v5.87 tool chain.
;
;   This application shows a bug in how the MPASMWIN v5.87 builds the opcode for the BRA statement.
;   Specifically here the branch target is out of reach. 
;   The assembler does assert an error diagnostic. 
;
; This is the output:
;
;   make -f nbproject/Makefile-default.mk SUBPROJECTS= .build-conf
;   make[1]: Entering directory 'C:/Public/GIT/Projects/PIC/MPLABXv5xx_pic-as_examples/12F1572_Example_MPASM_v535.X'
;   make  -f nbproject/Makefile-default.mk dist/default/production/12F1572_Example_MPASM_v535.X.production.hex
;   make[2]: Entering directory 'C:/Public/GIT/Projects/PIC/MPLABXv5xx_pic-as_examples/12F1572_Example_MPASM_v535.X'
;   "C:\PIC_dev\MPLABX\v5.35\mpasmx\mpasmx.exe" -q -p12f1572 -l"build/default/production/main.lst" -e"build/default/production/main.err" -o"build/default/production/main.o" "main.asm" 
;   "C:\PIC_dev\MPLABX\v5.35\mpasmx\mplink.exe"    -p12f1572  -w  -m"dist/default/production/12F1572_Example_MPASM_v535.X.production.map"   -z__MPLAB_BUILD=1  -odist/default/production/12F1572_Example_MPASM_v535.X.production.cof  build/default/production/main.o     
;   MPLINK 5.09, LINKER
;   Device Database Version 1.50
;   Copyright (c) 1998-2011 Microchip Technology Inc.
;   Error - file './build/default/production/main.o', section 'StartCode', Symbol ' out of range of relative branch instruction.
;   Errors    : 1
;   
;   make[2]: Leaving directory 'C:/Public/GIT/Projects/PIC/MPLABXv5xx_pic-as_examples/12F1572_Example_MPASM_v535.X'
;   make[1]: Leaving directory 'C:/Public/GIT/Projects/PIC/MPLABXv5xx_pic-as_examples/12F1572_Example_MPASM_v535.X'
;   make[2]: *** [nbproject/Makefile-default.mk:126: dist/default/production/12F1572_Example_MPASM_v535.X.production.hex] Error 1
;   make[1]: *** [nbproject/Makefile-default.mk:91: .build-conf] Error 2
;   make: *** [nbproject/Makefile-impl.mk:39: .build-impl] Error 2
;   
;   BUILD FAILED (exit value 2, total time: 2s)
;
;
    PROCESSOR   12F1572
    LIST        c=132,n=0
    LIST        r=dec
;
; Include target specific definitions for special function registers
;
#include <p12f1572.inc>
;
; Set the configuration word
;
; CONFIG1
; __config 0x39E4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_OFF & _STVREN_ON & _BORV_LO & _LPBOREN_OFF & _LVP_ON
;
; Reset vector
;
ResetVec    CODE 0x0000
    global  ResetVector
ResetVector:
    goto    Start
;
;   Data space use by interrupt handler to save context
Isr_data    UDATA
;
    GLOBAL  WREG_save,STATUS_save
;
WREG_save:      RES 1
STATUS_save:    RES 1
;
;   Interrupt vector and handler
Isr_vec     CODE    0x0004
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_save
    swapf   STATUS,W
    movwf   STATUS_save
;
IsrHandler:
;
IsrExit:
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                      ; Return from interrupt
;
; Simple test application 
;
StartCode   CODE
    global  Start
Start:
;
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x000 - 0x00F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x010 - 0x01F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x020 - 0x02F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x030 - 0x03F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x040 - 0x04F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x050 - 0x05F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x060 - 0x06F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x070 - 0x07F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x080 - 0x08F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x090 - 0x09F
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0A0 - 0x0AF
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0B0 - 0x0BF
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0C0 - 0x0CF
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0D0 - 0x0DF
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0E0 - 0x0EF
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 0x0F0 - 0x0FF
    bra     Start   ; This should be out of reach for the BRA statement but no error is asserted.
    goto    Start

    end
