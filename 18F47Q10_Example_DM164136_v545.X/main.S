;
; File:       main.S
; Target:     PIC18F47Q10
; Author:     dan1138
; Date:       2021-MAR-26
; Compiler:   pic-as(v2.31)
; IDE:        MPLABX v5.45
; Demo board: DM164136
;
;                                PIC18F47Q10
;                     +--------------:_:--------------+
; SWITCH_S3 VPP ->  1 : RE3/MCLR/VPP     PGD/ANB7/RB7 : 40 <> PGD
;           POT ->  2 : RA0/ANA0         PGC/ANB6/RB6 : 39 <> PGC
;               <>  3 : RA1/ANA1             ANB5/RB5 : 38 <>
;               <>  4 : RA2/ANA2             ANB4/RB4 : 37 <> SWITCH_S1
;               <>  5 : RA3/ANA3             ANB3/RB3 : 36 <>
;        LED_D2 <>  6 : RA4/ANA4             ANB2/RB2 : 35 <>
;        LED_D3 <>  7 : RA5/ANA5             ANB1/RB1 : 34 <>
;               <>  8 : RE0                  ANB0/RB0 : 33 <>
;               <>  9 : RE1                       VDD : 32 <- PWR
;               <> 10 : RE2                       VSS : 31 <- GND
;           PWR -> 11 : VDD                  AND7/RD7 : 30 <>
;           GND -> 12 : VSS                  AND6/RD6 : 29 <>
;        LED_D5 <> 13 : RA7/ANA7/OSC1        AND5/RD5 : 28 <>
;        LED_D4 <> 14 : RA6/ANA6/OSC2        AND4/RD4 : 27 <>
;               <> 15 : RC0/ANC0/SOSCO       ANC7/RC7 : 26 <>
;               <> 16 : RC1/ANC1/SOSCI       ANC6/RC6 : 25 <>
;               <> 17 : RC2/ANC2             ANC5/RC5 : 24 <> SWITCH_S2
;               <> 18 : RC3/ANC3             ANC4/RC4 : 23 <>
;     TARGET_TX <> 19 : RD0/AND0(U2TX)       AND3/RD3 : 22 <>
;     TARGET_RX <> 20 : RD1/AND1(U2RX)       AND2/RD2 : 21 <>
;                     +-------------------------------:
;                                   DIP-40
;
; Description:
;   LED blinky and UART demo application fo the DM164136 Curiosity HPC.
;   Blinks the on board LED and sends a message to the virtual COM port.
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wa,-a -Wl,-presetVec=0h,-phi_int_vec=08h,-plo_int_vec=18h
;
; Notes:
;   The MPLABX v5.45 tool pack version 1.2.293 for the PKOB4 breaks the virvual COM 
;   implementation in the PKOB4 controller. Tool pack version 1.1.166 works correctly.
;
    PROCESSOR   18F47Q10
    PAGEWIDTH   132
    RADIX       dec

; PIC18F47Q10 Configuration Bit Settings

 ; CONFIG1L
  CONFIG  FEXTOSC = OFF         ; External Oscillator mode Selection bits (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_64MHZ; Power-up default value for COSC bits (HFINTOSC with HFFRQ = 64 MHz and CDIV = 1:1)

; CONFIG1H
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable bit (CLKOUT function is disabled)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)

; CONFIG2L
  CONFIG  MCLRE = EXTMCLR       ; Master Clear Enable bit (MCLR pin (RE3) is MCLR)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (Power up timer disabled)
  CONFIG  LPBOREN = OFF         ; Low-power BOR enable bit (Low power BOR is disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled , SBOREN bit is ignored)

; CONFIG2H
  CONFIG  BORV = VBOR_190       ; Brown Out Reset Voltage selection bits (Brown-out Reset Voltage (VBOR) set to 1.90V)
  CONFIG  ZCD = OFF             ; ZCD Disable bit (ZCD disabled. ZCD can be enabled by setting the ZCDSEN bit of ZCDCON)
  CONFIG  PPS1WAY = OFF         ; PPSLOCK bit One-Way Set Enable bit (PPSLOCK bit can be set and cleared repeatedly (subject to the unlock sequence))
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Extended Instruction Set and Indexed Addressing Mode disabled)

