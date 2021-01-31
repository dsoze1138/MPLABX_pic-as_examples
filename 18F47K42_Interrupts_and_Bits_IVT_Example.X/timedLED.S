; 
; Code example from section 8. Interrupts and Bits Example For PIC18 Devices
;
; From document: https://ww1.microchip.com/downloads/en/DeviceDoc/50002994B.pdf
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-presetVec=0h -Wl,-pivt=08h -Wa,-a -Wl,-Map=timedLED.map
;
    PROCESSOR 18F47K42
    PAGEWIDTH   162
    RADIX       dec
;
; Blink the LED on a PIC18F47K42 Curiosity Nano Board
; using the timer and interrupts to control the flash period.
;
#include <xc.inc>

    CONFIG FEXTOSC = OFF                ; External Oscillator Selection->Oscillator not enabled
    CONFIG RSTOSC = HFINTOSC_1MHZ       ; Reset Oscillator Selection->HFINTOSC, HFFRQ=4MHz, CDIV=4:1
    CONFIG CLKOUTEN = OFF               ; Clock out Enable bit->CLKOUT function is disabled
    CONFIG PR1WAY = ON                  ; PRLOCKED One-Way Set Enable->PRLOCK cleared/set only once
    CONFIG CSWEN = ON                   ; Clock Switch Enable->Writing to NOSC and NDIV is allowed
    CONFIG FCMEN = ON                   ; Fail-Safe Clock Monitor Enable->Clock Monitor enabled

    CONFIG MCLRE = EXTMCLR              ; MCLR Enable->LVP=0=>MCLR pin is MCLR; LVP=1=>RE3 pin is MCLR
    CONFIG PWRTS = PWRT_OFF             ; Power-up timer selection bits->PWRT is disabled
    CONFIG MVECEN = ON                  ; Multi-vector enable->Multi-vector table enabled
    CONFIG IVT1WAY = ON                 ; IVTLOCK One-way set enable->IVTLOCK cleared/set only once
    CONFIG LPBOREN = OFF                ; Low Power BOR Enable bit->ULPBOR disabled
    CONFIG BOREN = SBORDIS              ; Brown-out Reset Enable->BOR enabled, SBOREN ignored
    CONFIG BORV = VBOR_2P45             ; Brown-out Reset Voltage Selection->VBOR set to 2.45V
    CONFIG ZCD = OFF                    ; ZCD Disable->ZCD disabled; enable by setting ZCDSEN
    CONFIG PPS1WAY = ON                 ; PPSLOCK One-Way Set Enable->PPSLOCK cleared/set only once
    CONFIG STVREN = ON                  ; Stack Full/Underflow Reset Enable->Full/underflow => Reset
    CONFIG DEBUG = OFF                  ; Debugger Enable bit->Background debugger disabled
    CONFIG XINST = OFF                  ; Extended Instruction Set Enable->Extended Set disabled

    CONFIG WDTCPS = WDTCPS_31           ; WDT Period selection->Divider 1:65536; s/w control of WDTPS
    CONFIG WDTE = OFF                   ; WDT operating mode->WDT Disabled; SWDTEN is ignored
    CONFIG WDTCWS = WDTCWS_7            ; WDT Window Select->window open (100%); software control
    CONFIG WDTCCS = SC                  ; WDT input clock selector->Software Control

    CONFIG BBSIZE = BBSIZE_512          ; Boot Block Size selection->Boot Block size is 512 words
    CONFIG BBEN = OFF                   ; Boot Block enable bit->Boot block disabled
    CONFIG SAFEN = OFF                  ; Storage Area Flash enable bit->SAF disabled
    CONFIG WRTAPP = OFF                 ; Application Block write protection->Block not protected
    CONFIG WRTB = OFF                   ; Configuration Register Write Protection->Not protected
    CONFIG WRTC = OFF                   ; Boot Block Write Protection->Boot Block not write-protected
    CONFIG WRTD = OFF                   ; Data EEPROM Write Protection->Data EEPROM not write-protected
    CONFIG WRTSAF = OFF                 ; SAF Write protection bit->SAF not Write Protected
    CONFIG LVP = ON                     ; Low Voltage Programming Enable->LVP enabled
    CONFIG CP = OFF                     ; PFM and Data EEPROM Code Protection->code protection disabled

    GLOBAL  resetVec
    GLOBAL  LEDState                    ; make this global so it is watchable when debugging
    GLOBAL  __Livt                      ; defined by the linker but used in this code

    PSECT   bitbssCOMMON,bit,class=COMRAM,space=1
