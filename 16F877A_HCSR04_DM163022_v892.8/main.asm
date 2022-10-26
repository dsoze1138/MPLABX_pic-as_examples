;
; File:     main.asm
; Target:   PIC16F877A
; Author:   dan1138
; Date:     2022-10-20
; Compiler: MPASMWIN v5.51
; IDE:      MPLAB v8.98
;
; Description:
;
;   Example of using HC-SR04 and LCD with the DM163022 (PICDEM2+) board.
;
; 
; 
;
;                              PIC16F877A
;                      +----------:_:----------+
;            VPP ->  1 : MCLR/VPP      PGD/RB7 : 40 <> PGD
;            POT <>  2 : RA0/AN0       PGC/RB6 : 39 <> PGC
;                <>  3 : RA1/AN1           RB5 : 38 <>
;                <>  4 : RA2/AN2           RB4 : 37 <>
;                <>  5 : RA3/AN3       PGM/RB3 : 36 <> LED_D5
;             S2 <>  6 : RA4               RB2 : 35 <> LED_D4
;             S3 <>  7 : RA5/AN4           RB1 : 34 <> LED_D3
;                <>  8 : RE0/AN5       INT/RB0 : 33 <> LED_D2
;                <>  9 : RE1/AN6           VDD : 32 <- 5v0
;                <> 10 : RE2/AM7           VSS : 31 <- GND
;            5v0 -> 11 : VDD               RD7 : 30 -> LCD_PWR
;            GND -> 12 : VSS               RD6 : 29 -> LCD_E
;           4MHZ <> 13 : RA7/OSC1          RD5 : 28 -> LCD_RW
;           4MHZ <> 14 : RA6/OSC2          RD4 : 27 -> LCD_RS
;                <> 15 : RC0/SOSCO   RX/DT/RC7 : 26 <> 
;                <> 16 : RC1/SOSCI   TX/CK/RC6 : 25 <> 
; (HC-SR04) ECHO -> 17 : RC2/CCP1          RC5 : 24 -> TRIGGER (NC-SR04)
;                <> 18 : RC3/SCL       SDA/RC4 : 23 <> 
;         LCD_D4 <> 19 : RD0               RD3 : 22 <> LCD_D7
;         LCD_D5 <> 20 : RD1               RD2 : 21 <> LCD_D6
;                      +-----------------------:
;                               DIP-40
;
    ERRORLEVEL  -302        ; Supress Register in operand not in bank 0 warning
    PROCESSOR   16F877A
    LIST        c=132,n=0
    RADIX       DEC
;
#include <p16f877a.inc>

; PIC16F877A Configuration Bit Settings

; 'C' source line config statements

; CONFIG
 __CONFIG _FOSC_HS & _WDTE_OFF &_PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF







;
; 
;



















;
; Define macros to help with
; bank selection
;
#define BANK0  (0x000)
#define BANK1  (0x080)
#define BANK2  (0x100)
#define BANK3  (0x180)
;
; Speed of sound in air, units micrometers per microsecond
#define SPEED_OF_SOUND (343)
;
; Application data space
MainData    UDATA   0x20

    GLOBAL IdleTick,mBits,BCD_out,A_reg,B_reg,D_reg
IdleTick:   res 1            ; used in idle loop to count time for LED flashing
mBits:      res 1            ; used by Math functions, used for bit counts
BCD_out:    res 3            ; used for 5 byte BCD outpt, overlaps with register A
A_reg:      res 2            ; used by Math functions, 16-bit input  register A
B_reg:                       ; used by Math functions, 16-bit input  register B, not register shares 16-bits with the output register
D_reg:      res 4            ; used by Math functions, 32-bit output register D
;
;
; Power-On-Reset entry point
;
Por_Vec     CODE    0x0000
    global  resetVec
resetVec:
    pagesel(Start)
    goto    Start

;
;   Data in common space use by LCD implementation
LCD_Data    UDATA_SHR
;
    GLOBAL  LCD_Temp
;
LCD_Temp:       res  1

;
;   Data in common space use by interrupt handler to save context
Isr_Data    UDATA_SHR
;
    GLOBAL  WREG_save,STATUS_save,PCLATH_save,TimeOfFlight
;
WREG_save:      res  1
STATUS_save:    res  1
PCLATH_save:    res  1
TimeOfFlight:   res  2
;
;   Interrupt vector and handler
Isr_Vec     CODE    0x0004
    GLOBAL  IsrVec
;
IsrVec:
    movwf   WREG_save
    swapf   STATUS,W
    movwf   STATUS_save
    movf    PCLATH,W
    movwf   PCLATH_save
    pagesel(IsrVec)
