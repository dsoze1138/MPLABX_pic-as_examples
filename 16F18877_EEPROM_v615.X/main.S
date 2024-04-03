; Date: 2023-DEC-02
; File: main.S
; Target: PIC16F18877
; MPLABX: v6.15
; Compiler: pic-as(v2.45)
;  
; Description:
;
;   Hardware: DM164163 Curiosity HPC demo board.
;
;   Example appliction for PIC16F18877.
;   Access EEPROM area, read and write byte at address 0
;   
;                        PIC16F18877
;                 +----------:_:----------+
;       VPP ->  1 : RE3/MCLR/VPP  PGD/RB7 : 40 <> PGD
;       POT ->  2 : RA0/AN0       PGC/RB6 : 39 <> PGC
;           <>  3 : RA1               RB5 : 38 <>
;           <>  4 : RA2               RB4 : 37 <> SW1
;           <>  5 : RA3               RB3 : 36 <>
;   LED_D2  <>  6 : RA4               RB2 : 35 <>
;   LED_D3  <>  7 : RA5               RB1 : 34 <> 
;           <>  8 : RE0               RB0 : 33 <> 
;           <>  9 : RE1               VDD : 32 <- PWR
;           <> 10 : RE2               VSS : 31 <- GND
;       PWR -> 11 : VDD               RD7 : 30 <>
;       GND -> 12 : VSS               RD6 : 29 <>
;           <> 13 : RA7/OSC1          RD5 : 28 <>
;           <> 14 : RA6/OSC2          RD4 : 27 <>
;           <> 15 : RC0/SOSCO         RC7 : 26 <> RXD
;           <> 16 : RC1/SOSCI         RC6 : 25 <> TXD
;           <> 17 : RC2/CCP1          RC5 : 24 <> SW2
;           <> 18 : RC3               RC4 : 23 <>
;           <> 19 : RD0               RD3 : 22 <>
;           <> 20 : RD1               RD2 : 21 <>
;                 +-----------------------:
;                          DIP-40
;
; Add this line in the project properties box "pic-as Global Options -> Additional options":
;
;   -Wa,-a -Wl,-DCODE=2,-pResetVec=0h,-pISR_Vec=4h
;
    PROCESSOR   16F18877
    PAGEWIDTH   132
    RADIX       dec
;
; Define the system oscillator the code is expected to setup
;
#define _XTAL_FREQ (4000000)
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
  CONFIG  FEXTOSC = OFF, RSTOSC = HFINT32, CLKOUTEN = OFF, CSWEN = ON, FCMEN = ON
  CONFIG  MCLRE = ON, PWRTE = OFF, LPBOREN = OFF, BOREN = OFF, BORV = LO, ZCD = OFF, PPS1WAY = OFF, STVREN = ON
  CONFIG  WDTCPS = WDTCPS_31, WDTE = OFF, WDTCWS = WDTCWS_7, WDTCCS = SC
  CONFIG  WRT = OFF, SCANE = available, LVP = ON
  CONFIG  CP = OFF, CPD = OFF
;
; Skip macros
;
skipnc  MACRO
    btfsc   STATUS,STATUS_C_POSITION
        ENDM
 
skipc   MACRO
    btfss   STATUS,STATUS_C_POSITION
        ENDM
 
skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
        ENDM
 
skipz   MACRO
    btfss   STATUS,STATUS_Z_POSITION
        ENDM
;
; EEPROM
;
    PSECT   edata,global,class=EEDATA,space=3,delta=2,noexec
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  0x64,255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  0x64,255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  0x32,255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  0x32,255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    db  255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
;
; Reset vector
;
    PSECT   ResetVec,class=CODE,delta=2
    global  ResetVector
ResetVector:
    pagesel Start
    goto    Start
;
;   Data space use by interrupt handler
    PSECT   Isr_Data,global,class=COMMON,space=1,delta=1,noexec
LED_D2_wait:DS      1
EEPROM_Data:DS      1

#define TIMER0_TICKS_TO_LED_TOGGLE 10
;
; Interrupt vector
;
    PSECT   ISR_Vec,class=CODE,delta=2
    global  ISR
ISR:
    banksel PIE0
    btfsc   PIE0,PIE0_TMR0IE_POSITION
    btfss   PIR0,PIR0_TMR0IF_POSITION
    goto    ISR_TIMER0_EXIT
    bcf     PIR0,PIR0_TMR0IF_POSITION
    movf    LED_D2_wait,F
    skipnz
    goto    ISR_TIMER0_EXIT
    decfsz  LED_D2_wait,F
    goto    ISR_TIMER0_EXIT
    movlw   TIMER0_TICKS_TO_LED_TOGGLE
    movwf   LED_D2_wait
    banksel LATA
    movlw   (1<<LATA_LATA4_POSITION)
    xorwf   LATA,F      ; Toggle LED_D3