LEDState:
    DS      1                           ; a single bit used to hold the required LED state

    PSECT   resetVec,class=CODE,reloc=2
resetVec:
    goto    start
;
; This PSECT name (ivt) is "special" in that the 
; linker creates a symbolic reference (__Livt) that 
; is used to initialize the Interrupt Vector Table
; base address.
;
; Changing the name of this section means that these
; other symbols must also be changed.
;
    PSECT   ivt,class=CODE,reloc=2,ovrld
ivtbase:
    ORG     31*2                        ; timer 0 vector position
    DW      tmr0Isr shr 2   ; WHERE IS IT DOCUMENTED THAT THE ISR ADDRESS NEEDS THIS RIGHT SHIFT?

;    PSECT   code ; Wrong, the IVT target ISR must be on an 4 byte boundry
    PSECT   tmr0Isr,class=CODE,reloc=4  ; Fix error in example code
tmr0Isr:
    bcf     TMR0IF
    ;toggle the desired LED state
    movlw   1 shl (LEDState&7)
    xorwf   LEDState/(0+8),c

    retfie  f

    PSECT   code
start:
    bsf     BANKMASK(INTCON0),INTCON0_IPEN_POSN,c ; set IPEN bit
    ; use the unlock sequence to set the vector table position
    ; based on where the ivt psect is linked
    bcf     GIE
    movlw   0x55
    movwf   BANKMASK(IVTLOCK),c
    movlw   0xAA
    movwf   BANKMASK(IVTLOCK),c
    bcf     IVTLOCKED
    movlw   low highword __Livt
    movwf   BANKMASK(IVTBASEU),c
    movlw   high __Livt
    movwf   BANKMASK(IVTBASEH),c
    movlw   low __Livt
    movwf   BANKMASK(IVTBASEL),c
    movlw   0x55
    movwf   BANKMASK(IVTLOCK),c
    movlw   0xAA
    movwf   BANKMASK(IVTLOCK),c
    bsf     IVTLOCKED
    ; set up the state of the oscillator and peripherals with RE0 as a digital output driving
    ; the LED, assuming that other registers have not changed from their reset state
    movlw   6
    movwf   BANKMASK(TRISE),c
    movlw   0x62
    BANKSEL OSCCON1
    movwf   BANKMASK(OSCCON1),b
    clrf    BANKMASK(OSCCON3),b
    clrf    BANKMASK(OSCEN),b
    movlw   2                           ; Select 4MHz as HFINTOSC frequency
    movwf   BANKMASK(OSCFRQ),b
    clrf    BANKMASK(OSCTUNE),b
    ;configure and start timer interrupts
    BANKSEL IPR3
    bsf     BANKMASK(IPR3),IPR3_TMR0IP_POSITION,b
    movlw   0x4B                        ; TIMER0 clock source as FOSC/4 (only one that works in simulation), prescaler 1:2048
    movwf   BANKMASK(T0CON1),c          ; FOSC/4 is 1MHz
    movlw   0xF3                        ; TIMER0 interrupt period (1/1000)*2048*244 = 499.712 milliseconds
    movwf   BANKMASK(TMR0H),c           
    clrf    BANKMASK(TMR0L),c
    BANKSEL PIR3
    bcf     BANKMASK(PIR3),PIR3_TMR0IF_POSITION,b
    bsf     BANKMASK(PIE3),PIE3_TMR0IE_POSITION,b
    movlw   0x80
    movwf   BANKMASK(T0CON0),c
    bsf     GIEH

loop:
    ;set LED state to be that requested by the interrupt code
    btfss   LEDState/8,LEDState&7,c
    goto    lightLED
    bsf     RE0                         ; turn LED off
    goto    loop
lightLED:
    bcf     RE0                         ; turn LED on
    goto    loop
    END     resetVec