; CONFIG3L
  CONFIG  WDTCPS = WDTCPS_31    ; WDT Period Select bits (Divider ratio 1:65536; software control of WDTPS)
  CONFIG  WDTE = OFF            ; WDT operating mode (WDT Disabled)

; CONFIG3H
  CONFIG  WDTCWS = WDTCWS_7     ; WDT Window Select bits (window always open (100%); software control; keyed access not required)
  CONFIG  WDTCCS = SC           ; WDT input clock selector (Software Control)

; CONFIG4L
  CONFIG  WRT0 = OFF            ; Write Protection Block 0 (Block 0 (000800-003FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection Block 1 (Block 1 (004000-007FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection Block 2 (Block 2 (008000-00BFFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection Block 3 (Block 3 (00C000-00FFFFh) not write-protected)
  CONFIG  WRT4 = OFF            ; Write Protection Block 4 (Block 4 (010000-013FFFh) not write-protected)
  CONFIG  WRT5 = OFF            ; Write Protection Block 5 (Block 5 (014000-017FFFh) not write-protected)
  CONFIG  WRT6 = OFF            ; Write Protection Block 6 (Block 6 (018000-01BFFFh) not write-protected)
  CONFIG  WRT7 = OFF            ; Write Protection Block 7 (Block 7 (01C000-01FFFFh) not write-protected)

; CONFIG4H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-30000Bh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)
  CONFIG  SCANE = ON            ; Scanner Enable bit (Scanner module is available for use, SCANMD bit can control the module)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored)

; CONFIG5L
  CONFIG  CP = OFF              ; UserNVM Program Memory Code Protection bit (UserNVM code protection disabled)
  CONFIG  CPD = OFF             ; DataNVM Memory Code Protection bit (DataNVM code protection disabled)

; CONFIG5H

; CONFIG6L
  CONFIG  EBTR0 = OFF           ; Table Read Protection Block 0 (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection Block 1 (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection Block 2 (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection Block 3 (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR4 = OFF           ; Table Read Protection Block 4 (Block 4 (010000-013FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR5 = OFF           ; Table Read Protection Block 5 (Block 5 (014000-017FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR6 = OFF           ; Table Read Protection Block 6 (Block 6 (018000-01BFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR7 = OFF           ; Table Read Protection Block 7 (Block 7 (01C000-01FFFFh) not protected from table reads executed in other blocks)

; CONFIG6H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)

#include <xc.inc>
;
; The initialzation code must configure this oscillator frequency.
;
FSYS SET 64000000       ; System oscillator frequency
FCYC SET FSYS/4         ; Instruction cycle frequency
;
; Power On Reset entry point
;
    PSECT   resetVec,class=CODE,reloc=2
    global  PORreset
PORreset:
    goto    main
;
;   High priority interrupt vector
    PSECT   hi_int_vec,global,reloc=2,class=CODE,delta=1
;
    goto    HiIsrHandler
;
;   Data space use by low priority interrupt handler to save context
    PSECT   LoIsr_data,global,class=COMRAM,space=1,delta=1,lowdata,noexec
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
    movwf   WREG_save,C
    movf    STATUS,W,C
    movwf   STATUS_save,C
    movf    BSR,W,C
    movwf   BSR_save,C
;
tmr0Isr:
    BANKSEL PIE0
    btfsc   BANKMASK(PIE0),PIE0_TMR0IE_POSITION,b
    btfss   BANKMASK(PIR0),PIR0_TMR0IF_POSITION,b
    bra     LowIsrExit
    bcf     BANKMASK(PIR0),PIR0_TMR0IF_POSITION,b
    BANKSEL LATA
    btg     BANKMASK(LATA),LATA_LATA4_POSITION,c
tmr0IsrExit:
;
LowIsrExit:
    movf    BSR_save,W,C
    movwf   BSR,C
    movf    STATUS_save,W,C
    movwf   STATUS,C
    swapf   WREG_save,F,C
    swapf   WREG_save,W,C
    retfie  0   ; Return from interrupt
;
;   High priority interrupt handler
    PSECT   HiIsrCode,global,reloc=2,class=CODE,delta=1
;
HiIsrHandler:
;
;
;
iocIsr:
    BANKSEL PIE0
    btfsc   BANKMASK(PIE0),PIE0_IOCIE_POSITION,b
    btfss   BANKMASK(PIR0),PIR0_IOCIF_POSITION,b
    bra     iocIsrExit

    BANKSEL IOCBF
    btfss   BANKMASK(IOCBF),IOCBF_IOCBF4_POSITION,b
    bra     iocB4_Exit
; 
; Clear IOC flags for PORTB bits
;
    movlw   0xFF
    xorwf   BANKMASK(IOCBF),W,b
    andwf   BANKMASK(IOCBF),F,b
    BANKSEL LATA
    btg     BANKMASK(LATA),LATA_LATA6_POSITION,b
iocB4_Exit:

    BANKSEL IOCCF
    btfss   BANKMASK(IOCCF),IOCCF_IOCCF5_POSITION,b
    bra     iocC5_Exit
; 
; Clear IOC flags for PORTC bits
;
    movlw   0xFF
    xorwf   BANKMASK(IOCCF),W,b
    andwf   BANKMASK(IOCCF),F,b
    BANKSEL LATA
    btg     BANKMASK(LATA),LATA_LATA5_POSITION,B
iocC5_Exit:
iocIsrExit:
    retfie  1   ; Fast return from interrupt
;
; Initialize this PIC
;
    PSECT   code
    global  PIC_Init

PIC_Init:
    clrf    INTCON,C
    bsf     INTCON,INTCON_IPEN_POSITION,C   ; enable priority interrupt handling
    BANKSEL (OSCFRQ)
    movlw   0x08
    movwf   BANKMASK(OSCFRQ),B      ; Set FOSC as HFINTOSC at 64MHz
    movlw   0x60
    movwf   BANKMASK(OSCCON1),B     ; Select HFINTOSC
    clrf    BANKMASK(OSCCON3),B
    clrf    BANKMASK(OSCEN),B
    clrf    BANKMASK(OSCTUNE),B
    BANKSEL (PIE0)
    clrf    BANKMASK(PIE0),B
    clrf    BANKMASK(PIE1),B
    clrf    BANKMASK(PIE2),B
    clrf    BANKMASK(PIE3),B
    clrf    BANKMASK(PIE4),B
    clrf    BANKMASK(PIE5),B
    clrf    BANKMASK(PIE6),B
    clrf    BANKMASK(PIE7),B
    BANKSEL (ANSELA)
    clrf    BANKMASK(ANSELA),B
    clrf    BANKMASK(ANSELB),B
    clrf    BANKMASK(ANSELC),B
    clrf    BANKMASK(ANSELD),B
    clrf    BANKMASK(ANSELE),B
    BANKSEL (TRISA)
    setf    BANKMASK(TRISA),B
    setf    BANKMASK(TRISB),B
    setf    BANKMASK(TRISC),B
    setf    BANKMASK(TRISD),B
    setf    BANKMASK(TRISE),B
    return
;
; Initialize TIMER0
;
TIMER0_Init:
    BANKSEL PIE0
    bcf     BANKMASK(PIE0),PIE0_TMR0IE_POSITION,b
    bcf     BANKMASK(IPR0),IPR0_TMR0IP_POSITION,b
    BANKSEL T0CON1
    movlw   0x4E                        ; TIMER0 clock source as FOSC/4 (only one that works in simulation), prescaler 1:16384
    movwf   BANKMASK(T0CON1),b          ; FOSC/4 is 16MHz
    movlw   0xF3                        ; TIMER0 interrupt period (1/16000)*16384*244 = 249.856 milliseconds
    movwf   BANKMASK(TMR0H),b           
    clrf    BANKMASK(TMR0L),b
    BANKSEL PIR0
    bcf     BANKMASK(PIR0),PIR0_TMR0IF_POSITION,b
    bsf     BANKMASK(PIE0),PIE0_TMR0IE_POSITION,b
    BANKSEL T0CON1
    movlw   0x80
    movwf   BANKMASK(T0CON0),b
    return
;
; Initialize Interrupt On Change
;
IOC_Init:
    BANKSEL PIE0
    bcf     BANKMASK(PIE0),PIE0_IOCIE_POSITION,b
    bsf     BANKMASK(IPR0),IPR0_IOCIP_POSITION,b
    BANKSEL IOCAF
    clrf    BANKMASK(IOCAN),b
    clrf    BANKMASK(IOCBN),b
    clrf    BANKMASK(IOCCN),b
    clrf    BANKMASK(IOCAP),b
    clrf    BANKMASK(IOCBP),b
    clrf    BANKMASK(IOCCP),b
    clrf    BANKMASK(IOCAF),b
    clrf    BANKMASK(IOCBF),b
    clrf    BANKMASK(IOCCF),b
    BANKSEL ANSELB
    bcf     BANKMASK(ANSELB),ANSELB_ANSELB4_POSITION,b
    bcf     BANKMASK(ANSELC),ANSELC_ANSELC5_POSITION,b
    BANKSEL TRISB
    bsf     BANKMASK(TRISB),TRISB_TRISB4_POSITION,b
    bsf     BANKMASK(TRISC),TRISC_TRISC5_POSITION,b
    BANKSEL IOCBN
    bsf     BANKMASK(IOCBN),IOCBN_IOCBN4_POSITION,b
    bsf     BANKMASK(IOCCN),IOCCN_IOCCN5_POSITION,b
    BANKSEL IOCBF
    movlw   0xFF
    xorwf   BANKMASK(IOCBF),W,b
    andwf   BANKMASK(IOCBF),F,b
    movlw   0xFF
    xorwf   BANKMASK(IOCCF),W,b
    andwf   BANKMASK(IOCCF),F,b
    BANKSEL PIE0
    bsf     BANKMASK(PIE0),PIE0_IOCIE_POSITION,b    ; Code cannot set this bit in the simulator (2021-MAR-26)
    return
;
; Initialize the EUSART2
;
U2_BAUD SET 9600
SP2BRG_VALUE SET (FCYC/U2_BAUD)
;
    global  EUSART2_Init
EUSART2_Init:
    BANKSEL (PIE3)
    bcf     BANKMASK(PIE3),PIE3_RC2IE_POSITION,B
    bcf     BANKMASK(PIE3),PIE3_TX2IE_POSITION,B

    BANKSEL (BAUD2CON)
    movlw   0x08            ; ABDOVF no_overflow; SCKP Non-Inverted; BRG16 16bit_generator; WUE disabled; ABDEN disabled; 
    movwf   BANKMASK(BAUD2CON),B

    BANKSEL (RC2STA)
    movlw   0x90            ; SPEN enabled; RX9 8-bit; CREN enabled; ADDEN disabled; SREN disabled; 
    movwf   BANKMASK(RC2STA),B

    BANKSEL (TX2STA)
    movlw   0x24            ; TX9 8-bit; TX9D 0; SENDB sync_break_complete; TXEN enabled; SYNC asynchronous; BRGH hi_speed; CSRC slave; 
    movwf   BANKMASK(TX2STA),B

    BANKSEL (SP2BRGL)
    movlw   low(SP2BRG_VALUE)
    movwf   BANKMASK(SP2BRGL),B
    movlw   high(SP2BRG_VALUE)
    movwf   BANKMASK(SP2BRGH),B

    BANKSEL (LATD)
    bsf     LATD,LATD_LATD0_POSITION,B
    bcf     TRISD,TRISD_TRISD0_POSITION,B
    bsf     TRISD,TRISD_TRISD1_POSITION,B

    BANKSEL (RD0PPS)
    movlw   0x0B        ; RD0->EUSART2:TX2
    movwf   BANKMASK(RD0PPS),B

    BANKSEL (RX2PPS)
    movlw   0x19        ; RD1->EUSART2:RX2
    movwf   BANKMASK(RX2PPS),B

    return
;
; Write a byte to EUSART2
;
EUSART2_Write:
    BANKSEL (TX2STA)
EUSART2_WaitForTx:
    btfss   BANKMASK(TX2STA),TX2STA_TRMT_POSITION,B
    bra     EUSART2_WaitForTx
    BANKSEL (TX2REG)
    movwf   BANKMASK(TX2REG),B
    return
;
; Send an ASCIIZ string from ROM to EUSART2
;
EUSART2_PutsRom:
    tblrd*+
    movf    TABLAT,W,C
    btfsc   STATUS,STATUS_Z_POSITION,C
    return
    call    EUSART2_Write
    bra     EUSART2_PutsRom
;
; Message sent after Power-On-Reset
;
    psect	smallconst,global,reloc=2,class=SMALLCONST,delta=1,noexec
SignOn:
        db  'D','M','1','6','4','1','3','6',' ','w','i','t','h',' '
        db  '1','8','F','4','7','Q','1','0',' ','s','t','a','r','t',' '
        IRPC ch,built on __DATE__ at __TIME__
      if 'ch' <> '"'
        db 'ch'
      endif
        endm
        db  13,10,0
;
; Data for Delay function
;
    psect   DelayData,global,class=RAM,space=1,delta=1,noexec
    global  DelayCounter
DelayCounter:  ds 3
;
; Setup for 500 millisecond delay
;
LOOP_CYCLES SET 6
DELAYS_PER_SECOND SET 2
LOOP_COUNT SET (FCYC/(DELAYS_PER_SECOND*LOOP_CYCLES))-3
;
; Delay spin wait for 500 miliseconds
;
    PSECT   code
Delay:
    BANKSEL (DelayCounter)
    movlw   low(LOOP_COUNT)
    movwf   BANKMASK(DelayCounter+0),B
    movlw   high(LOOP_COUNT)
    movwf   BANKMASK(DelayCounter+1),B
    movlw   low highword(LOOP_COUNT)
    movwf   BANKMASK(DelayCounter+2),B
    movlw   0
DelayLoop:
    bcf     STATUS,STATUS_C_POSITION,C      ; 1
    subwfb  BANKMASK(DelayCounter+0),F,B    ; 1
    subwfb  BANKMASK(DelayCounter+1),F,B    ; 1
    subwfb  BANKMASK(DelayCounter+2),F,B    ; 1
    bc      DelayLoop                       ; 2, total 6 cycles per loop
    return
;
; Main Application
;
    PSECT   code
    global  main
main:
;
; Application initialization
;
    call    PIC_Init
    call    EUSART2_Init
    call    IOC_Init
    call    TIMER0_Init
    movlw   low(SignOn)
    movwf   TBLPTRL,C
    movlw   high(SignOn)
    movwf   TBLPTRH,C
    movlw   low highword(SignOn)
    movwf   TBLPTRU,C
    call    EUSART2_PutsRom
    
    BANKSEL (LATA)
    bcf     BANKMASK(LATA),LATA_LATA7_POSITION,B
    bcf     BANKMASK(TRISA),TRISA_TRISA7_POSITION,B
    bcf     BANKMASK(LATA),LATA_LATA6_POSITION,B
    bcf     BANKMASK(TRISA),TRISA_TRISA6_POSITION,B
    bcf     BANKMASK(LATA),LATA_LATA5_POSITION,B
    bcf     BANKMASK(TRISA),TRISA_TRISA5_POSITION,B
    bcf     BANKMASK(LATA),LATA_LATA4_POSITION,B
    bcf     BANKMASK(TRISA),TRISA_TRISA4_POSITION,B

    BANKSEL INTCON
    bsf     INTCON,INTCON_GIEL_POSITION,C
    bsf     INTCON,INTCON_GIEH_POSITION,C
;
; Application process loop
;
AppLoop:
    BANKSEL (LATA)
    btg     BANKMASK(LATA),LATA_LATA7_POSITION,B
    call    Delay

    bra     AppLoop

; Tell linker the address of the Power-On-Reset
    end     PORreset