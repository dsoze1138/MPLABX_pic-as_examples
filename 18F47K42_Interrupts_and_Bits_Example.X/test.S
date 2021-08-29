; 
; This is the code Microchip should have published.
;
; Code example from section 7.  Interrupts and Bits Example
;
; Not from document: http://ww1.microchip.com/downloads/en/DeviceDoc/XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
;
; File:     test.S
; Target:   PIC18F47K42
; Author:   dan1138
; Date:     2020-06-21
; Compiler: pic-as(v2.32)
; IDE:      MPLABX v5.50
;
; Description:
;
;   Make PORTA an 8-bit output port and write a binary
;   count incremented from a TIMER0 interrupt event.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-presetVec=0h,-phi_int_vec=08h,-plo_int_vec=18h -Wl,-Map=test.map
;
    PROCESSOR   18F47K42
    PAGEWIDTH   132
    RADIX       dec
;
#include <xc.inc>
;
 CONFIG FEXTOSC=XT, RSTOSC=EXTOSC, CLKOUTEN=OFF, PR1WAY=ON
 CONFIG CSWEN=ON, FCMEN=ON, MCLRE=EXTMCLR, PWRTS=PWRT_OFF
 CONFIG MVECEN=OFF, IVT1WAY=ON, LPBOREN=OFF, BOREN=SBORDIS
 CONFIG BORV=VBOR_2P45, ZCD=OFF, PPS1WAY=ON, STVREN=ON
 CONFIG XINST=OFF, WDTCPS=WDTCPS_31, WDTE=OFF, WDTCWS=WDTCWS_7
 CONFIG WDTCCS=SC, BBSIZE=BBSIZE_512, BBEN=OFF, SAFEN=OFF
 CONFIG WRTAPP=OFF, WRTB=OFF, WRTC=OFF, WRTD=OFF
 CONFIG WRTSAF=OFF, LVP=ON, CP=OFF
;
;   bits in bank 0 data memory
    PSECT   BitFlags,global,class=BANK0,space=1,bit,noexec
;
    GLOBAL  bTimerEvent
bTimerEvent: DS  1
;
;   Reset vector
    PSECT   resetVec,global,reloc=2,class=CODE,delta=1
;
resetVec:
    goto    Start
;
;   High priority interrupt vector
    PSECT   hi_int_vec,global,reloc=2,class=CODE,delta=1
;
    goto    HighIsrHandler
;
;   Data space use by low priority interrupt handler to save context
    PSECT   LowIsr_data,global,class=COMRAM,space=1,delta=1,lowdata,noexec
;
    GLOBAL  WREG_save,STATUS_save,BSR_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
BSR_save:       DS  1
;
;   Low priority interrupt vector and handler
    PSECT   lo_int_vec,global,reloc=2,class=CODE,delta=1
;
LowIsrVec:
    movff   WREG,WREG_save
    movff   STATUS,STATUS_save
    movff   BSR,BSR_save
;
LowIsrHandler:
    BANKSEL PIE0
    btfsc   PIE3,PIE3_TMR0IE_POSITION,b ;did the timer generate this interrupt?
    btfss   PIR3,PIR3_TMR0IF_POSITION,b
    bra     LowIsrExit                  ;no - ignore
    bcf     PIR3,PIR3_TMR0IF_POSITION,b ;yes - clear the interrupt flag

    ;set a flag to say that the port should be incremented
    BANKSEL (bTimerEvent/8)
    bsf     BANKMASK(bTimerEvent/8),bTimerEvent&7,b
;
LowIsrExit:
    movff   BSR_save,BSR
    movff   STATUS_save,STATUS
    movff   WREG_save,WREG
    retfie  0   ; Return from interrupt
;
;   High priority interrupt handler
    PSECT   HighIsr_code,global,reloc=2,class=CODE,delta=1
;
HighIsrHandler:
    retfie  1   ; Fast return from interrupt
;
;   Startup code used at power on reset
    PSECT   start_code,global,reloc=2,class=CODE,delta=1
;
Start:
    bcf     INTCON0,INTCON0_GIEH_POSITION,c   ; Disable all interrupts
    bcf     INTCON0,INTCON0_GIEL_POSITION,c
    bsf     INTCON0,INTCON0_IPEN_POSITION,c   ; Enable interrupt priority
;
; Initialize TIMER0 in 8-bit mode to reload after 128 counts.
; Assign the ISR to the low priority handler.
;
    clrf    T0CON0,c        ; Stop TIMER0
    movlw   0b01000000      ; Clock source: FOSC/4, Prescale 1:1
    movwf   T0CON1,c
    clrf    TMR0L,c         ; Clear 8-bit timer count register
    movlw   128-1
    movwf   TMR0H,c         ; Set 8-bit timer reload count
    BANKSEL PIE0
    bcf     IPR3,IPR3_TMR0IP_POSITION,b
    bcf     PIR3,PIR3_TMR0IF_POSITION,b
    bsf     PIE3,PIE3_TMR0IE_POSITION,b
    bsf     T0CON0,T0CON0_EN_POSITION,c     ; Start timer
    bsf     INTCON0,INTCON0_GIEH_POSITION,c ; Enable all interrupts
    bsf     INTCON0,INTCON0_GIEL_POSITION,c
    goto    main
;
;   Data used by main application
    PSECT   main_data,global,class=RAM,space=1,delta=1,noexec
;
    GLOBAL  count
count:      DS  1
;
;   Main application code
    PSECT   main_code,global,reloc=2,class=CODE,delta=1
;
main:
    clrf    TRISA,c
    clrf    LATA,c
    BANKSEL count
    clrf    BANKMASK(count),b
AppLoop:
    BANKSEL (bTimerEvent/8)
    bcf     BANKMASK(bTimerEvent/8),bTimerEvent&7,b
EventWait:
    ;do we need to increment yet?
    btfss   BANKMASK(bTimerEvent/8),bTimerEvent&7,b
    bra     EventWait   ;no - keep checking
;
    ;yes - increment the value on the port
    BANKSEL count
    incf    BANKMASK(count),f,b
    movff   count,LATA
    goto    AppLoop
;
    END     resetVec