;
IsrHandler:
    banksel(BANK0)
;
; CCP1 capture interrupt handler
;
    btfss   PIR1,CCP1IF
    goto    Isr_CCP1_done
    bcf     PIR1,CCP1IF
    btfsc   CCP1CON,0                   ; skp if leading edge detected
    goto    Isr_CCP1_T0
    movf    TimeOfFlight,W              ; compute TIMER1 counts
    subwf   CCPR1L,W                    ; from leading edge
    movwf   TimeOfFlight                ; to trailing edge.
    movf    TimeOfFlight+1,W
    skpc
    incf    TimeOfFlight+1,W
    subwf   CCPR1H,W
    movwf   TimeOfFlight+1
    bcf     T1CON,TMR1ON                ; stop TIMER1 when trailing edge of range pulse is captured
    goto    Isr_CCP1_done
Isr_CCP1_T0:
    movf    CCPR1L,W                    ; save start time of leading edge
    movwf   TimeOfFlight
    movf    CCPR1H,W
    movwf   TimeOfFlight+1
    bcf     CCP1CON,0                   ; setup to apture trailing edge
Isr_CCP1_done:
;
; TIMER1 interrupt handler
;
    btfss   PIR1,TMR1IF
    goto    Isr_TMR1_done
    bcf     PIR1,TMR1IF
    clrf    TMR1H
    clrf    TMR1L
    movlw   0x05                        ; setup CCP1 to capture leading edge of range pulse
    movwf   CCP1CON
    bcf     PIR1,CCP1IF
    bsf     PORTC,5                     ; Set HC-SR04 trigger high
    nop                                 ; delay +1  microsecond
    nop                                 ; delay +2  microsecond
    nop                                 ; delay +3  microsecond
    nop                                 ; delay +4  microsecond
    nop                                 ; delay +5  microsecond
    nop                                 ; delay +6  microsecond
    nop                                 ; delay +7  microsecond
    nop                                 ; delay +8  microsecond
    nop                                 ; delay +9  microsecond
    bcf     PORTC,5                     ; Set HC-SR04 trigger low
Isr_TMR1_done:
;
IsrExit:
    movf    PCLATH_save,W
    movwf   PCLATH
    swapf   STATUS_save,W
    movwf   STATUS
    swapf   WREG_save,F
    swapf   WREG_save,W
    retfie                              ; Return from interrupt
;
;   Section used for main code
MainCode    CODE
;
; Initialize the PIC hardware
;
Start:
    clrf    INTCON
    banksel(PIE1)
    clrf    PIE1
    clrf    PIE2

    banksel(PORTB)
    clrf    PORTB
    clrf    PORTC
    banksel(TRISB)
    clrf    TRISB                       ; PORT B OUTPUTS
    bcf     TRISC,TRISC5
;
; Make all GPIO pins digital I/O
;
    banksel(ADCON1)
    movlw   0x06
    movwf   ADCON1
    banksel(CMCON)
    movlw   0x07
    movwf   CMCON
;
; Setup TIMER0
;
    banksel(OPTION_REG)
    movlw   0xC7                        ; TIMER0 clock source FOSC/4, TIMER0 uses prescaler, prescale 1:256
    movwf   OPTION_REG
;
; Setup TIMER1, CCP1 to capture HC-SR04 range pulse
;
    banksel(PIE1)
    bcf     PIE1,TMR1IE
    bcf     PIE1,CCP1IE
    banksel(T1CON)
    clrf    T1CON                       ; TIMER1 off, prescale 1:1, clock FOSC/4
    clrf    CCP1CON                     ; CCP1 off
    clrf    TMR1H
    clrf    TMR1L
    clrf    CCPR1H
    clrf    CCPR1L
    bcf     PIR1,TMR1IF
    bcf     PIR1,CCP1IF
    goto    AppInit
;
; LCD functions
;
#define LCD_PORT PORTD
#define LCD_DATA_BITS (0x0F)
#define LCD_PWR PORTD,7
#define LCD_E   PORTD,6
#define LCD_RW  PORTD,5
#define LCD_RS  PORTD,4
;
; Start address of each line on LCD module
;
#define LINE_ONE    0x00
#define LINE_TWO    0x40
;
;**********************************************************************
; Subroutine Name: Delay_4us, Delay_20us, Delay_40us
; Function: provides a delay for 4, 20 or 40 microseconds
;           Code relies on a 4MHz system oscillator
;
; Inputs:  none
;
; Outputs: none
;
;**********************************************************************

