;
; File:       main.S
; Target:     PIC18F46K22
; Author:     dan1138
; Date:       2024-MAY-08
; Compiler:   pic-as(v2.45)
; IDE:        MPLABX v6.15
; Demo board: DM164136
;
;                                PIC18F46K22
;                     +--------------:_:--------------+
; SWITCH_S3 VPP ->  1 : RE3/MCLR/VPP     PGD/ANB7/RB7 : 40 <> PGD
;           POT ->  2 : RA0/ANA0         PGC/ANB6/RB6 : 39 <> PGC
;               <>  3 : RA1/ANA1             ANB5/RB5 : 38 <>
;               <>  4 : RA2/ANA2             ANB4/RB4 : 37 <> SWITCH_S1
;   MAX7912_CSn <>  5 : RA3/ANA3             ANB3/RB3 : 36 <> MOSI
;        LED_D2 <>  6 : RA4/ANA4             ANB2/RB2 : 35 <> MISO
;        LED_D3 <>  7 : RA5/ANA5             ANB1/RB1 : 34 <> SCK
;               <>  8 : RE0                  ANB0/RB0 : 33 <>
;               <>  9 : RE1                       VDD : 32 <- PWR
;               <> 10 : RE2                       VSS : 31 <- GND
;           PWR -> 11 : VDD            (U2RX)AND7/RD7 : 30 <> TARGET_RX
;           GND -> 12 : VSS            (U2TX)AND6/RD6 : 29 <> TARGET_TX
;        LED_D5 <> 13 : RA7/ANA7/OSC1        AND5/RD5 : 28 <>
;        LED_D4 <> 14 : RA6/ANA6/OSC2        AND4/RD4 : 27 <>
;               <> 15 : RC0/ANC0/SOSCO       ANC7/RC7 : 26 <>
;               <> 16 : RC1/ANC1/SOSCI       ANC6/RC6 : 25 <>
;               <> 17 : RC2/ANC2             ANC5/RC5 : 24 <> SWITCH_S2
;               <> 18 : RC3/ANC3             ANC4/RC4 : 23 <>
;               <> 19 : RD0/AND0             AND3/RD3 : 22 <>
;               <> 20 : RD1/AND1             AND2/RD2 : 21 <>
;                     +-------------------------------:
;                                   DIP-40
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-presetVec=0h,-phi_int_vec=08h,-plo_int_vec=18h
;
; Description:
;   Hardware: DM164136 Curiosity HPC, PIC18F46K22, MIKROE-1295 8x8-R-click
;   Initialize UART2 at 9600 baud, display start message.
;   Initialize MAX7129, display ASCII character as 5x7 matrix
;   Count down in an 8 digit array using BCD in the low 4-bits of each byte
;   See: https://forum.microchip.com/s/topic/a5CV40000000oRRMAY/t395014
;
; Notes:
;   The DM164136 depends on a controller to support the Peripheral-Pin-Select(PPS) 
;   feature so the on chip SPI function can be mapped to the mikroBUS Click socket. 
;
;   The PIC18F46K22 does not have the PPS feature. This application 
;   uses a bit-bang SPI implementation to interface with the MAX7129 
;   to keep the DM164136 circuit in the standard configuration.
;
    PROCESSOR   18F46k22
    PAGEWIDTH   132
    RADIX       dec

;
; The initialzation code must configure this oscillator frequency.
;
FSYS SET 64000000       ; System oscillator frequency
FCYC SET FSYS/4         ; Instruction cycle frequency

