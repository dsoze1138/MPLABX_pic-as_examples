; File:   main.S
; Author: dan1138
; Target: PIC18F47Q43
; Compiler: pic-as v2.31
; IDE: MPLABX v5.45
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-presetVec=0h -Wl,-pivt=08h -Wa,-a
;
; Description:
;
;   Example code that initializes the Interrupt Vector Table
;
    PROCESSOR   18F47Q43
    PAGEWIDTH   162
    RADIX       dec
;

#include <xc.inc>

; CONFIG1
  CONFIG  FEXTOSC = OFF         ; External Oscillator Selection (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_64MHZ; Reset Oscillator Selection (HFINTOSC with HFFRQ = 64 MHz and CDIV = 1:1)

; CONFIG2
  CONFIG  CLKOUTEN = OFF        ; Clock out Enable bit (CLKOUT function is disabled)
  CONFIG  PR1WAY = OFF          ; PRLOCKED One-Way Set Enable bit (PRLOCKED bit can be set and cleared repeatedly)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)

; CONFIG3
  CONFIG  MCLRE = EXTMCLR       ; MCLR Enable bit (If LVP = 0, MCLR pin is MCLR; If LVP = 1, RE3 pin function is MCLR )
  CONFIG  PWRTS = PWRT_OFF      ; Power-up timer selection bits (PWRT is disabled)
  CONFIG  MVECEN = ON           ; Multi-vector enable bit (Multi-vector enabled, Vector table used for interrupts)
  CONFIG  IVT1WAY = OFF         ; IVTLOCK bit One-way set enable bit (IVTLOCKED bit can be cleared and set repeatedly)
  CONFIG  LPBOREN = OFF         ; Low Power BOR Enable bit (Low-Power BOR disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable bits (Brown-out Reset disabled)

; CONFIG4
  CONFIG  BORV = VBOR_1P9       ; Brown-out Reset Voltage Selection bits (Brown-out Reset Voltage (VBOR) set to 1.9V)
  CONFIG  ZCD = OFF             ; ZCD Disable bit (ZCD module is disabled. ZCD can be enabled by setting the ZCDSEN bit of ZCDCON)
  CONFIG  PPS1WAY = OFF         ; PPSLOCK bit One-Way Set Enable bit (PPSLOCKED bit can be set and cleared repeatedly (subject to the unlock sequence))
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Extended Instruction Set and Indexed Addressing Mode disabled)

; CONFIG5
  CONFIG  WDTCPS = WDTCPS_31    ; WDT Period selection bits (Divider ratio 1:65536; software control of WDTPS)
  CONFIG  WDTE = OFF            ; WDT operating mode (WDT Disabled; SWDTEN is ignored)

; CONFIG6
  CONFIG  WDTCWS = WDTCWS_7     ; WDT Window Select bits (window always open (100%); software control; keyed access not required)
  CONFIG  WDTCCS = SC           ; WDT input clock selector (Software Control)

; CONFIG7
  CONFIG  BBSIZE = BBSIZE_512   ; Boot Block Size selection bits (Boot Block size is 512 words)
  CONFIG  BBEN = OFF            ; Boot Block enable bit (Boot block disabled)
  CONFIG  SAFEN = OFF           ; Storage Area Flash enable bit (SAF disabled)
  CONFIG  DEBUG = OFF           ; Background Debugger (Background Debugger disabled)

; CONFIG8
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block not Write protected)
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers not Write protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not Write protected)
  CONFIG  WRTSAF = OFF          ; SAF Write protection bit (SAF not Write Protected)
  CONFIG  WRTAPP = OFF          ; Application Block write protection bit (Application Block not write protected)

; CONFIG10
  CONFIG  CP = OFF              ; PFM and Data EEPROM Code Protection bit (PFM and Data EEPROM code protection disabled)
