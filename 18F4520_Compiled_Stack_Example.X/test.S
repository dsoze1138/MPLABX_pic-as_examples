; 
; Code example from section 6.  Compiled Stack Example
;
; From document: http://ww1.microchip.com/downloads/en/DeviceDoc/XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-presetVec=0h,-pudata_acs=0 -Wl,-Map=test.map -mcallgraph=full
;
; History:
;   2020-AUG-08: Workaround assembler bug with configuration word settings.
;
    PROCESSOR 18F4520
;
#include <xc.inc>
;
; PIC18F4520 Configuration Bit Settings
;
 config OSC = INTIO67    ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
 config FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
 config IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)
 config PWRT = OFF       ; Power-up Timer Enable bit (PWRT disabled)
 config BOREN = SBORDIS  ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
 config BORV = 3         ; Brown Out Reset Voltage bits (Minimum setting)
 config WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
 config WDTPS = 15 ;32768; Watchdog Timer Postscale Select bits (1:32768)
 config CCP2MX = PORTC   ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
 config PBADEN = OFF     ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
 config LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
 config MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
 config STVREN = ON      ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
 config LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
 config XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))
 config CP0 = OFF        ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
 config CP1 = OFF        ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
 config CP2 = OFF        ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
 config CP3 = OFF        ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)
 config CPB = OFF        ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
 config CPD = OFF        ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)
 config WRT0 = OFF       ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
 config WRT1 = OFF       ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
 config WRT2 = OFF       ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
 config WRT3 = OFF       ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)
 config WRTC = OFF       ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
 config WRTB = OFF       ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
 config WRTD = OFF       ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)
 config EBTR0 = OFF      ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
 config EBTR1 = OFF      ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
 config EBTR2 = OFF      ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
 config EBTR3 = OFF      ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)
 config EBTRB = OFF      ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)
;
; This C code represents the assembly language implemented in this file:
;
;   int add(int a, int b) {
;       return a + b;
;   }
;   void write(int val) {
;       LATA = val;
;       LATB = val >> 8;
;   }
;   int result, incr;
;   void main(void) {
;       result = 0;
;       incr = 2;
;       while(1) {
;           result = add(result, incr);
;           write(result);
;           incr++;
;       }
;   }
;
; Notes:
; 
;place the compiled stack in Access bank memory
;use the ?au_ prefix for autos, the ?pa_ prefix for parameters
    FNCONF udata_acs,?au_,?pa_

    PSECT resetVec,class=CODE,reloc=2
resetVec:
    goto main

    PSECT code
;add needs 4 bytes of parameters, but no autos
    FNSIZE add,0,4                  ;two 2-byte parameters
    GLOBAL ?pa_add
;add the two 'int' parameters, returning the result in the first parameter location
add:
    movf ?pa_add+2,w,c
    addwf ?pa_add+0,f,c
    movf ?pa_add+3,w,c
    addwfc ?pa_add+1,f,c
    return

;write needs one 2-byte parameter
    FNSIZE write,0,2
    GLOBAL ?pa_write
;write the low byte of the argument to LATA; the high byte to LATB
write:
    movff ?pa_write+0,LATA
    movff ?pa_write+1,LATB
    return

    FNROOT main                     ;this is the root of a call graph
    FNSIZE main,4,0                 ;two 2-byte 'autos'
    FNCALL main,add                 ;main calls add
    FNCALL main,write               ;and write
    GLOBAL ?au_main
    PSECT code
main:
    clrf ?au_main+0,c               ;intermediate result
    clrf ?au_main+1,c
    movlw 2                         ;increment amount
    movwf ?au_main+3,c
loop:
    movff ?au_main+0,?pa_add+0      ;load 1st parameter for add
    movff ?au_main+1,?pa_add+1
    movff ?au_main+2,?pa_add+2      ;load 2nd parameter for add
    movff ?au_main+3,?pa_add+3
    call add
    movff ?pa_add+0,?au_main+0      ;store add's return value
    movff ?pa_add+1,?au_main+1
    movff ?au_main+0,?pa_write+0    ;load the parameter for write
    movff ?au_main+1,?pa_write+1
    call write
    infsnz ?au_main+2,f,c           ;increase the increment value 
    incf ?au_main+3,f,c
    goto loop

    END resetVec