ISR_TIMER0_EXIT:

    retfie
;
; EEPROM Read
;
; Input:  NVMADRH:NVMADRL EEPROM address
;         ;
; Output: WREG data from EEPROM address
;
EEPROM_Read:
    banksel NVMCON1
    bsf     NVMCON1,NVMCON1_NVMREGS_POSITION
    bsf     NVMCON1,NVMCON1_RD_POSITION
EEPROM_RD_Wait:
    nop
    btfsc   NVMCON1,NVMCON1_RD_POSITION
    bra     EEPROM_RD_Wait
    movf    NVMDATL,W
    return
;
; EEPROM Write.
;
; Input:  WREG EEPROM data
;         NVMADRH:NVMADRL EEPROM address
;
; Output: None
;
EEPROM_Write:
    banksel NVMCON1
    bsf     NVMCON1,NVMCON1_NVMREGS_POSITION
    bsf     NVMCON1,NVMCON1_WREN_POSITION
    movwf   NVMDATL
    movlw   0xFF
    movwf   NVMDATH
;
; Enter critical region
    rlf     INTCON,W
    bcf     INTCON,INTCON_GIE_POSITION
    movlw   0x55
    movwf   NVMCON2
    movlw   0xAA
    movwf   NVMCON2
    bsf     NVMCON1,NVMCON1_WR_POSITION
    nop
    nop
    skipnc
    bsf     INTCON,INTCON_GIE_POSITION
; Exit critical region
;
EEPROM_WR_Wait:
    btfsc   NVMCON1,NVMCON1_WR_POSITION
    bra     EEPROM_WR_Wait
    return
;
; EEPROM SetAddress.
;
; Input:  WREG EEPROM Address (0x00 to 0xFF)
;
; Output: WREG written to NVMADRL, 0xF0 written to NVMADRH
;
EEPROM_SetAddress:
    banksel NVMADRL
    movwf   NVMADRL
    movlw   0xF0
    movwf   NVMADRH
    return
;
; EEPROM NextAddress.
;
; Input:  NVMADRL
;
; Output: NVMADRL EEPROM addess is incrememntd
;
EEPROM_NextAddress:
    banksel NVMADRL
    incf    NVMADRL,F
    return

; Main application data
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
SpinWait:   DS      2
;
; Main application code
;
    PSECT   MainCode,global,class=CODE,delta=2
Start:
    clrf    INTCON      ; Disable all interrupts
    banksel PIE0
    clrf    PIE0
    clrf    PIE1
    clrf    PIE2
    clrf    PIE3
    clrf    PIE4
    clrf    PIE5
    clrf    PIE6
    clrf    PIE7
    clrf    PIE8
;
; Clear RAM PIC16F18877
;
#define END_OF_LINEAR_RAM 0x2000+80*51-1
    
    movlw   high (END_OF_LINEAR_RAM)
    movwf   FSR0H
    movlw   low  (END_OF_LINEAR_RAM)
    movwf   FSR0L
    movlw   0
ClearLinearRAM:
    movwi   FSR0--
    btfsc   FSR0H,5
    bra     ClearLinearRAM
ClearCommonRAM:    
    movwi   FSR0--
    btfsc   FSR0L,4
    bra     ClearCommonRAM
 
    banksel OSCCON1
    movlw   0x63        ; System oscillator set to 4MHz
    movwf   OSCCON1
 
    banksel T0CON1
    movlw   0x48        ; Set TIMER0 clock source to FOSC/4, scale 1:256 TIMER0 overflows every 32.768 milliseconds
    movwf   T0CON1
    banksel T0CON0
    movlw   0x80        ; Start TIMER0
    movwf   T0CON0
 
    banksel TRISA
    bcf     TRISA,TRISA_TRISA4_POSITION
    bcf     TRISA,TRISA_TRISA5_POSITION
    banksel LATA
    bcf     LATA,LATA_LATA4_POSITION
    bcf     LATA,LATA_LATA5_POSITION
;
; Seup TIMER0
; 
    banksel TMR0L
    clrf    TMR0L
    movlw   0xFF
    movwf   TMR0H
    banksel PIR0
    bcf     PIR0,PIR0_TMR0IF_POSITION
    bsf     PIE0,PIE0_TMR0IE_POSITION
    movlw   TIMER0_TICKS_TO_LED_TOGGLE
    movwf   LED_D2_wait