; PIC18F46K22 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1H
  CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block)
  CONFIG  PLLCFG = ON           ; 4X PLL Enable (Oscillator multiplied by 4)
  CONFIG  PRICLKEN = ON         ; Primary clock enable bit (Primary clock is always enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power-up Timer Enable bit (Power up timer disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
  CONFIG  BORV = 190            ; Brown Out Reset Voltage bits (VBOR set to 1.90 V nominal)

; CONFIG2H
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bits (Watch dog timer is always disabled. SWDTEN has no effect.)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC1       ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as digital I/O on Reset)
  CONFIG  CCP3MX = PORTB5       ; P3A/CCP3 Mux bit (P3A/CCP3 input/output is multiplexed with RB5)
  CONFIG  HFOFST = ON           ; HFINTOSC Fast Start-up (HFINTOSC output and ready status are not delayed by the oscillator stable status)
  CONFIG  T3CMX = PORTC0        ; Timer3 Clock input mux bit (T3CKI is on RC0)
  CONFIG  P2BMX = PORTD2        ; ECCP2 B output mux bit (P2B is on RD2)
  CONFIG  MCLRE = EXTMCLR       ; MCLR Pin Enable bit (MCLR pin enabled, RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled if MCLRE is also 1)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection Block 0 (Block 0 (000800-003FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection Block 1 (Block 1 (004000-007FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection Block 2 (Block 2 (008000-00BFFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection Block 3 (Block 3 (00C000-00FFFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection Block 0 (Block 0 (000800-003FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection Block 1 (Block 1 (004000-007FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection Block 2 (Block 2 (008000-00BFFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection Block 3 (Block 3 (00C000-00FFFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection Block 0 (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection Block 1 (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection Block 2 (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection Block 3 (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)

// config statements should precede project file includes.
#include <xc.inc>
;
; Assembly macro to load pointer to a table
;
LoadTablePointer MACRO  pTable
    movlw   low(pTable)
    movwf   TBLPTRL,C
    movlw   high(pTable)
    movwf   TBLPTRH,C
    movlw   low highword(pTable)
    movwf   TBLPTRU,C
    ENDM
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
    global  HighIsrVec
;
HighIsrVec:
    return
;
;   Low priority interrupt vector and handler
    PSECT   lo_int_vec,global,reloc=2,class=CODE,delta=1
    global  LowIsrVec
;
LowIsrVec:
    return

;SPI DEFINES---------------
#define SPI_MOSI        LATB,3
#define SPI_MISO        PORTB,2
#define SPI_CLK         LATB,1
#define MAX7912_CSn     LATA,3
#define SPI_MOSI_DIR    TRISB,3
#define SPI_MISO_DIR    TRISB,2
#define SPI_CLK_DIR     TRISB,1
#define MAX7912_CSn_DIR TRISA,3
;SPI DEFINES END-----------
;
;Objects in common (Access) memory bank
    PSECT   udata_acs
SPI_TEMP:       DS  1
SPI_COUNT:      DS  1
CHAR_TO_SEND:   DS  1
;
; Initialize this PIC
;
    PSECT   code
    global  PIC_Init

PIC_Init:
    clrf    INTCON,c
    bsf     RCON,RCON_IPEN_POSITION,c   ; enable priority interrupt handling
    BANKSEL (OSCCON)
    movlw   0x70
    movwf   OSCCON,B      ; Set Fosc as 16MHz
    clrf    OSCTUNE,B
    bsf     OSCTUNE,OSCTUNE_PLLEN_POSITION,B    ; Enable PLL for 64MHz Fosc
    clrf    PIE1,c
    clrf    PIE2,c
    clrf    PIE3,c
    clrf    PIE4,c
    clrf    PIE5,c
    clrf    ANSELA,c
    clrf    ANSELB,c
    clrf    ANSELC,c
    clrf    ANSELD,c
    clrf    ANSELE,c
    setf    TRISA,c
    setf    TRISB,c
    setf    TRISC,c
    setf    TRISD,c
    setf    TRISE,c
    BANKSEL (SLRCON)
    clrf    SLRCON,B
    return
;
; Initialize the EUSART2
;
U2_BAUD SET 9600
U2BRG_VALUE SET (FCYC/U2_BAUD)
;
    global  EUSART2_Init
EUSART2_Init:
    bcf     PIE3,PIE3_RC2IE_POSITION,c
    bcf     PIE3,PIE3_TX2IE_POSITION,c

    movlw   0x08            ; ABDOVF no_overflow; SCKP Non-Inverted; BRG16 16bit_generator; WUE disabled; ABDEN disabled; 
    movwf   BAUDCON2,c

    movlw   0x90            ; SPEN enabled; RX9 8-bit; CREN enabled; ADDEN disabled; SREN disabled; 
    movwf   RCSTA2,c

    movlw   0x24            ; TX9 8-bit; TX9D 0; SENDB sync_break_complete; TXEN enabled; SYNC asynchronous; BRGH hi_speed; CSRC slave; 
    movwf   TXSTA2,c

    movlw   low(U2BRG_VALUE)
    movwf   SPBRG2,c
    movlw   high(U2BRG_VALUE)
    movwf   SPBRGH2,c

    bsf     LATD,LATD_LATD6_POSITION,c
    bcf     TRISD,TRISD_TRISD6_POSITION,c
    bsf     TRISD,TRISD_TRISD7_POSITION,c

    return

;
; Data in banked memory
;
    psect   MAX7219Data,global,class=RAM,space=1,delta=1,noexec
    global  MAX7219_Pixels

#define MAX_CHAR_WIDTH 6
#define MAX_CHARS 42
#define MAX_DISPLAY_WIDTH MAX_CHARS*MAX_CHAR_WIDTH

MAX7219_Pixels:
    ds      MAX_DISPLAY_WIDTH

    PSECT   MAX7219Code,global,reloc=2,class=CODE,delta=1

;MAX7219 SUBS----------------------------------------------------------------------------------
;
; Function: BB_SPI_TX
;
; Description:
;   Bit-Bang SPI transmit/receive function.
;
; Input:    WREG = 8-bits of data to send to SPI slave
;
; Output:   WREG = 8-bits of data received from SPI slave
;
; Uses:     SPI_TEMP, SPI_COUNT
;
BB_SPI_TX:
                MOVWF   SPI_TEMP,c
                RLCF    SPI_TEMP,W,c
                XORWF   SPI_TEMP,F,c
                CLRF    SPI_COUNT,c
                BSF     SPI_COUNT,3,c
                BCF     SPI_MOSI,c
BB_SPI_TX_LOOP:
                BCF     SPI_CLK,c
                BTFSC   STATUS,STATUS_C_POSITION,c
                BTG     SPI_MOSI,c  ; Update MOSI output bit
                RLCF    SPI_TEMP,F,c
                BCF     SPI_TEMP,0,c
                BSF     SPI_CLK,c
                BTFSC   SPI_MISO,c
                BSF     SPI_TEMP,0,c
                DECFSZ  SPI_COUNT,F,c
                BRA     BB_SPI_TX_LOOP
                MOVF    SPI_TEMP,W,c
                BCF     SPI_CLK,c
                BCF     SPI_MOSI,c
                RETURN

;
; Assert the SPI chip select for the MAX7219
;
MAX7219_SELECT:
                BCF     MAX7912_CSn,c
                RETURN
;
; Deassert the SPI chip select for the MAX7219
;
MAX7219_DESELECT:
                BSF     MAX7912_CSn,c
                NOP
                NOP
                NOP
                RETURN
;
; Function: MAX7219_SEND_ASCII
;
; Description:
;   Lookup ASCII character in 5x7 character generator table in code space
;   and send pattern to MAX7219.
;
; Input:    WREG = ASCII character.
;
; Output:   none
;
; Uses:
;
; Calls:    CG_SET_ADDRESS, CG_LOOK_UP, BB_SPI_TX
;
MAX7219_SEND_ASCII:
                CALL    CG_SET_ADDRESS

                CALL    MAX7219_SELECT
                MOVLW     2             ; Column 1 of 5x7 pattern
                CALL    BB_SPI_TX
                CALL    CG_LOOK_UP      ; Send data
                CALL    BB_SPI_TX
                CALL    MAX7219_DESELECT

                CALL    MAX7219_SELECT
                MOVLW     3             ; Column 2 of 5x7 pattern
                CALL    BB_SPI_TX
                CALL    CG_LOOK_UP      ; Send data
                CALL    BB_SPI_TX
                CALL    MAX7219_DESELECT

                CALL    MAX7219_SELECT
                MOVLW     4             ; Column 3 of 5x7 pattern
                CALL    BB_SPI_TX
                CALL    CG_LOOK_UP      ; Send data
                CALL    BB_SPI_TX
                CALL    MAX7219_DESELECT

                CALL    MAX7219_SELECT
                MOVLW     5             ; Column 4 of 5x7 pattern
                CALL    BB_SPI_TX
                CALL    CG_LOOK_UP      ; Send data
                CALL    BB_SPI_TX
                CALL    MAX7219_DESELECT

                CALL    MAX7219_SELECT
                MOVLW     6             ; Column 5 of 5x7 pattern
                CALL    BB_SPI_TX
                CALL    CG_LOOK_UP      ; Send data
                CALL    BB_SPI_TX
                CALL    MAX7219_DESELECT

                RETURN
;
; Function: CG_SET_ADDRESS
;
; Description:
;   Set address for character generator lookup.
;   Multiply the ASCII character code by 5 and
;   add the based address of the look up table.
;
; Input:    WREG = ASCII character.
;
; Output:   TBLPTR set to first byte of character data in code space
;
CG_SET_ADDRESS:
                MULLW   5
                MOVLW   LOW(ASCII_CHAR_GEN)
                ADDWF   PRODL,W,c
                MOVWF   TBLPTRL,c
                MOVLW   HIGH(ASCII_CHAR_GEN)
                ADDWFC  PRODH,W,c
                MOVWF   TBLPTRH,c
                MOVLW   low highword(ASCII_CHAR_GEN)
                CLRF    TBLPTRU,c
                ADDWFC  TBLPTRU,F,c
                RETURN
;
; Function: CG_LOOK_UP
;
; Input:        Code space address in CGT_ADDR
;
; Output:       WREG = 8-bits of data from Character Generator Table
;               TBLPTR incremented
;
CG_LOOK_UP:
                tblrd*+
                movf    TABLAT,W,C
                return
;
; Function: MAX7219INIT
;
; Description:
;   Initialize MAX7219 LED Display driver
;
; Input:    none
;
; Output:   none
;
; Calls:    BB_SPI_TX, MAX7219_DESELECT
;
MAX7219INIT:
    bsf     MAX7912_CSn,c
    bcf     MAX7912_CSn_DIR,c
    bcf     SPI_MOSI,c
    bcf     SPI_MOSI_DIR,c
    bcf     SPI_CLK,c
    bcf     SPI_CLK_DIR,c
    bsf     SPI_MISO_DIR,c

    lfsr    0,MAX7219_Pixels
MAX7219INIT_ClearPixels:
    clrf    POSTINC0,c
    movlw   high(MAX7219_Pixels+(MAX_DISPLAY_WIDTH))
    xorwf   FSR0H,W,c
    bnz     MAX7219INIT_ClearPixels
    movlw   low(MAX7219_Pixels+(MAX_DISPLAY_WIDTH))
    xorwf   FSR0L,W,c
    bnz     MAX7219INIT_ClearPixels

    CALL    MAX7219_SELECT
    MOVLW   0x0C            ;SHUTDOWN COMMAND
    CAll    BB_SPI_TX
    MOVLW   0x01            ;RELEASED
    CAll    BB_SPI_TX
    CALL    MAX7219_DESELECT

    CALL    MAX7219_SELECT
    MOVLW   0x09            ;DECODE MODE COMMAND
    CAll    BB_SPI_TX
    MOVLW     0             ;DISABLED FOR ALL DIGITS
    CAll    BB_SPI_TX
    CALL    MAX7219_DESELECT

    CALL    MAX7219_SELECT
    MOVLW   0x0A            ;INTENSITY COMMAND
    CAll    BB_SPI_TX
    MOVLW   0x01            ;INTENSITY VALUE
    CAll    BB_SPI_TX
    CALL    MAX7219_DESELECT

    CALL    MAX7219_SELECT
    MOVLW   0x0B            ;SCAN LIMIT COMMAND
    CAll    BB_SPI_TX
    MOVLW   0x07            ;ALL DIGITS
    CAll    BB_SPI_TX
    CALL    MAX7219_DESELECT

    CALL    MAX7219_SELECT
    MOVLW   0x0F            ;TEST MODE COMMAND
    CAll    BB_SPI_TX
    MOVLW     0             ;NORMAL
    CAll    BB_SPI_TX
    CALL    MAX7219_DESELECT

    MOVLW     1             ; 
    CALL    ZERO_COLUMN
    MOVLW     2             ; 
    CALL    ZERO_COLUMN
    MOVLW     3             ; 
    CALL    ZERO_COLUMN
    MOVLW     4             ; 
    CALL    ZERO_COLUMN
    MOVLW     5             ; 
    CALL    ZERO_COLUMN
    MOVLW     6             ; 
    CALL    ZERO_COLUMN
    MOVLW     7             ; 
    CALL    ZERO_COLUMN
    MOVLW     8             ; 
ZERO_COLUMN:
    CALL    MAX7219_SELECT
    CALL    BB_SPI_TX
    MOVLW   0
    CALL    BB_SPI_TX
    CALL    MAX7219_DESELECT

    RETURN

;MAX7219 SUBS ENDS-----------------------------------------------------------------------------
;
; Data in banked memory
;
    psect	DigitsData,global,class=RAM,space=1,delta=1,noexec
    global  Digits
#define NUMBER_OF_DIGITS 8
Digits:     DS      NUMBER_OF_DIGITS
;
; Digits Functions to clear, increment, decrement, and check for zero
;
    PSECT   DigitsCode,global,reloc=2,class=CODE,delta=1
;
; Clear digit array to zero
;
Digits_clear:
    lfsr    0,Digits
    movlw   NUMBER_OF_DIGITS
Digits_clear_loop:
    clrf    POSTINC0,c
    decfsz  WREG,c
    bra     Digits_clear_loop
    return
;
; Test if digit array is zero
;
; Returns: WREG = 0, ZERO status flag set when array is zero
;          WREG = 1, ZERO status flag clear when array is not zero
;
Digits_Test_Zero:
    lfsr    0,Digits+NUMBER_OF_DIGITS-1
Digits_Test_Zero_Loop:
    movlw   1
    movf    POSTDEC0,F,c
    bnz     Digits_Test_Zero_Exit
    movlw   HIGH(Digits-1)
    xorwf   FSR0H,W,c
    bnz     Digits_Test_Zero_Loop
    movlw   LOW(Digits-1)
    xorwf   FSR0L,W,c
    bnz     Digits_Test_Zero_Loop
Digits_Test_Zero_Exit:
    return
;
; Increment Ditits array as a BCD number
;
Digits_BCD_Inc:
    lfsr    0,Digits
Digits_BCD_Inc_Loop:
    movf    INDF0,w,c
    andlw   0x0F
    addlw   0x91
    daw
    andlw   0x0F
    movwf   POSTINC0,c
    btfss   STATUS,STATUS_C_POSITION,c
    bra     Digits_BCD_Inc_Exit
    movlw   HIGH(Digits+NUMBER_OF_DIGITS)
    xorwf   FSR0H,W,c
    bnz     Digits_BCD_Inc_Loop
    movlw   LOW(Digits+NUMBER_OF_DIGITS)
    xorwf   FSR0L,W,c
    bnz     Digits_BCD_Inc_Loop
Digits_BCD_Inc_Exit:
    return
;
; Decrement Ditits array as a BCD number
;
Digits_BCD_Dec:
    lfsr    0,Digits
Digits_BCD_Dec_Loop:
    movf    INDF0,w,c
    andlw   0x0F
    addlw   0x99
    daw
    andlw   0x0F
    movwf   POSTINC0,c
    btfsc   STATUS,STATUS_C_POSITION,c
    bra     Digits_BCD_Dec_Exit
    movlw   HIGH(Digits+NUMBER_OF_DIGITS)
    xorwf   FSR0H,W,c
    bnz     Digits_BCD_Dec_Loop
    movlw   LOW(Digits+NUMBER_OF_DIGITS)
    xorwf   FSR0L,W,c
    bnz     Digits_BCD_Dec_Loop
Digits_BCD_Dec_Exit:
    return
;
; Send Ditits array to the UART as ASCII digits
;
Digits_Print:
    lfsr    0,Digits+NUMBER_OF_DIGITS-1
Digits_Print_Loop:
    movf    POSTDEC0,W,c
    andlw   0x0F
    iorlw   '0'
    call    EUSART2_Write

    movlw   HIGH(Digits-1)
    xorwf   FSR0H,W,c
    bnz     Digits_Print_Loop
    movlw   LOW(Digits-1)
    xorwf   FSR0L,W,c
    bnz     Digits_Print_Loop
Digits_Print_Exit:
    movlw   13
    call    EUSART2_Write
    movlw   10
    call    EUSART2_Write
    return
;
; Write a byte to EUSART2
;
    PSECT   code
EUSART2_Write:

EUSART2_WaitForTx:
    btfss   TXSTA2,TXSTA2_TRMT_POSITION,c
    bra     EUSART2_WaitForTx
    movwf   TXREG2,c
    return
;
; Send an ASCIIZ string from ROM to EUSART2
;
EUSART2_PutsRom:
    tblrd*+
    movf    TABLAT,W,c
    tblrd*+
    btfsc   STATUS,STATUS_Z_POSITION,C
    return
    call    EUSART2_Write
    bra     EUSART2_PutsRom
;
; Main Application
;
    global  main
main:
    call    PIC_Init
    call    EUSART2_Init

;
; Wait for about 100ms when the system oscillator is 64MHz
; (the wait will be longer for a lower frequency clock)
;
    clrf    PRODL,c
    clrf    PRODH,c
    movlw   8
    decfsz  PRODL,c
    bra     $-2
    decfsz  PRODH,c
    bra     $-6
    decfsz  WREG,c
    bra     $-8

    LoadTablePointer SignOn
    call    EUSART2_PutsRom

    call    Digits_clear
    movlw   0
    lfsr    0,Digits
    movwf   POSTINC0,c
    movwf   POSTINC0,c
    movlw   1
    movwf   POSTINC0,c
    call    Digits_Print

    call    MAX7219INIT
;
; Application process loop
;
AppLoop:
    movlw   ' '
    movwf   CHAR_TO_SEND,c

CharLoop:

    call    Digits_Test_Zero
    bz      Skip_Digits_Print
    call    Digits_BCD_Dec
    call    Digits_Print
Skip_Digits_Print:

    movf    CHAR_TO_SEND,W,c
    call    MAX7219_SEND_ASCII
    incf    CHAR_TO_SEND,F,c
;
; Wait for about 500 milliseconds
;
    clrf    PRODL,c
    clrf    PRODH,c
    movlw   80
    decfsz  PRODL,c
    bra     $-2
    decfsz  PRODH,c
    bra     $-6
    decfsz  WREG,c
    bra     $-8
;
; Check for end of CG array
    movlw   132
    xorwf   CHAR_TO_SEND,W,c
    bnz     CharLoop    ; Branch if not at end

    bra     AppLoop     ; Branch to start at begining

;
; 5x7 pixel ASCII character generator data
;
    psect	ascii_cg,reloc=2,class=CONST,delta=1,noexec
ASCII_CHAR_GEN:
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   0
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   1
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   2
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   3
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   4
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   5
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   6
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   7
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   8
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII   9
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  10
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  11
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  12
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  13
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  14
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  15
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  16
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  17
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  18
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  19
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  20
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  21
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  22
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  23
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  24
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  25
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  26
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  27
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  28
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  29
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  30
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;       ASCII  31
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;SPACE  ASCII  32
    db 0b00000000,0b00000000,0b11111010,0b00000000,0b00000000   ;!      ASCII  33
    db 0b00000000,0b11100000,0b00000000,0b11100000,0b00000000   ;"      ASCII  34
    db 0b00101000,0b11111110,0b00101000,0b11111110,0b00101000   ;#      ASCII  35
    db 0b01001000,0b01010100,0b11111110,0b01010100,0b00100100   ;$      ASCII  36
    db 0b01000110,0b00100110,0b00010000,0b11001000,0b11000100   ;%      ASCII  37
    db 0b00001010,0b01000100,0b10101010,0b10010010,0b01101100   ;&      ASCII  38
    db 0b00000000,0b00000000,0b11000000,0b00000000,0b00000000   ;'      ASCII  39
    db 0b00000000,0b10000010,0b01000100,0b00111000,0b00000000   ;(      ASCII  40
    db 0b00000000,0b00111000,0b01000100,0b10000010,0b00000000   ;)      ASCII  41
    db 0b01000100,0b00101000,0b11111110,0b00101000,0b01000100   ;*      ASCII  42
    db 0b00010000,0b00010000,0b01111100,0b00010000,0b00010000   ;+      ASCII  43
    db 0b00000000,0b00000000,0b00001100,0b00001010,0b00000000   ;,      ASCII  44
    db 0b00010000,0b00010000,0b00010000,0b00010000,0b00010000   ;-      ASCII  45
    db 0b00000000,0b00000000,0b00000110,0b00000110,0b00000000   ;.      ASCII  46
    db 0b01000000,0b00100000,0b00010000,0b00001000,0b00000100   ;/      ASCII  47
    db 0b01111100,0b10100010,0b10010010,0b10001010,0b01111100   ;0      ASCII  48
    db 0b00000010,0b00000010,0b11111110,0b01000010,0b00100010   ;1      ASCII  49
    db 0b01100010,0b10010010,0b10001010,0b10000110,0b01000010   ;2      ASCII  50
    db 0b01101100,0b10010010,0b10010010,0b10000010,0b01000100   ;3      ASCII  51
    db 0b00001000,0b11111110,0b01001000,0b00101000,0b00011000   ;4      ASCII  52
    db 0b10001100,0b10010010,0b10010010,0b10010010,0b11110100   ;5      ASCII  53
    db 0b00001100,0b10010010,0b10010010,0b01010010,0b00111100   ;6      ASCII  54
    db 0b11000000,0b10100000,0b10010000,0b10001110,0b10000000   ;7      ASCII  55
    db 0b01101100,0b10010010,0b10010010,0b10010010,0b01101100   ;8      ASCII  56
    db 0b01111000,0b10010100,0b10010010,0b10010010,0b01100000   ;9      ASCII  57
    db 0b00000000,0b00000000,0b01101100,0b01101100,0b00000000   ;:      ASCII  58
    db 0b00000000,0b00000000,0b01101100,0b01101010,0b00000000   ;;      ASCII  59
    db 0b00000000,0b10000010,0b01000100,0b00101000,0b00010000   ;<      ASCII  60
    db 0b00101000,0b00101000,0b00101000,0b00101000,0b00101000   ;=      ASCII  61
    db 0b00010000,0b00101000,0b01000100,0b10000010,0b00000000   ;>      ASCII  62
    db 0b01100000,0b10010000,0b10001010,0b10000000,0b01000000   ;?      ASCII  63
    db 0b01111100,0b10000010,0b10011110,0b10010010,0b01001100   ;@      ASCII  64
    db 0b01111110,0b10010000,0b10010000,0b10010000,0b01111110   ;A      ASCII  65
    db 0b01101100,0b10010010,0b10010010,0b10010010,0b11111110   ;B      ASCII  66
    db 0b01000100,0b10000010,0b10000010,0b10000010,0b01111100   ;C      ASCII  67
    db 0b01111100,0b10000010,0b10000010,0b10000010,0b11111110   ;D      ASCII  68
    db 0b10000010,0b10010010,0b10010010,0b10010010,0b11111110   ;E      ASCII  69
    db 0b10000000,0b10010000,0b10010000,0b10010000,0b11111110   ;F      ASCII  70
    db 0b01001110,0b10001010,0b10000010,0b10000010,0b01111100   ;G      ASCII  71
    db 0b11111110,0b00010000,0b00010000,0b00010000,0b11111110   ;H      ASCII  72
    db 0b10000010,0b10000010,0b11111110,0b10000010,0b10000010   ;I      ASCII  73
    db 0b11111100,0b00000010,0b00000010,0b00000010,0b00000100   ;J      ASCII  74
    db 0b10000010,0b01000100,0b00101000,0b00010000,0b11111110   ;K      ASCII  75
    db 0b00000010,0b00000010,0b00000010,0b00000010,0b11111110   ;L      ASCII  76
    db 0b11111110,0b01000000,0b00110000,0b01000000,0b11111110   ;M      ASCII  77
    db 0b11111110,0b00001000,0b00010000,0b00100000,0b11111110   ;N      ASCII  78
    db 0b01111100,0b10000010,0b10000010,0b10000010,0b01111100   ;O      ASCII  79
    db 0b01100000,0b10010000,0b10010000,0b10010000,0b11111110   ;P      ASCII  80
    db 0b01111010,0b10000100,0b10001010,0b10000010,0b01111100   ;Q      ASCII  81
    db 0b01100010,0b10010100,0b10011000,0b10010000,0b11111110   ;R      ASCII  82
    db 0b01001100,0b10010010,0b10010010,0b10010010,0b01100100   ;S      ASCII  83
    db 0b10000000,0b10000000,0b11111110,0b10000000,0b10000000   ;T      ASCII  84
    db 0b11111100,0b00000010,0b00000010,0b00000010,0b11111100   ;U      ASCII  85
    db 0b11100000,0b00011000,0b00000110,0b00011000,0b11100000   ;V      ASCII  86
    db 0b11111100,0b00000010,0b00011100,0b00000010,0b11111100   ;W      ASCII  87
    db 0b11000110,0b00101000,0b00010000,0b00101000,0b11000110   ;X      ASCII  88
    db 0b11000000,0b00100000,0b00011110,0b00100000,0b11000000   ;Y      ASCII  89
    db 0b11000010,0b10100010,0b10010010,0b10001010,0b10000110   ;Z      ASCII  90
    db 0b00000000,0b00000000,0b10000010,0b10000010,0b11111110   ;[      ASCII  91
    db 0b00000100,0b00001000,0b00010000,0b00100000,0b01000000   ;\      ASCII  92
    db 0b00000000,0b00000000,0b11111110,0b10000010,0b10000010   ;]      ASCII  93
    db 0b00100000,0b01000000,0b10000000,0b01000000,0b00100000   ;^      ASCII  94
    db 0b00000010,0b00000010,0b00000010,0b00000010,0b00000010   ;_      ASCII  95
    db 0b00000000,0b00100000,0b01000000,0b10000000,0b00000000   ;`      ASCII  96
    db 0b00011110,0b00101010,0b00101010,0b00101010,0b00000100   ;a      ASCII  97
    db 0b00011100,0b00100010,0b00100010,0b00010010,0b11111110   ;b      ASCII  98
    db 0b00000100,0b00100010,0b00100010,0b00100010,0b00011100   ;c      ASCII  99
    db 0b11111110,0b00010010,0b00100010,0b00100010,0b00011100   ;d      ASCII 100
    db 0b00011000,0b00101010,0b00101010,0b00101010,0b00011100   ;e      ASCII 101
    db 0b01000000,0b10000000,0b10010000,0b01111110,0b00010000   ;f      ASCII 102
    db 0b01111100,0b01001010,0b01001010,0b01001010,0b00110000   ;g      ASCII 103
    db 0b00011110,0b00100000,0b00100000,0b00010000,0b11111110   ;h      ASCII 104
    db 0b00000000,0b00000010,0b10111110,0b00100010,0b00000000   ;i      ASCII 105
    db 0b00000000,0b10111100,0b00100010,0b00000010,0b00000100   ;j      ASCII 106
    db 0b00000000,0b00100010,0b00010100,0b00001000,0b11111110   ;k      ASCII 107
    db 0b00000000,0b00000010,0b11111110,0b10000010,0b00000000   ;l      ASCII 108
    db 0b00011110,0b00100000,0b00011000,0b00100000,0b00111110   ;m      ASCII 109
    db 0b00011110,0b00100000,0b00100000,0b00010000,0b00111110   ;n      ASCII 110
    db 0b00011100,0b00100010,0b00100010,0b00100010,0b00011100   ;o      ASCII 111
    db 0b00010000,0b00101000,0b00101000,0b00101000,0b00111110   ;p      ASCII 112
    db 0b00111110,0b00011000,0b00101000,0b00101000,0b00010000   ;q      ASCII 113
    db 0b00010000,0b00100000,0b00100000,0b00010000,0b00111110   ;r      ASCII 114
    db 0b00000100,0b00101010,0b00101010,0b00101010,0b00010010   ;s      ASCII 115
    db 0b00000100,0b00000010,0b00100010,0b11111100,0b00100000   ;t      ASCII 116
    db 0b00111110,0b00000100,0b00000010,0b00000010,0b00111100   ;u      ASCII 117
    db 0b00111000,0b00000100,0b00000010,0b00000100,0b00111000   ;v      ASCII 118
    db 0b00111100,0b00000010,0b00001100,0b00000010,0b00111100   ;w      ASCII 119
    db 0b00100010,0b00010100,0b00001000,0b00010100,0b00100010   ;x      ASCII 120
    db 0b00111100,0b00001010,0b00001010,0b00001010,0b00110000   ;y      ASCII 121
    db 0b00100010,0b00110010,0b00101010,0b00100110,0b00100010   ;z      ASCII 122
    db 0b10000010,0b01101100,0b00010000,0b00000000,0b00000000   ;{      ASCII 123
    db 0b00000000,0b00000000,0b11111110,0b00000000,0b00000000   ;|      ASCII 124
    db 0b00000000,0b00010000,0b01101100,0b10000010,0b00000000   ;}      ASCII 125
    db 0b11001100,0b11000010,0b00010010,0b11000010,0b11001100   ;SMILE  ASCII 126
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;BLANK  ASCII 127
    db 0b11000100,0b11000100,0b00010100,0b11000100,0b11000100   ;SOSO   ASCII 128
    db 0b11111110,0b11111110,0b11111110,0b11111110,0b11111110   ;FILL   ASCII 129
    db 0b11111110,0b10000010,0b10000010,0b10000010,0b11111110   ;BOX    ASCII 130
    db 0b11000110,0b11001000,0b00011000,0b11001000,0b11000110   ;SAD    ASCII 131
    db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000   ;BLANK  ASCII 132

;
; Message sent after Power-On-Reset
;
    psect	sign_on,reloc=2,class=CONST,delta=1,noexec
SignOn:
    dw  13,10,"DM164136 with 18F46K22 start ",13,10
    dw  "Built on "
    dw  __DATE__
    dw  " at "
    dw  __TIME__
    dw  13,10,0

; Tell linker the address of the Power-On-Reset
    end     PORreset