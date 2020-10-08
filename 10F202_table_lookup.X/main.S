;
; File:     main.S
; Target:   PIC10F202
; Author:   dan1138
; Date:     2020-07-25
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
;
;   Example project for the PIC10F202 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pStartCode=0h,-pTableInCode=1h,-pResetVec=1ffh,-Map=10F202_table_lookup.map
;
; Notes:
;   Needed to add the "-DCODE=2" parameter because the pic-as(v2.20) integration with the MPLABX IDE
;   still has bugs. See: https://www.microchip.com/forums/FindPost/1150913
;
    PROCESSOR   10F202
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Declare one byte in RAM
; 
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  Index
Index:    DS      1
;
; Table look up using a very odd implementation.
;
    global  Lookup
    PSECT   MainCode,class=CODE,delta=2
    global  Main
    global  Lookup
Main:
    movwf   OSCCAL
    clrf    Index
;
Loop:
    movlw   Lookup
    subwf   Index,W
    movlw   0x00        ; value when Index is for last entry in table
    btfsc   STATUS,STATUS_C_POSITION
    goto    Done
    movf    Index,W
    btfss   STATUS,STATUS_Z_POSITION
    call    Lookup
    btfsc   STATUS,STATUS_Z_POSITION
    movlw   0xFF        ; value when Index is for first entry in table
Done:
    incf    Index,F
    goto    Loop