;
; Setup UART
;
#define BRG_VALUE ((_XTAL_FREQ)/(4*9600))-1
    banksel BAUD1CON
    movlw   0x08
    movwf   BAUD1CON
    movlw   0x90
    movwf   RC1STA
    movlw   0x24
    movwf   TX1STA
    movlw   BRG_VALUE
    movwf   SP1BRGL
    movlw   BRG_VALUE>>8
    movwf   SP1BRGH

    banksel ANSELC
    bcf     ANSELC,ANSELC_ANSC6_POSITION
    bcf     ANSELC,ANSELC_ANSC7_POSITION
    bcf     SLRCONC,SLRCONC_SLRC6_POSITION
    bcf     ODCONC,ODCONC_ODCC6_POSITION
    bsf     WPUC,WPUC_WPUC7_POSITION
    banksel LATC
    bsf     LATC,LATC_LATC6_POSITION
    bcf     TRISC,TRISC_TRISC6_POSITION
    bsf     TRISC,TRISC_TRISC7_POSITION

    banksel RXPPS
    movlw   0x17        ; RC7->EUSART1:RX1
    movwf   RXPPS
    banksel RC6PPS
    movlw   0x10        ; RC6->EUSART1:TX1
    movwf   RC6PPS
;
; Enable system interrupts
; 
    bsf     INTCON,INTCON_PEIE_POSITION
    bsf     INTCON,INTCON_GIE_POSITION
;
; Start application
    goto    AppInit
;
; Spin wait
;
Delay:
    banksel SpinWait
    clrf    SpinWait
    clrf    SpinWait+1
Delay_1:
    incfsz  SpinWait,F
    goto    Delay_1
    incfsz  SpinWait+1,F
    goto    Delay_1
    return
;
; UART send byte
;
U1_Write:
    banksel TX1STA
U1_Wait:
    btfss   TX1STA,TX1STA_TRMT_POSITION
    goto    U1_Wait

    banksel TX1REG
    movwf   TX1REG      ; Write the data byte to the UART.
    return
;
; UART send WREG low 4-bits as ASCII HEX character
;
U1_SendHEX:
    andlw   0x0F
    addlw   -10
    skipnc
    addlw   'A'-'9'-1
    addlw   '0'+10
    goto    U1_Write
;
; UART send carriage return, line feed
;
U1_CRLF:
    movlw   0x0D
    call    U1_Write
    movlw   0x0A
    goto    U1_Write
;
; UART send ADC sample in HEX
;
U1_DumpEEPROM:
    movlw   '0'
    call    U1_Write
    movlw   'x'
    call    U1_Write
    banksel NVMADRH
    swapf   NVMADRH,W
    call    U1_SendHEX
    banksel NVMADRH
    movf    NVMADRH,W
    call    U1_SendHEX
    banksel NVMADRL
    swapf   NVMADRL,W
    call    U1_SendHEX
    banksel NVMADRL
    movf    NVMADRL,W
    call    U1_SendHEX
    movlw   ':'
    call    U1_Write
    movlw   ' '
    call    U1_Write
    swapf   EEPROM_Data,W
    call    U1_SendHEX
    movf    EEPROM_Data,W
    call    U1_SendHEX
    
    goto    U1_CRLF
;
; Send Power-On-Reset message
;
Send_POR_Message:
    movlw   low(POR_Message)
    movwf   FSR0L
    movlw   high(POR_Message)
    movwf   FSR0H
    bsf     FSR0H,7     ; Access in code space
Send_MessageLoop:
    movf    INDF0,w
    skipnz
    goto    Send_MessageExit
    call    U1_Write
    addfsr  FSR0,1
    goto    Send_MessageLoop
Send_MessageExit:
    return
;
; Initialize application
;
AppInit:
    call    Delay       ; Leave UART at stop bit state so garbage doesn't go out after a reset
    call    Send_POR_Message
;
; Test EEPROM:
;   Read value at EEPROM address 0x00
;   Print value at EEPROM address 0x00
;   Increment value at EEPROM address 0x00
;
    movlw   0x00
    call    EEPROM_SetAddress
    call    EEPROM_Read
    movwf   EEPROM_Data
    call    U1_DumpEEPROM
    incf    EEPROM_Data,W
    call    EEPROM_Write
;
; Application loop
;
AppLoop:
;
; Toggle LED_D3
;
    banksel LATA
    movlw   (1<<LATA_LATA5_POSITION)
    xorwf   LATA,F      ; Toggle LED_D3
    call    Delay

    goto    AppLoop     ;loop forever
;
; Text message strings
;
    PSECT   MsgStrings,global,class=CODE,delta=2
POR_Message:
    dw      0x0D,0x0A
    dw      "PIC16F18877 EEPROM demo built on "
    dw      __DATE__
    dw      " at "
    dw      __TIME__
    dw      0x0D,0x0A
    retlw   0

    end     ResetVector