Delay_40us:
    call    Delay_20us              ; Wait at least 40 microseconds
Delay_20us:                         ; for command to complete.
    call    Delay_4us
    call    Delay_4us
    call    Delay_4us
    call    Delay_4us
    goto    Delay_4us
;
;**********************************************************************
; Subroutine Name: Delay_5ms
; Function: Provides a delay for at least 5 milliseconds
;           Code relies on a 4MHz system oscillator
;
; Inputs:  none
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
Delay_5ms:
    call    Dly0
    call    Dly0
Dly0:
    movlw   208     ; Magic number to get 5 milliseconds of delay with FOSC at 4MHz
Dly1:
    call    Delay_4us
    addlw   -1
    skpz
    goto    Dly1
Delay_4us:
    return
;
;**********************************************************************
; Subroutine Name: LCD_POR_Delay
; Function: provides a delay for at least 15 milliseconds
;
; Inputs:  none
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_POR_Delay:
    call    Delay_5ms
    call    Delay_5ms
    goto    Delay_5ms
;
;**********************************************************************
; Subroutine Name: LCD_Init
; Function: Initialize the LCD interface.
;
; Inputs:  none
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_Init:
    call    Delay_4us       ; Used to test the timing 
    call    Delay_40us      ; of the delay functions
    call    Delay_5ms       ; with the simulator.
    banksel BANK1
    movlw   ~LCD_DATA_BITS  ; Make GPIO bits for
    andwf   LCD_PORT,F      ; LCD interface output bits
    bcf     LCD_PWR
    bcf     LCD_E
    bcf     LCD_RW
    bcf     LCD_RS
    banksel BANK0
    andwf   LCD_PORT,F
    bsf     LCD_PWR         ; Turn the LCD module power on
    bcf     LCD_E
    bcf     LCD_RW
    bcf     LCD_RS
;
; Force LCD module to 4-bit parallel mode
;
    call    LCD_POR_Delay
    movlw   0x33
    xorwf   LCD_PORT,W
    andlw   LCD_DATA_BITS
    xorwf   LCD_PORT,F
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    call    Delay_5ms
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    call    Delay_5ms
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    call    Delay_5ms
    movlw   0x22
    xorwf   LCD_PORT,W
    andlw   LCD_DATA_BITS
    xorwf   LCD_PORT,F
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    call    Delay_5ms
;
; Configure 16x2 LCD character module
;
    movlw   (0x28)          ; 4-bit parallel, 5x7, multiline mode
    call    LCD_WriteCommand

    movlw   (0x08)          ; Display off, cursor off, blink off
    call    LCD_WriteCommand

    movlw   (0x01)          ; Clear display
    call    LCD_WriteCommand

    movlw   (0x06)          ; Entry mode, address increments, display shift off
    call    LCD_WriteCommand

    movlw   (0x0C)          ; Display on, cursor off, blink off
    call    LCD_WriteCommand

    return
;
;**********************************************************************
; Subroutine Name: LCD_WriteCommand
; Function: Set LCD_RS to command mode
;           Write command byte to PORTB
;           Pulse the LCD_E high for 4 microseconds
;           Wait for 5 milliseconds
;
; Inputs:  WREG     Command to be sent to LCD module
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_WriteCommand:
    banksel(LCD_PORT)
    bcf     LCD_RW          ; Assert LCD_RW low
    bcf     LCD_RS          ; Assert LCD_RS low
    call    LCD_Write1
    goto    Delay_5ms
;
;**********************************************************************
; Subroutine Name: LCD_WriteData
; Function: Set LCD_RS to data mode
;           Write command byte to PORTB
;           Pulse the LCD_E high for 4 microseconds
;           Wait for 40 microseconds
;
; Inputs:  WREG     Data to be sent to LCD module
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_WriteData:
    banksel(LCD_PORT)
    bcf     LCD_RW          ; Assert LCD_RW low
    bsf     LCD_RS          ; Assert LCD_RS high
LCD_Write1:
    movwf   LCD_Temp
 if (LCD_DATA_BITS & 0x0F)
    swapf   LCD_Temp,F
    movf    LCD_Temp,W
 endif
    xorwf   LCD_PORT,W
    andlw   LCD_DATA_BITS
    xorwf   LCD_PORT,F      ; Write high nibble
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    call    Delay_4us
    swapf   LCD_Temp,W
    xorwf   LCD_PORT,W
    andlw   LCD_DATA_BITS
    xorwf   LCD_PORT,F      ; Write low nibble
    bsf     LCD_E           ; Assert LCD_E high
    call    Delay_4us
    bcf     LCD_E           ; Assert LCD_E low
    goto    Delay_40us
