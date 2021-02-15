; File:   main.S
; Author: dan1138
; Target: PIC18F46K42
; Compiler: pic-as v2.31
; IDE: MPLABX v5.45
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-presetVec=0h -Wl,-pivt=08h -Wa,-a
;
; Description:
;
;   Example code that initia;lizes the Interrupt Vector Table
;
    PROCESSOR 18F46K42
    PAGEWIDTH   162
    RADIX       dec
;

#include <xc.inc>

; CONFIG1L
  CONFIG  FEXTOSC = OFF         ; External Oscillator Selection (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_64MHZ; Reset Oscillator Selection (HFINTOSC with HFFRQ = 64 MHz and CDIV = 1:1)

; CONFIG1H
  CONFIG  CLKOUTEN = OFF        ; Clock out Enable bit (CLKOUT function is disabled)
  CONFIG  PR1WAY = OFF          ; PRLOCKED One-Way Set Enable bit (PRLOCK bit can be set and cleared repeatedly)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)

; CONFIG2L
  CONFIG  MCLRE = EXTMCLR       ; MCLR Enable bit (If LVP = 0, MCLR pin is MCLR; If LVP = 1, RE3 pin function is MCLR )
  CONFIG  PWRTS = PWRT_OFF      ; Power-up timer selection bits (PWRT is disabled)
  CONFIG  MVECEN = ON           ; Multi-vector enable bit (Multi-vector enabled, Vector table used for interrupts)
  CONFIG  IVT1WAY = OFF         ; IVTLOCK bit One-way set enable bit (IVTLOCK bit can be cleared and set repeatedly)
  CONFIG  LPBOREN = OFF         ; Low Power BOR Enable bit (ULPBOR disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled , SBOREN bit is ignored)

; CONFIG2H
  CONFIG  BORV = VBOR_2P45      ; Brown-out Reset Voltage Selection bits (Brown-out Reset Voltage (VBOR) set to 2.45V)
  CONFIG  ZCD = OFF             ; ZCD Disable bit (ZCD disabled. ZCD can be enabled by setting the ZCDSEN bit of ZCDCON)
  CONFIG  PPS1WAY = OFF         ; PPSLOCK bit One-Way Set Enable bit (PPSLOCK bit can be set and cleared repeatedly (subject to the unlock sequence))
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  DEBUG = OFF           ; Debugger Enable bit (Background debugger disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Extended Instruction Set and Indexed Addressing Mode disabled)

; CONFIG3L
  CONFIG  WDTCPS = WDTCPS_31    ; WDT Period selection bits (Divider ratio 1:65536; software control of WDTPS)
  CONFIG  WDTE = OFF            ; WDT operating mode (WDT Disabled; SWDTEN is ignored)

; CONFIG3H
  CONFIG  WDTCWS = WDTCWS_7     ; WDT Window Select bits (window always open (100%); software control; keyed access not required)
  CONFIG  WDTCCS = SC           ; WDT input clock selector (Software Control)

; CONFIG4L
  CONFIG  BBSIZE = BBSIZE_512   ; Boot Block Size selection bits (Boot Block size is 512 words)
  CONFIG  BBEN = OFF            ; Boot Block enable bit (Boot block disabled)
  CONFIG  SAFEN = OFF           ; Storage Area Flash enable bit (SAF disabled)
  CONFIG  WRTAPP = OFF          ; Application Block write protection bit (Application Block not write protected)

; CONFIG4H
  CONFIG  WRTB = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-30000Bh) not write-protected)
  CONFIG  WRTC = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)
  CONFIG  WRTSAF = OFF          ; SAF Write protection bit (SAF not Write Protected)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored)

; CONFIG5L
  CONFIG  CP = OFF              ; PFM and Data EEPROM Code Protection bit (PFM and Data EEPROM code protection disabled)

; CONFIG5H

    GLOBAL  resetVec
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
    GLOBAL  __Livt                      ; defined by the linker but used in this code
    PSECT   ivt,class=CODE,reloc=2,ovrld
