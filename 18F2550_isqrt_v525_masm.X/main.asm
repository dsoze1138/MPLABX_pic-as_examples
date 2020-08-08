; File:     main.asm
; Target:   PIC18F2550
; Author:   dan1138
; Date:     2020-06-17
; Compiler: MPASM v5.84
; IDE:      MPLABX v5.25
;
; Description:
;
;   Find integer square root of a 32-bit value
;
;
;
;
;                             PIC18F2550
;                    +------------:_:------------+
;          VPP ->  1 : RE3/MCLRn/VPP     PGD/RB7 : 28 <> PGD
;              ->  2 : RA0/AN0           PGC/RB6 : 27 <> PGC
;              <>  3 : RA1/AN1           PGM/RB5 : 26 <>
;              <>  4 : RA2/AN2          AN11/RB4 : 25 <>
;              <>  5 : RA3/AN3           AN9/RB3 : 24 <>
;              <>  6 : RA4/C1OUT         AN8/RB2 : 23 <>
;              <>  7 : RA5/AN4          AN10/RB1 : 22 <>
;          GND <>  8 : VSS              AN12/RB0 : 21 <>
;        20MHz <>  9 : RA7/OSC1              VDD : 20 <- 5v0
;        20MHz <> 10 : RA6/OSC2              VSS : 19 <- GND
;    32.768KHz <> 11 : RC0/SOSCO       RX/DT/RC7 : 18 <>
;    32.768KHz <> 12 : RC1/SOSCI       TX/CK/RC6 : 17 <>
;              <> 13 : RC2/CCP1           D+/RC5 : 16 <-
;              <> 14 : VUSB               D-/RC4 : 15 <-
;                    +---------------------------:
;                               DIP-28
;  Note:
;   RC4,RC5 can only be used as digital inputs when the USB transceiver is not used.
;
;
;
;
;
;
    list        p=18F2550
    list        c=132
    list        r=dec
;
 config PLLDIV = 5          ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
 config CPUDIV = OSC1_PLL2  ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
 config USBDIV = 2          ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes from the 96 MHz PLL divided by 2)
 config FOSC = HSPLL_HS     ; Oscillator Selection bits (HS oscillator, PLL enabled (HSPLL))
 config FCMEN = OFF         ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
 config IESO = OFF          ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)
 config PWRT = OFF          ; Power-up Timer Enable bit (PWRT disabled)
 config BOR = OFF           ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
 config BORV = 3            ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
 config VREGEN = OFF        ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)
 config WDT = OFF           ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
 config WDTPS = 32768       ; Watchdog Timer Postscale Select bits (1:32768)
 config CCP2MX = ON         ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
 config PBADEN = OFF        ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
 config LPT1OSC = OFF       ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
 config MCLRE = ON          ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
 config STVREN = ON         ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
 config LVP = OFF           ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
 config XINST = OFF         ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))
 config CP0 = OFF           ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
 config CP1 = OFF           ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
 config CP2 = OFF           ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
 config CP3 = OFF           ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)
 config CPB = OFF           ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
 config CPD = OFF           ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)
 config WRT0 = OFF          ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
 config WRT1 = OFF          ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
 config WRT2 = OFF          ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
 config WRT3 = OFF          ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)
 config WRTC = OFF          ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
 config WRTB = OFF          ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
 config WRTD = OFF          ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)
 config EBTR0 = OFF         ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
 config EBTR1 = OFF         ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
 config EBTR2 = OFF         ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
 config EBTR3 = OFF         ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)
 config EBTRB = OFF         ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)
;
;   Specify the System clock frequency in Hz
;
#define FOSC 48000000
;
;   Specify the Peripheral clock frequency in Hz
;
#define FCYC (FOSC/4)
;
; Include device specific definitions for Special Function Registers
;
#include <p18F2550.inc>
;
;
;
;
;
resetVec    code    0x0000          ; processor reset vector
;
resetVec:
    clrf    TBLPTRU, ACCESS
    goto    Start
;
hi_int_vec  code    0x0008
;
    goto    HighIsrHandler
;
LowIsr_data udata_acs
;
    global  WREG_save,STATUS_save,BSR_save
;
WREG_save:      res 1
STATUS_save:    res 1
BSR_save:       res 1
;
lo_int_vec  code    0x0018
;
LowIsrVec:
    movff   WREG,WREG_save
    movff   STATUS,STATUS_save
    movff   BSR,BSR_save
;
LowIsrHandler:
;
    movff   BSR_save,BSR
    movff   STATUS_save,STATUS
    movff   WREG_save,WREG
    retfie
;
HighIsr_code code
;
HighIsrHandler:
    return  FAST
;
start_code  code
;
Start:
    bcf     INTCON,GIEH         ; Disable all interrupts
    bcf     INTCON,GIEL
    bsf     RCON,IPEN           ; Enable interrupt priority
;
    movlw   0x00                ; Set primary oscillator as system clock source
    movwf   OSCCON,ACCESS       ;
;
    movlw   0x0F                ; Configure A/D
    movwf   ADCON1              ; for digital inputs
;
    goto    main
;
; Implement integer square root
;
;       unsigned long   in;
;       unsigned long  out;
;       unsigned long  bit;
;       unsigned long temp;
;
;       unsigned long isqrt(void)
;       {
;           out = 0;
;           bit = 1L << 30;
;
;           // "bit" starts at the highest power of four <= the argument.
;           while (bit > in)
;               bit >>= 2;
;
;           while (bit != 0)
;           {
;               temp = out + bit;
;               out >>= 1;
;               if (in >= temp)
;               {
;                   in -= temp;
;                   out += bit;
;               }
;               bit >>= 2;
;           }
;           return out;
;       }
;
;
isqrt_data  udata
    global      isqrt_in,isqrt_out,isqrt_bit,isqrt_temp