;
;**********************************************************************
; Subroutine Name: LCD_SetPosition
; Function: Set the position where character are to be 
;           written to the LCD display.
;
; Inputs:  WREG     Line and position on that lone
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_SetPosition:
    iorlw   0x80        ; Set position LCD module command
    goto    LCD_WriteCommand
;
;**********************************************************************
; Subroutine Name: LCD_putrs
;
; Function: This routine writes a string of bytes to the
;           Hitachi HD44780 LCD controller. 
;
; Inputs:  EEADRH:EEADR as pointer to string in code space
;
; Outputs: none
;
; Uses:    WREG, STATUS
;
;**********************************************************************
LCD_putrs:
    banksel(EECON1)
    bsf     EECON1,EEPGD
    bsf     EECON1,RD
    nop
    nop
    banksel(EEADR)
    incf    EEADR,F
    skpnz
    incf    EEADRH,F
    movf    EEDATA,W
    skpnz
    return
    call    LCD_WriteData
    goto    LCD_putrs
;
; Macro to send message in ROM to LCD display
;
Show_LCD_Message MACRO LCD_message
    banksel(EEADR)
    movlw   LOW(LCD_message)
    movwf   EEADR
    movlw   HIGH(LCD_message)
    movwf   EEADRH
    call    LCD_putrs
    ENDM
;
;
;**********************************************************************
; Math support
;**********************************************************************
; Function: uMutiply_16x16
; Input:    A_reg, 16-bit multiplicand
;           B_reg, 16-bit multiplier
;
; Output:   D_reg, 32-bit product
;
; Notes:
;   The B_reg is overwritten by the low 16-bits of the product.
;
; Uses:    WREG, STATUS
;
;**********************************************************************
uMutiply_16x16:
    movlw   16              ; Setup the number of bits to multiply
    movwf   mBits
    clrf    D_reg+2         ; Zero out the product register.
    clrf    D_reg+3
    clrc
    rrf     B_reg+1,F
    rrf     B_reg,F
uM16x16a:
    skpc
    goto    uM16x16b
    movf    A_reg,W         ; When CARRY is set then add 
    addwf   D_reg+2,F       ; the multiplicand to the product.
    movf    A_reg+1,W
    skpnc
    incfsz  A_reg+1,W
    addwf   D_reg+3,F
uM16x16b:
    rrf     D_reg+3,F       ; Shift in the CARRY from the add
    rrf     D_reg+2,F       ; and shift the product and multiplier
    rrf     D_reg+1,F       ; right one bit.
    rrf     D_reg+0,F
    decfsz  mBits,f         ; Decrement the bit count and loop
    goto    uM16x16a        ; until multiplication is complete.
    
    return
;
;**********************************************************************
; Function: Bin2BCD
; Input:    D_reg, 32-bit binary
;
; Output:   BCD_out, 5 bytes of packed BCD digits
;
;
; Description:
;   Convert a 32-bit unsigned interger to a 5-byte 
;   packed BCD string of digits.
;
; Uses:    WREG, STATUS
;
;**********************************************************************
Bin2BCD:
    clrf    BCD_out+0       ; Clear result
    clrf    BCD_out+1
    clrf    BCD_out+2
    clrf    BCD_out+3
    clrf    BCD_out+4
    movlw   32              ; Set bit counter
    movwf   mBits

ConvertBit:
    movlw   0x33            ; Correct BCD value so that
    addwf   BCD_out+0,F     ; subsequent shift yields
    btfsc   BCD_out+0,3     ; correct value.
    andlw   0xF0
    btfsc   BCD_out+0,7
    andlw   0x0F
    subwf   BCD_out+0,F

    movlw   0x33
    addwf   BCD_out+1,F
    btfsc   BCD_out+1,3
    andlw   0xF0
    btfsc   BCD_out+1,7
    andlw   0x0F
    subwf   BCD_out+1,F

    movlw   0x33
    addwf   BCD_out+2,F
    btfsc   BCD_out+2,3
    andlw   0xF0
    btfsc   BCD_out+2,7
    andlw   0x0F
    subwf   BCD_out+2,F

    movlw   0x33
    addwf   BCD_out+3,F
    btfsc   BCD_out+3,3
    andlw   0xF0
    btfsc   BCD_out+3,7
    andlw   0x0F
    subwf   BCD_out+3,F

    movlw   0x33
    addwf   BCD_out+4,F
    btfsc   BCD_out+4,3
    andlw   0xF0
    btfsc   BCD_out+4,7
    andlw   0x0F
    subwf   BCD_out+4,F

    clrc
    rlf     D_reg+0,F       ; Shift out a binary bit
    rlf     D_reg+1,F
    rlf     D_reg+2,F
    rlf     D_reg+3,F

    rlf     BCD_out+0,F     ; .. and into BCD value
    rlf     BCD_out+1,F
    rlf     BCD_out+2,F
    rlf     BCD_out+3,F
    rlf     BCD_out+4,F

    decfsz  mBits,F         ; Repeat for all bits
    goto    ConvertBit
    return     