;
;
;
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
    DW  Default_ISR shr 2   ; IVT -   0(0x00) Software Interrupt
    DW  Default_ISR shr 2   ; IVT -   1(0x01) HLVD (High/Low-Voltage Detect)
    DW  Default_ISR shr 2   ; IVT -   2(0x02) OSF (Oscillator Fail)
    DW  Default_ISR shr 2   ; IVT -   3(0x03) CSW (Clock Switching)
    DW  Default_ISR shr 2   ; IVT -   4(0x04) reserved
    DW  Default_ISR shr 2   ; IVT -   5(0x05) CLC1 (Configurable Logic Cell)
    DW  Default_ISR shr 2   ; IVT -   6(0x06) reserved
    DW      ioc_Isr shr 2   ; IVT -   7(0x07) IOC (Interrupt-On-Change)
    DW  Default_ISR shr 2   ; IVT -   8(0x08) INT0
    DW  Default_ISR shr 2   ; IVT -   9(0x09) ZCD (Zero-Cross Detection)
    DW  Default_ISR shr 2   ; IVT -  10(0x0A) AD (ADC Conversion Complete)
    DW  Default_ISR shr 2   ; IVT -  11(0x0B) ACT (Active Clock Tuning)
    DW  Default_ISR shr 2   ; IVT -  12(0x0C) CM1 (Comparator)
    DW  Default_ISR shr 2   ; IVT -  13(0x0D) SMT1 (Signal Measurement Timer)
    DW  Default_ISR shr 2   ; IVT -  14(0x0E) SMT1PRA
    DW  Default_ISR shr 2   ; IVT -  15(0x0F) SMT1PWA
    DW  Default_ISR shr 2   ; IVT -  16(0x10) ADT
    DW  Default_ISR shr 2   ; IVT -  17(0x11) reserved
    DW  Default_ISR shr 2   ; IVT -  18(0x12) reserved
    DW  Default_ISR shr 2   ; IVT -  19(0x13) reserved
    DW  Default_ISR shr 2   ; IVT -  20(0x14) DMA1SCNT (Direct Memory Access)
    DW  Default_ISR shr 2   ; IVT -  21(0x15) DMA1DCNT
    DW  Default_ISR shr 2   ; IVT -  22(0x16) DMA1OR
    DW  Default_ISR shr 2   ; IVT -  23(0x17) DMA1A
    DW  Default_ISR shr 2   ; IVT -  24(0x18) SPI1RX (Serial Peripheral Interface)
    DW  Default_ISR shr 2   ; IVT -  25(0x19) SPI1TX
    DW  Default_ISR shr 2   ; IVT -  26(0x1A) SPI1
    DW  Default_ISR shr 2   ; IVT -  27(0x1B) TMR2
    DW  Default_ISR shr 2   ; IVT -  28(0x1C) TMR1
    DW  Default_ISR shr 2   ; IVT -  29(0x1D) TMR1G
    DW  Default_ISR shr 2   ; IVT -  30(0x1E) CCP1 (Capture/Compare/PWM)
    DW      tmr0Isr shr 2   ; IVT -  31(0x1F) TMR0
    DW  Default_ISR shr 2   ; IVT -  32(0x20) U1RX
    DW  Default_ISR shr 2   ; IVT -  33(0x21) U1TX
    DW  Default_ISR shr 2   ; IVT -  34(0x22) U1E
    DW  Default_ISR shr 2   ; IVT -  35(0x23) U1
    DW  Default_ISR shr 2   ; IVT -  36(0x24) reserved
    DW  Default_ISR shr 2   ; IVT -  37(0x25) reserved
    DW  Default_ISR shr 2   ; IVT -  38(0x26) PWM1RINT
    DW  Default_ISR shr 2   ; IVT -  39(0x27) PWM1GINT
    DW  Default_ISR shr 2   ; IVT -  40(0x28) SPI2RX
    DW  Default_ISR shr 2   ; IVT -  41(0x29) SPI2TX
    DW  Default_ISR shr 2   ; IVT -  42(0x2A) SPI2
    DW  Default_ISR shr 2   ; IVT -  43(0x2B) reserved
    DW  Default_ISR shr 2   ; IVT -  44(0x2C) TMR3
    DW  Default_ISR shr 2   ; IVT -  45(0x2D) TMR3G
    DW  Default_ISR shr 2   ; IVT -  46(0x2E) PWM2RINT
    DW  Default_ISR shr 2   ; IVT -  47(0x2F) PWM2GINT
    DW  Default_ISR shr 2   ; IVT -  48(0x30) INT1
    DW  Default_ISR shr 2   ; IVT -  49(0x31) CLC2
    DW  Default_ISR shr 2   ; IVT -  50(0x32) CWG1 (Complementary Waveform Generator)
    DW  Default_ISR shr 2   ; IVT -  51(0x33) NCO1 (Numerically Controlled Oscillator)
    DW  Default_ISR shr 2   ; IVT -  52(0x34) DMA2SCNT
    DW  Default_ISR shr 2   ; IVT -  53(0x35) DMA2DCNT
    DW  Default_ISR shr 2   ; IVT -  54(0x36) DMA2OR
    DW  Default_ISR shr 2   ; IVT -  55(0x37) DMA2A
    DW  Default_ISR shr 2   ; IVT -  56(0x38) I2C1RX
    DW  Default_ISR shr 2   ; IVT -  57(0x39) I2C1TX
    DW  Default_ISR shr 2   ; IVT -  58(0x3A) I2C1
    DW  Default_ISR shr 2   ; IVT -  59(0x3B) I2C1E
    DW  Default_ISR shr 2   ; IVT -  60(0x3C) reserved
    DW  Default_ISR shr 2   ; IVT -  61(0x3D) CLC3
    DW  Default_ISR shr 2   ; IVT -  62(0x3E) PWM3RINT
    DW  Default_ISR shr 2   ; IVT -  63(0x3F) PWM3GINT
    DW  Default_ISR shr 2   ; IVT -  64(0x40) U2RX
    DW  Default_ISR shr 2   ; IVT -  65(0x41) U2TX
    DW  Default_ISR shr 2   ; IVT -  66(0x42) U2E
    DW  Default_ISR shr 2   ; IVT -  67(0x43) U2
    DW  Default_ISR shr 2   ; IVT -  68(0x44) TMR5
    DW  Default_ISR shr 2   ; IVT -  69(0x45) TMR5G
    DW  Default_ISR shr 2   ; IVT -  70(0x46) CCP2
    DW  Default_ISR shr 2   ; IVT -  71(0x47) SCAN
    DW  Default_ISR shr 2   ; IVT -  72(0x48) U3RX
    DW  Default_ISR shr 2   ; IVT -  73(0x49) U3TX
    DW  Default_ISR shr 2   ; IVT -  74(0x4A) U3E
    DW  Default_ISR shr 2   ; IVT -  75(0x4B) U3
    DW  Default_ISR shr 2   ; IVT -  76(0x4C) reserved
    DW  Default_ISR shr 2   ; IVT -  77(0x4D) CLC4
    DW  Default_ISR shr 2   ; IVT -  78(0x4E) reserved
    DW  Default_ISR shr 2   ; IVT -  79(0x4F) reserved
    DW  Default_ISR shr 2   ; IVT -  80(0x50) INT2
    DW  Default_ISR shr 2   ; IVT -  81(0x51) CLC5
    DW  Default_ISR SHR 2   ; IVT -  82(0x52) CWG2 (Complementary Waveform Genera
    DW  Default_ISR SHR 2   ; IVT -  83(0x53) NCO2
    DW  Default_ISR SHR 2   ; IVT -  84(0x54) DMA3SCNT
    DW  Default_ISR SHR 2   ; IVT -  85(0x55) DMA3DCNT
    DW  Default_ISR SHR 2   ; IVT -  86(0x56) DMA3OR
    DW  Default_ISR SHR 2   ; IVT -  87(0x57) DMA3A
    DW  Default_ISR SHR 2   ; IVT -  88(0x58) CCP3
    DW  Default_ISR SHR 2   ; IVT -  89(0x59) CLC6
    DW  Default_ISR SHR 2   ; IVT -  90(0x5A) CWG3
    DW  Default_ISR SHR 2   ; IVT -  91(0x5B) TMR4
    DW  Default_ISR SHR 2   ; IVT -  92(0x5C) DMA4SCNT
    DW  Default_ISR SHR 2   ; IVT -  93(0x5D) DMA4DCNT
    DW  Default_ISR SHR 2   ; IVT -  94(0x5E) DMA4OR
    DW  Default_ISR SHR 2   ; IVT -  95(0x5F) DMA4A
    DW  Default_ISR SHR 2   ; IVT -  96(0x60) U4RX
    DW  Default_ISR SHR 2   ; IVT -  97(0x61) U4TX
    DW  Default_ISR SHR 2   ; IVT -  98(0x62) U4E
    DW  Default_ISR SHR 2   ; IVT - 109(0x63) U4
    DW  Default_ISR SHR 2   ; IVT - 100(0x64) DMA5SCNT
    DW  Default_ISR SHR 2   ; IVT - 101(0x65) DMA5DCNT
    DW  Default_ISR SHR 2   ; IVT - 102(0x66) DMA5OR
    DW  Default_ISR SHR 2   ; IVT - 103(0x67) DMA5A
    DW  Default_ISR SHR 2   ; IVT - 104(0x68) U5RX
    DW  Default_ISR SHR 2   ; IVT - 105(0x69) U5TX
    DW  Default_ISR SHR 2   ; IVT - 106(0x6A) U5E
    DW  Default_ISR SHR 2   ; IVT - 107(0x6B) U5
    DW  Default_ISR SHR 2   ; IVT - 108(0x6C) DMA6SCNT
    DW  Default_ISR SHR 2   ; IVT - 109(0x6D) DMA6DCNT
    DW  Default_ISR SHR 2   ; IVT - 110(0x6E) DMA6OR
    DW  Default_ISR SHR 2   ; IVT - 111(0x6F) DMA6A
    DW  Default_ISR SHR 2   ; IVT - 112(0x70) reserved
    DW  Default_ISR SHR 2   ; IVT - 113(0x71) CLC7
    DW  Default_ISR SHR 2   ; IVT - 114(0x72) CM2
    DW  Default_ISR SHR 2   ; IVT - 115(0x73) NCO3
    DW  Default_ISR SHR 2   ; IVT - 116(0x74) reserved
    DW  Default_ISR SHR 2   ; IVT - 117(0x75) reserved
    DW  Default_ISR SHR 2   ; IVT - 118(0x76) reserved
    DW  Default_ISR SHR 2   ; IVT - 119(0x77) reserved
    DW  Default_ISR SHR 2   ; IVT - 120(0x78) NVM
    DW  Default_ISR SHR 2   ; IVT - 121(0x79) CLC8
    DW  Default_ISR SHR 2   ; IVT - 122(0x7A) CRC (Cyclic Redundancy Check)
    DW  Default_ISR SHR 2   ; IVT - 123(0x7B) TMR6

    PSECT   DefaultIsr,class=CODE,reloc=4
Default_ISR:
    reset

    PSECT   tmr0Isr,class=CODE,reloc=4
tmr0Isr:
    bcf     TMR0IF
    retfie  f

    PSECT   ioc_Isr,class=CODE,reloc=4
ioc_Isr:
    BANKSEL IOCBF
    btfss   BANKMASK(IOCBF),IOCBF_IOCBF4_POSITION,b
    bra     NoIOCB4
; 
; Clear IOC flags for PORTB bits
;
    movlw   0xFF
    xorwf   BANKMASK(IOCBF),W,b
    andwf   BANKMASK(IOCBF),F,b
NoIOCB4:

    btfss   BANKMASK(IOCCF),IOCCF_IOCCF5_POSITION,b
    bra     NoIOCC5
; 
; Clear IOC flags for PORTC bits
;
    movlw   0xFF
    xorwf   BANKMASK(IOCCF),W,b
    andwf   BANKMASK(IOCCF),F,b
NoIOCC5:
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
    BANKSEL T0CON1
    movlw   0x4B                        ; TIMER0 clock source as FOSC/4 (only one that works in simulation), prescaler 1:2048
    movwf   BANKMASK(T0CON1),b          ; FOSC/4 is 1MHz
    movlw   0xF3                        ; TIMER0 interrupt period (1/1000)*2048*244 = 499.712 milliseconds
    movwf   BANKMASK(TMR0H),b           
    clrf    BANKMASK(TMR0L),b
    BANKSEL PIR3
    bcf     BANKMASK(PIR3),PIR3_TMR0IF_POSITION,b
    bsf     BANKMASK(PIE3),PIE3_TMR0IE_POSITION,b
    BANKSEL T0CON1
    movlw   0x80
    movwf   BANKMASK(T0CON0),b
;
; Configure Interupt On Change(IOC)
;
    BANKSEL PIE0
    bcf     BANKMASK(PIE0),PIE0_IOCIE_POSITION,b
    BANKSEL IOCAF
    clrf    BANKMASK(IOCAN),b
    clrf    BANKMASK(IOCBN),b
    clrf    BANKMASK(IOCCN),b
    clrf    BANKMASK(IOCAP),b
    clrf    BANKMASK(IOCBP),b
    clrf    BANKMASK(IOCCP),b
    movf    PORTA,W,c
    movf    PORTB,W,c
    movf    PORTC,W,c
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
    bsf     GIEL
    bsf     GIEH
;
; Application Loop
;
AppLoop:
    nop
    goto    AppLoop
;
; Build date and time
;
PSECT   BuildStamp,class=CODE,reloc=1
    IRPC ch,built on __DATE__ at __TIME__
  if 'ch' <> '"'
    db 'ch'
  endif
    endm
    db 0

    END     resetVec