;
; File:     main.S
; Target:   PIC18F45K80
; Author:   dan1138
; Date:     2020-09-25
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Description:
; 
;   Example assembly language branch table
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-Wl,-presetVec=0h
;
    PROCESSOR   18F45K80
    PAGEWIDTH   132
    RADIX       dec

#include <xc.inc>

; PIC18F45K80 Configuration Bit Settings

 config RETEN = OFF      ; VREG Sleep Enable bit (Ultra low-power regulator is Disabled (Controlled by REGSLP bit))
 config INTOSCSEL = HIGH ; LF-INTOSC Low-power Enable bit (LF-INTOSC in High-power mode during Sleep)
 config SOSCSEL = HIGH   ; SOSC Power Selection and mode Configuration bits (High Power SOSC circuit selected)
 config XINST = OFF      ; Extended Instruction Set (Disabled)
 config FOSC = INTIO2    ; Oscillator (Internal RC oscillator)
 config PLLCFG = OFF     ; PLL x4 Enable bit (Disabled)
 config FCMEN = OFF      ; Fail-Safe Clock Monitor (Disabled)
 config IESO = OFF       ; Internal External Oscillator Switch Over Mode (Disabled)
 config PWRTEN = OFF     ; Power Up Timer (Disabled)
 config BOREN = OFF      ; Brown Out Detect (Disabled in hardware, SBOREN disabled)
 config BORV = 3         ; Brown-out Reset Voltage bits (1.8V)
 config BORPWR = ZPBORMV ; BORMV Power level (ZPBORMV instead of BORMV is selected)
 config WDTEN = OFF      ; Watchdog Timer (WDT disabled in hardware; SWDTEN bit disabled)
 config WDTPS = 1048576  ; Watchdog Postscaler (1:1048576)
 config CANMX = PORTB    ; ECAN Mux bit (ECAN TX and RX pins are located on RB2 and RB3, respectively)
 config MSSPMSK = 1      ; MSSP address masking (7 Bit address masking mode)
 config MCLRE = ON       ; Master Clear Enable (MCLR Enabled, RE3 Disabled)
 config STVREN = ON      ; Stack Overflow Reset (Enabled)
 config BBSIZ = BB2K     ; Boot Block Size (2K word Boot Block size)
 config CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
 config CPB = OFF, CPD = OFF
 config WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
 config WRTC = OFF, WRTB = OFF, WRTD = OFF
 config EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
 config EBTRB = OFF      ; Table Read Protect Boot (Disabled)
;
; Power On Reset entry point
;
    PSECT   resetVec,class=CODE,reloc=2
    global  PORreset
PORreset:
    goto    main
;
; Action branch table
;
    PSECT   code
    global  ACTIONS_TABLE
ACTIONS_TABLE:
    goto    ACTION1
AT_SecondElement:
    goto    ACTION2
    goto    ACTION3
    goto    ACTION4
    goto    ACTION5
    goto    ACTION6
    goto    ACTION7
    goto    ACTION8
    goto    ACTION9
    goto    ACTION10
    goto    ACTION11
    goto    ACTION12
    goto    ACTION13
    goto    ACTION14
    goto    ACTION15
AT_LastdElement:
    goto    ACTION16
;
; Macros that describe the shape of the branch table
;
#define ActionTableElementCount ((AT_LastdElement-ACTIONS_TABLE)/(AT_SecondElement-ACTIONS_TABLE))
#define ActionTableElementSize (AT_SecondElement-ACTIONS_TABLE)
;
; Indirect branch to action
;
; Input: WREG = Action selector, range 0 to 255
;
    PSECT   code
    global  Select_Action
Select_Action:
    movwf   PRODL,c                 ; Save action seelctor.
    movlw   ActionTableElementCount+1
    cpfslt  PRODL,c                 ; Skip when action selector is withing the branch table.
    return
    movlw   ActionTableElementSize
    mulwf   PRODL,c                 ; Scale the selector by the action table element size to make the table offset.
    movlw   LOW(ACTIONS_TABLE)
    addwf   PRODL,F,c               ; Add offset to table start address (bits 7-0).
    movlw   HIGH(ACTIONS_TABLE)
    addwfc  PRODH,W,c               ; Add offset to table start address (bits 15-8).
    movwf   PCLATH,c
    clrf    PCLATU,c
    movlw   (ACTIONS_TABLE>>16)
    addwfc  PCLATU,F,c              ; Add offset to table start address (bits 23-16).
    movf    PRODL,W,c
    movwf   PCL,c                   ; Update the program counter to the branch table address.
;
;   Data used by main application
    PSECT   main_data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  Selector
Selector:   DS  1
;
; Application loop
;
    PSECT   code
    global  main
main:
    banksel Selector
    clrf    BANKMASK(Selector),b    ; Start with first asction.
AppLoop:
    movf    BANKMASK(Selector),W,b
    call    Select_Action           ; Invoke action.
    banksel Selector
    incf    BANKMASK(Selector),F,b  ; Select next action.
    movlw   ActionTableElementCount
    cpfsgt  BANKMASK(Selector),b    ; Skip if next action is not within the table.
    bra     AppLoop                 ; Loop for next action.
    bra     main                    ; Start all over.
;
; Actions call using table lookup
;
ACTION1:
    return
ACTION2:
    return
ACTION3:
    return
ACTION4:
    return
ACTION5:
    return
ACTION6:
    return
ACTION7:
    return
ACTION8:
    return
ACTION9:
    return
ACTION10:
    return
ACTION11:
    return
ACTION12:
    return
ACTION13:
    return
ACTION14:
    return
ACTION15:
    return
ACTION16:
    return

; Tell linker the address of the Power-On-Reset
    end     PORreset