;
;**********************************************************************
; Function: TOF_to_distance
; Input:    A_reg, 16-bit Time of flight in microseconds from CCP1 capture
;           B_reg, 16-bit Speed of sound in air (343 micrometers/microsecond)
;
; Output:   D_reg, 32-bit (Time of flight)*(Speed of sound)/2 distance in micrometers
;
; Description:
;   Convert time of flight to distance in micrometers.
;
; Uses:    WREG, STATUS
;
;**********************************************************************
TOF_to_distance:
    banksel(D_reg)
    movf    TimeOfFlight+0,w
    movwf   A_reg+0
    movf    TimeOfFlight+1,w
    movwf   A_reg+1
    movlw   LOW(SPEED_OF_SOUND)
    movwf   B_reg+0
    movlw   HIGH(SPEED_OF_SOUND)
    movwf   B_reg+1
    call    uMutiply_16x16
;
; Add 1 to round up
    movlw   1
    addwf   D_reg+0,F
    skpnc
    addwf   D_reg+1,F
    skpnc
    addwf   D_reg+2,F
    skpnc
    addwf   D_reg+3,F
;
; Divide by 2 to convert time of flight in micrometers to range in micrometers
    clrc
    rrf     D_reg+3,F
    rrf     D_reg+2,F
    rrf     D_reg+1,F
    rrf     D_reg+0,F
    return
;
; Application initialization
;
AppInit:
;
; Initialize the LCD module
;
    call    LCD_Init    ; Initialize LCD module
    banksel(PIE1)
    bsf     PIE1,TMR1IE
    bsf     PIE1,CCP1IE
    banksel(INTCON)
    bsf     INTCON,PEIE
    bsf     INTCON,GIE
    banksel(T1CON)
    bsf     T1CON,TMR1ON
;
; Show the initial LCD screen
;
    movlw   LINE_ONE
    call    LCD_SetPosition
    Show_LCD_Message LCD_message1

    banksel(IdleTick)
    clrf    IdleTick
    bsf     IdleTick,3
;
; Application loop
;
AppLoop:
;
; Application loop HC-SR04 range state
;
    banksel(T1CON)
    btfsc   T1CON,TMR1ON
    goto    AppLoop_EndRangeState
    call    TOF_to_distance
    call    Bin2BCD         ; convert distance to BCD
    ;
    ; show four digits of rangs in centimeters
    movlw   LINE_TWO
    call    LCD_SetPosition
    banksel(BCD_out)
    swapf   BCD_out+3,W
    andlw   0x0F
    addlw   '0'
    call    LCD_WriteData
    banksel(BCD_out)
    movf    BCD_out+3,W
    andlw   0x0F
    addlw   '0'
    call    LCD_WriteData
    swapf   BCD_out+2,W
    andlw   0x0F
    addlw   '0'
    call    LCD_WriteData
    banksel(BCD_out)
    movf    BCD_out+2,W
    andlw   0x0F
    addlw   '0'
    call    LCD_WriteData
    movlw   'c'
    call    LCD_WriteData
    movlw   'm'
    call    LCD_WriteData
    ;
    ; Start TIMER1 to do another range pulse
    banksel(T1CON)
    bsf     T1CON,TMR1ON
AppLoop_EndRangeState:
;
; Applicaiton loop idle atate 
;
    banksel(IdleTick)
    movf    IdleTick,F
    skpz
    btfss   INTCON,TMR0IF
    goto    AppLoop
    bcf     INTCON,TMR0IF
    decfsz  IdleTick,F
    goto    AppLoop
    bsf     IdleTick,3
    movlw   1
    banksel(PORTB)
    xorwf   PORTB,F             ; Toggle LED on RB0 to show application loop is running
    goto    AppLoop
;
; ROM based LCD messages
;
LCD_message1:
;       0123456789.12345
    dt "16F877A  HC-SR04",0
;
; 
;
    END