ivtbase:
    DW  Default_ISR shr 2        ; IVT 0  - Software Interrupt
    DW  Default_ISR shr 2        ; IVT 1  - HLVD
    DW  Default_ISR shr 2        ; IVT 2  - OSF
    DW  Default_ISR shr 2        ; IVT 3  - CSW
    DW  Default_ISR shr 2        ; IVT 4  - NVM
    DW  Default_ISR shr 2        ; IVT 5  - SCAN
    DW  Default_ISR shr 2        ; IVT 6  - CRC
    DW  Default_ISR shr 2        ; IVT 7  - IOC
    DW  Default_ISR shr 2        ; IVT 8  - INT0
    DW  Default_ISR shr 2        ; IVT 9  - ZCD
    DW  Default_ISR shr 2        ; IVT 10 - AD
    DW  Default_ISR shr 2        ; IVT 11 - ADT
    DW  Default_ISR shr 2        ; IVT 12 - C1
    DW  Default_ISR shr 2        ; IVT 13 - SMT1
    DW  Default_ISR shr 2        ; IVT 14 - SMT1PRA
    DW  Default_ISR shr 2        ; IVT 15 - SMT1PWA
    DW  Default_ISR shr 2        ; IVT 16 - DMA1SCNT
    DW  Default_ISR shr 2        ; IVT 17 - DMA1DCNT
    DW  Default_ISR shr 2        ; IVT 18 - DMA1OR
    DW  Default_ISR shr 2        ; IVT 19 - DMA1A
    DW  Default_ISR shr 2        ; IVT 20 - SPI1RX
    DW  Default_ISR shr 2        ; IVT 21 - SPI1TX
    DW  Default_ISR shr 2        ; IVT 22 - SPI1
    DW  Default_ISR shr 2        ; IVT 23 - I2C1RX
    DW  Default_ISR shr 2        ; IVT 24 - I2C1TX
    DW  Default_ISR shr 2        ; IVT 25 - I2C1
    DW  Default_ISR shr 2        ; IVT 26 - I2C1E
    DW  Default_ISR shr 2        ; IVT 27 - U1RX
    DW  Default_ISR shr 2        ; IVT 28 - U1TX
    DW  Default_ISR shr 2        ; IVT 29 - U1E
    DW  Default_ISR shr 2        ; IVT 30 - U1
    DW      tmr0Isr shr 2        ; IVT 31 - TMR0
    DW  Default_ISR shr 2        ; IVT 32 - TMR1
    DW  Default_ISR shr 2        ; IVT 33 - TMR1G
    DW  Default_ISR shr 2        ; IVT 34 - TMR2
    DW  Default_ISR shr 2        ; IVT 35 - CCP1
    DW  Default_ISR shr 2        ; IVT 36 - reserved
    DW  Default_ISR shr 2        ; IVT 37 - NCO
    DW  Default_ISR shr 2        ; IVT 38 - CWG1
    DW  Default_ISR shr 2        ; IVT 39 - CLC1
    DW  Default_ISR shr 2        ; IVT 40 - INT1
    DW  Default_ISR shr 2        ; IVT 41 - C2
    DW  Default_ISR shr 2        ; IVT 42 - DMA2SCNT
    DW  Default_ISR shr 2        ; IVT 43 - DMA2DCNT
    DW  Default_ISR shr 2        ; IVT 44 - DMA2OR
    DW  Default_ISR shr 2        ; IVT 45 - DMA2A
    DW  Default_ISR shr 2        ; IVT 46 - I2C2RX
    DW  Default_ISR shr 2        ; IVT 47 - I2C2TX
    DW  Default_ISR shr 2        ; IVT 48 - I2C2
    DW  Default_ISR shr 2        ; IVT 49 - I2C2E
    DW  Default_ISR shr 2        ; IVT 50 - U2RX
    DW  Default_ISR shr 2        ; IVT 51 - U2TX
    DW  Default_ISR shr 2        ; IVT 52 - U2E
    DW  Default_ISR shr 2        ; IVT 53 - U2
    DW  Default_ISR shr 2        ; IVT 54 - TMR3
    DW  Default_ISR shr 2        ; IVT 55 - TMR3G
    DW  Default_ISR shr 2        ; IVT 56 - TMR4
    DW  Default_ISR shr 2        ; IVT 57 - CCP2
    DW  Default_ISR shr 2        ; IVT 58 - reserved
    DW  Default_ISR shr 2        ; IVT 59 - CWG2
    DW  Default_ISR shr 2        ; IVT 60 - CLC2
    DW  Default_ISR shr 2        ; IVT 61 - INT2
    DW  Default_ISR shr 2        ; IVT 62 - reserved
    DW  Default_ISR shr 2        ; IVT 63 - reserved
    DW  Default_ISR shr 2        ; IVT 64 - reserved
    DW  Default_ISR shr 2        ; IVT 65 - reserved
    DW  Default_ISR shr 2        ; IVT 66 - reserved
    DW  Default_ISR shr 2        ; IVT 67 - reserved
    DW  Default_ISR shr 2        ; IVT 68 - reserved
    DW  Default_ISR shr 2        ; IVT 69 - reserved
    DW  Default_ISR shr 2        ; IVT 70 - TMR5
    DW  Default_ISR shr 2        ; IVT 71 - TMR5G
    DW  Default_ISR shr 2        ; IVT 72 - TMR6
    DW  Default_ISR shr 2        ; IVT 73 - CCP3
    DW  Default_ISR shr 2        ; IVT 74 - CWG3
    DW  Default_ISR shr 2        ; IVT 75 - CLC3
    DW  Default_ISR shr 2        ; IVT 76 - reserved
    DW  Default_ISR shr 2        ; IVT 77 - reserved
    DW  Default_ISR shr 2        ; IVT 78 - reserved
    DW  Default_ISR shr 2        ; IVT 79 - reserved
    DW  Default_ISR shr 2        ; IVT 80 - CCP4
    DW  Default_ISR shr 2        ; IVT 81 - CLC4

    PSECT   DefaultIsr,class=CODE,reloc=4
Default_ISR:
    reset

    PSECT   tmr0Isr,class=CODE,reloc=4
tmr0Isr:
    bcf     TMR0IF
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

; set up the state of the oscillator
    movlw   0x62
    BANKSEL OSCCON1
    movwf   BANKMASK(OSCCON1),b
    clrf    BANKMASK(OSCCON3),b
    clrf    BANKMASK(OSCEN),b
    movlw   2                           ; Select 4MHz as HFINTOSC frequency
    movwf   BANKMASK(OSCFRQ),b
    clrf    BANKMASK(OSCTUNE),b
; configure and start timer interrupts
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
;
; Application Loop
;
AppLoop:
    goto    AppLoop

    END     resetVec