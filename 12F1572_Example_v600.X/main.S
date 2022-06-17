;
; File:     main.S
; Target:   PIC12F1572
; Author:   dan1138
; Date:     2022-02-20
; Compiler: pic-as(v2.36)
; IDE:      MPLABX v6.00
;
; Description:
;
;   Example project for the PIC12F1572 controller using the pic-as(v2.36) tool chain.
;
;   This application shows a bug in how the pic-as(v2.36) builds the opcode for the BRA statement.
;   Specifically here the branch target is out of reach. This should cause the assember to
;   assert an error diagnostic. 
;
; This is the output:
;
;   CLEAN SUCCESSFUL (total time: 6ms)
;   make -f nbproject/Makefile-default.mk SUBPROJECTS= .build-conf
;   make[1]: Entering directory 'C:/Public/git/MPLABXv5xx_pic-as_examples/12F1572_Example_v600.X'
;   make  -f nbproject/Makefile-default.mk dist/default/production/12F1572_Example_v600.X.production.hex
;   make[2]: Entering directory 'C:/Public/git/MPLABXv5xx_pic-as_examples/12F1572_Example_v600.X'
;   "C:\Apps\PIC_Dev\MPLABXC\xc8\v2.36\pic-as\bin\pic-as.exe" -mcpu=PIC12F1572 -c \
;   -o build/default/production/main.o \
;   main.S \
;    -msummary=+mem,+psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pIsr_vec=4h
;   "C:\Apps\PIC_Dev\MPLABXC\xc8\v2.36\pic-as\bin\pic-as.exe" -mcpu=PIC12F1572 build/default/production/main.o \
;   -o dist/default/production/12F1572_Example_v600.X.production.hex \
;    -msummary=+mem,+psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -mcallgraph=std -Wl,-Map=dist/default/production/12F1572_Example_v600.X.production.map -mno-download-hex -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pIsr_vec=4h
;   
;   Psect Usage Map:
;   
;    Psect     | Contents | Memory Range  | Size
;   -----------|----------|---------------|-------------
;    ResetVec  |          | 0000h - 0000h |   1 word   
;    Isr_vec   |          | 0004h - 000Bh |   8 words  
;    StartCode |          | 000Ch - 010Dh | 102 words  
;   -----------|----------|---------------|-------------
;              |          |               |             
;    Isr_data  |          | 0020h - 0021h |   2 bytes  
;   -----------|----------|---------------|-------------
;    config    |          | 8007h - 8008h |   2 words  
;   -----------|----------|---------------|-------------
;   
;   
;   Memory Summary:
;       Program space        used   10Bh (   267) of   800h words   ( 13.0%)
;       Data space           used     2h (     2) of   100h bytes   (  0.8%)
;       EEPROM space         None available
;       Configuration bits   used     2h (     2) of     2h words   (100.0%)
;       ID Location space    used     0h (     0) of     4h bytes   (  0.0%)
;   
;   make[2]: Leaving directory 'C:/Public/git/MPLABXv5xx_pic-as_examples/12F1572_Example_v600.X'
;   make[1]: Leaving directory 'C:/Public/git/MPLABXv5xx_pic-as_examples/12F1572_Example_v600.X'
;   
;   BUILD SUCCESSFUL (total time: 765ms)
;   Loading code from C:/Public/git/MPLABXv5xx_pic-as_examples/12F1572_Example_v600.X/dist/default/production/12F1572_Example_v600.X.production.hex...
;   Program loaded with pack,PIC12-16F1xxx_DFP,1.3.90,Microchip
;   Loading completed
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pIsr_vec=4h
;
    PROCESSOR   12F1572
    PAGEWIDTH   132
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
; CONFIG1
  CONFIG  FOSC = INTOSC         ;  (INTOSC oscillator; I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  PLLEN = OFF           ; PLL Enable (4x PLL disabled)
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
  CONFIG  LPBOREN = OFF         ; Low Power Brown-out Reset enable bit (LPBOR is disabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable (Low-voltage programming enabled)
;
; Reset vector
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    goto    Start
;
;   Data space use by interrupt handler to save context
    PSECT   Isr_data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  WREG_save,STATUS_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
;
;   Interrupt vector and handler
    PSECT   Isr_vec,global,class=CODE,delta=2
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
    PSECT   StartCode,class=CODE,delta=2
    global  Start
Start:dw 0                             ; -256 (not reachable from BRA, pic-as(v2.xx) should produce a diagnostic message)
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -240 to -255
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -224 to -239
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -208 to -223
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -192 to -207
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -176 to -191
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -160 to -175
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -144 to -159
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -128 to -143
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; -112 to -127
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -96 to -111
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -80 to -95
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -64 to -79
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -48 to -63
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -32 to -47
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  -16 to -31
    dw   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;   -1 to -15
    bra     Start   ; This should be out of reach for the BRA statement but no error is asserted.
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;   +1 to +16
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +17 to +32
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +33 to +48
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +49 to +64
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +65 to +80
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +81 to +96
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;  +97 to +112
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +113 to +128
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +129 to +144
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +145 to +160
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +161 to +176
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +177 to +192
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +193 to +208
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +209 to +224
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; +225 to +240
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; +241 to +255
    dw 0 ; assembler bug branches here
    goto    Start

    end     ResetVector