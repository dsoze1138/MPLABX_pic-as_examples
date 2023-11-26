; 
; This is an example of how the PIC-AS(v2.45) assembler 
; processes high and low priority interrupts.
;
; External interrupt (INT0) is handled as high priority
; TIMER0 interrupt is handled as low priority
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-Map=main.map -Wl,-presetVec=0h,-phiIsrVec=08h,-ploIsrVec=18h
;
    PROCESSOR 18F452
    RADIX       dec
;
; Define the system oscillator this code will setup
#define __XTAL_FREQ 4000000

  CONFIG  OSC = XT, OSCS = ON
  CONFIG  PWRT = OFF, BOR = OFF, BORV = 20
  CONFIG  WDT = OFF, WDTPS = 128
  CONFIG  CCP2MUX = ON
  CONFIG  STVR = ON, LVP = OFF
  CONFIG  CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
  CONFIG  CPB = OFF, CPD = OFF
  CONFIG  WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
  CONFIG  WRTC = OFF, WRTB = OFF, WRTD = OFF
  CONFIG  EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
  CONFIG  EBTRB = OFF

#include <xc.inc>

    PSECT   resetVec,class=CODE,reloc=2
resetVec:
    clrf    PCLATU,c    ; Workaround for known bug in some PIC18F controllers
    goto    Start

;
;   High priority interrupt vector
    PSECT   hiIsrVec,global,reloc=2,class=CODE,delta=1
;
    call    $+4,1       ; Workaround for known bug in some PIC18F controllers
    pop                 ;
    goto    HighIsrHandler
;
;   Data space use by low priority interrupt handler to save context
    PSECT   loIsrData,global,class=COMRAM,space=1,delta=1,lowdata,noexec
;
    GLOBAL  WREG_save,STATUS_save,BSR_save
;
WREG_save:      DS  1
STATUS_save:    DS  1
BSR_save:       DS  1
;
;   Low priority interrupt vector and handler
    PSECT   loIsrVec,global,reloc=2,class=CODE,delta=1
;
LowIsrVec:
    movff   WREG,WREG_save
    movff   STATUS,STATUS_save
    movff   BSR,BSR_save
;
LowIsrHandler:
;
; TIMER0 Interrupt handler
    btfsc   INTCON,INTCON_TMR0IE_POSITION,c
    btfss   INTCON,INTCON_TMR0IF_POSITION,c
    bra     ISR_TMR0_Exit
    bcf     INTCON,INTCON_TMR0IF_POSITION,c
ISR_TMR0_Exit:
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
;
; INT0 Interrupt handler
    btfsc   INTCON,INTCON_INT0IE_POSITION,c
    btfss   INTCON,INTCON_INT0IF_POSITION,c
    bra     ISR_INT0_Exit
    bcf     INTCON,INTCON_INT0IF_POSITION,c
ISR_INT0_Exit:
;
    retfie  1   ; Fast return from interrupt

;
; Application data
;
    PSECT   udata
    global  AppLoopCount
AppLoopCount:   ds      1
;
; Start of code
;
    PSECT   code
Start:
    clrf    INTCON,c
    bsf     RCON,RCON_IPEN_POSITION,c
    goto    main

main:
    bsf     INTCON,INTCON_INT0IE_POSITION,c
    bsf     INTCON,INTCON_TMR0IE_POSITION,c
    bcf     INTCON2,INTCON2_TMR0IP_POSITION,c
;
; Configure TIMER0 
    movlw   0x4F
    movwf   T0CON,c
    clrf    TMR0L,c
    bcf     INTCON,INTCON_TMR0IF_POSITION,c
    bsf     T0CON,T0CON_TMR0ON_POSITION,c
;
; Configure INT0
    bsf     TRISB,TRISB_TRISB0_POSITION,c
    bcf     INTCON,INTCON_INT0IF_POSITION,c

    bsf     INTCON,INTCON_GIEL_POSITION,c
    bsf     INTCON,INTCON_GIEH_POSITION,c
;
; Application process loop
;
AppLoop:
    banksel AppLoopCount
    incf    AppLoopCount,F,b
    goto    AppLoop

    end     resetVec