;
isqrt_in:       res 4
isqrt_out:      res 4
isqrt_bit:      res 4
isqrt_temp:     res 4
;
isqrt_code  code
;
;
; logical shift right one bit [fsr1]
;
isqrt_lsr:
    bcf     STATUS,C
    rrcf    POSTDEC1,F
    rrcf    POSTDEC1,F
    rrcf    POSTDEC1,F
    rrcf    INDF1,f
    return
;
; Compare [FSR2] - [FSR1]
; Carry set when [FSR2] >= [FSR1]
; Carry clear when [FSR2] < [FSR1]
;
isqrt_cmp:
    movf    POSTINC1,w
    subwf   POSTINC2,w
    movf    POSTINC1,w
    subwfb  POSTINC2,w
    movf    POSTINC1,w
    subwfb  POSTINC2,w
    movf    INDF1,w
    subwfb  INDF2,w
    return
;
isqrt:
    clrf    isqrt_out
    clrf    isqrt_out+1
    clrf    isqrt_out+2
    clrf    isqrt_out+3
;
    clrf    isqrt_bit
    clrf    isqrt_bit+1
    clrf    isqrt_bit+2
    movlw   B'01000000'
    movwf   isqrt_bit+3
;
FindMSB:
    lfsr    FSR1,isqrt_bit
    lfsr    FSR2,isqrt_in
    rcall   isqrt_cmp       ; STATUS set to (isqrt_in - isqrt_bit)
    bc      FindNextDigit   ; branch when isqrt_in >= isqrt_bit
;
; Shift the digits right two bits
;
    lfsr    FSR1,isqrt_bit+3
    rcall   isqrt_lsr
    lfsr    FSR1,isqrt_bit+3
    rcall   isqrt_lsr
    bra     FindMSB
;
FindNextDigit:
    movf    isqrt_bit,W
    iorwf   isqrt_bit+1,W
    iorwf   isqrt_bit+2,W
    iorwf   isqrt_bit+3,W
    bz      isqrt_done
;
    movf    isqrt_bit,W
    addwf   isqrt_out,W
    movwf   isqrt_temp
    movf    isqrt_bit+1,W
    addwfc  isqrt_out+1,W
    movwf   isqrt_temp+1
    movf    isqrt_bit+2,W
    addwfc  isqrt_out+2,W
    movwf   isqrt_temp+2
    movf    isqrt_bit+3,W
    addwfc  isqrt_out+3,W
    movwf   isqrt_temp+3
;
    lfsr    FSR1,isqrt_out+3
    rcall   isqrt_lsr
;
    lfsr    FSR1,isqrt_temp
    lfsr    FSR2,isqrt_in
    rcall   isqrt_cmp       ; STATUS set to (isqrt_in - isqrt_temp)
    bnc     NoDigitUpdate   ; Branch when isqrt_in >= isqrt_temp
;
    movf    isqrt_temp,W
    subwf   isqrt_in
    movf    isqrt_temp+1,W
    subwfb  isqrt_in+1
    movf    isqrt_temp+2,W
    subwfb  isqrt_in+2
    movf    isqrt_temp+3,W
    subwfb  isqrt_in+3
;
    movf    isqrt_bit,W
    addwf   isqrt_out
    movf    isqrt_bit+1,W
    addwfc  isqrt_out+1
    movf    isqrt_bit+2,W
    addwfc  isqrt_out+2
    movf    isqrt_bit+3,W
    addwfc  isqrt_out+3
;
NoDigitUpdate:
;
    lfsr    FSR1,isqrt_bit+3
    rcall   isqrt_lsr
    lfsr    FSR1,isqrt_bit+3
    rcall   isqrt_lsr
    bra     FindNextDigit
;
isqrt_done:
    return
;
main_code   code
;
;
; Constants
#define TEST_VALUE1 2*2
#define TEST_VALUE2 3*3
#define TEST_VALUE3 4*4
#define TEST_VALUE4 5*5
#define TEST_VALUE5 6*6
#define TEST_VALUE6 10*10
#define TEST_VALUE7 9999*9999
#define TEST_VALUE8 12345*12345
#define TEST_VALUE9 65535*65535
;
; Macro to load a 32-bit constant
;
load32  macro DWORD, CONST
;
    banksel DWORD
    movlw   0xFF & (CONST)
    movwf   DWORD
    movlw   0xFF & (CONST >> 8)
    movwf   DWORD+1
    movlw   0xFF & (CONST >> 16)
    movwf   DWORD+2
    movlw   0xFF & (CONST >> 24)
    movwf   DWORD+3
;
        endm
;
main:
;
AppLoop:
    load32  isqrt_in,TEST_VALUE1
    call    isqrt
    load32  isqrt_in,TEST_VALUE2
    call    isqrt
    load32  isqrt_in,TEST_VALUE3
    call    isqrt
    load32  isqrt_in,TEST_VALUE4
    call    isqrt
    load32  isqrt_in,TEST_VALUE5
    call    isqrt
    load32  isqrt_in,TEST_VALUE6
    call    isqrt
    load32  isqrt_in,TEST_VALUE7
    call    isqrt
    load32  isqrt_in,TEST_VALUE8
    call    isqrt
    load32  isqrt_in,TEST_VALUE9
    call    isqrt
    goto    AppLoop
;
    END