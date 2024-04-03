/*
 * File:   main.c
 * Author: dan1138
 * Target: PIC18F57Q43
 * Compiler: pic-as v2.45
 * IDE: MPLABX v6.15
 * Test HW: PIC18F57Q43 Curiosity Nano (DM164150)
 *
 * Test PUSHL opcode using the PIC-AS(v2.45) assembler
 *
 * Push SW0 to restart test.
 * See output on vitrual COM port from Curiosity Nano (DM164150), 9600 baud.
 *
 * Add this line in the project properties box, pic-as Global Options -> Additional options:
 *   -Wl,-presetVec=0h,-pMainApp=20h,-pMyBuffer=500h
 *
 * Created on March 28, 2024, 11:36 AM
 *
 *                                                                           PIC18F57Q43
 *                 +----------------+                 +------------------+                 +---------------+                 +---------------+
 *           <>  1 : RC7            :           <> 13 : RF5              :           <> 25 : RA4           : PKOB_UOUT -> 37 : RF1/RX1       :
 *           <>  2 : RD4            :           <> 14 : RF6              :           <> 26 : RA5           :           <> 38 : RF2           :
 *           <>  3 : RD5            :           <> 15 : RF7              :           <> 27 : RE0           : NANO_LED0 <- 39 : RF3           :
 *           <>  4 : RD6            :  NANO_SW0 -> 16 : RB4              :           <> 28 : RE1           :           <> 40 : RC2           :
 *           <>  5 : RD7            :           <> 17 : RB5              :           <> 29 : RE2           :           <> 41 : RC3           :
 *       GND ->  6 : VSS            :  PKOB_PGC <> 18 : RB6/PGC          :       3v3 -> 30 : VDD           :           <> 42 : RD0           :
 *       3v3 ->  7 : VDD            :  PKOB_PGD <> 19 : RB7/PGD          :       GND -> 31 : VSS           :           <> 43 : RD1           :
 *           <>  8 : RB0/INT0       :  PKOB_VPP -> 20 : RE3/MCLRn        :           <> 32 : RA7/OSC1      :           <> 44 : RD2           :
 *           <>  9 : RB1            :           <> 21 : RA0              :           <> 33 : RA6/OSC2      :           <> 45 : RD3           :
 *           <> 10 : RB2            :           <> 22 : RA2              :           <> 34 : RC0/SOSCO     :           <> 46 : RC4           :
 *           <> 11 : RB3            :           <> 23 : RA2              :           <> 35 : RC1/SOSCI     :           <> 47 : RC5           :
 *           <> 12 : RF4            :           <> 24 : RA3              :  PKOB_UIN <- 36 : RF0/TX1       :           <> 48 : RC6           :
 *                 +----------------+                 +------------------+                 +---------------+                 +---------------+
 *                                                                             TQFP-48
 * This is what the output looks like:
 *     PIC18F57Q43 start built on Apr  3 2024 at 00:17:02
 *     FSR2 (t1):0506, (t2):0506, PUSHL 0xEF ; failed, FSR2 corrupt
 *     FSR2 (t1):0508, (t2):0508, PUSHL 0xEE ; failed, FSR2 corrupt
 *     FSR2 (t1):0506, (t2):0506, PUSHL 0xED ; failed, FSR2 corrupt
 *     FSR2 (t1):05EC, (t2):0508, PUSHL 0xEC ; failed, FSR2 corrupt
 *     FSR2 (t1):0572, (t2):0572, PUSHL 0xEB ; failed, FSR2 corrupt
 *     FSR2 (t1):0505, (t2):0505, PUSHL 0xE7 ; failed, FSR2 corrupt
 *     FSR2 (t1):0507, (t2):0507, PUSHL 0xE6 ; failed, FSR2 corrupt
 *     FSR2 (t1):0505, (t2):0505, PUSHL 0xE5 ; failed, FSR2 corrupt
 *     FSR2 (t1):0507, (t2):0507, PUSHL 0xE4 ; failed, FSR2 corrupt
 *     FSR2 (t1):0569, (t2):0569, PUSHL 0xE3 ; failed, FSR2 corrupt
 *     FSR2 (t1):0510, (t2):050F, PUSHL 0xDE ; failed, FSR2 corrupt, literal not pushed into Buffer
 *     FSR2 (t1):0510, (t2):050F, PUSHL 0xDC ; failed, FSR2 corrupt
 *     FSR2 (t1):056A, (t2):0569, PUSHL 0xDB ; failed, FSR2 corrupt, literal not pushed into Buffer
 */
 
/* Define how this application will configure the system oscillator frequency */
#define _XTAL_FREQ (4000000)
#define FCYC (_XTAL_FREQ/4)
 
/* Select UART1 baud rate */
#define BAUD_RATE (9600)

//#define PUSHL_WORKAROUND

    config FEXTOSC = OFF, RSTOSC = HFINTOSC_1MHZ, CLKOUTEN = OFF, PR1WAY = OFF, CSWEN = ON
    config FCMEN = ON, MCLRE = EXTMCLR, PWRTS = PWRT_OFF, MVECEN = OFF, IVT1WAY = OFF
    config LPBOREN = OFF, BOREN = OFF, BORV = VBOR_1P9, ZCD = OFF, PPS1WAY = OFF
    config STVREN = ON, LVP = ON, XINST = ON
    config WDTCPS = WDTCPS_31, WDTE = OFF, WDTCWS = WDTCWS_7, WDTCCS = SC
    config BBSIZE = BBSIZE_512, BBEN = OFF, SAFEN = OFF
    config WRTB = OFF, WRTC = OFF, WRTD = OFF, WRTSAF = OFF, WRTAPP = OFF
    config CP = OFF
 
    PROCESSOR 18F57Q43
    RADIX   DEC
 
#include <xc.inc>
 
;
; objects in common (Access bank) memory
;
    psect    MyBuffer,global,delta=1
    global  Buffer
    ds      8
Buffer:
    ds      8
;
; this must be linked to the reset vector
;
    PSECT   resetVec,class=CODE,reloc=2
resetVec:
    goto    main
;
; Main application
;
    PSECT   MainApp,class=CODE,reloc=2
/*
 * Initialize UART1
 */
U1_Init:
    bcf     PIE4,PIE4_U1TXIE_POSITION,c
    bcf     PIE4,PIE4_U1RXIE_POSITION,c
 
    banksel ANSELF
    bcf     ANSELF,ANSELF_ANSELF0_POSITION,b
    bcf     SLRCONF,SLRCONF_SLRF0_POSITION,b
    bsf     LATF,LATF_LATF0_POSITION,c
    bcf     TRISF,TRISF_TRISF0_POSITION,c
    
    bcf     ANSELF,ANSELF_ANSELF1_POSITION,b
    bsf     WPUF,WPUF_WPUF1_POSITION,b
    bsf     TRISF,TRISF_TRISF1_POSITION,c
 
    banksel U1CON0
    clrf    U1CON0,b        /* stop UART1 */
    clrf    U1CON1,b
    clrf    U1CON2,b
 
    bsf     U1CON0,U1CON0_BRGS_POSITION,b   /* use high speed BRG mode */
    bsf     U1CON0,U1CON0_TXEN_POSITION,b   /* enable TXD */
    bsf     U1CON0,U1CON0_RXEN_POSITION,b   /* enable RXD */
    
    /* set the baud rate */
    banksel U1BRG
    movlw   LOW((FCYC/BAUD_RATE)-1)
    movwf   U1BRGL,b
    movlw   HIGH((FCYC/BAUD_RATE)-1)
    movwf   U1BRGH,b
    
    banksel RF0PPS
    movlw   0x20    //RF0->UART1:TX1;
    movwf   RF0PPS,b
    banksel U1RXPPS
    movlw   0x29;   //RF1->UART1:RX1;    
    movwf   U1RXPPS,b
 
    banksel U1CON1
    bsf     U1CON1,U1CON1_ON_POSITION,b     /* enable UART1 */
    return
/*
 * Send byte to UART1
 */
U1_Write:
    banksel U1ERRIR
    btfss   U1ERRIR,U1ERRIR_U1TXMTIF_POSITION,b
    bra     $-2
    movwf   U1TXB,b     // Write the data byte to the USART.
    return
 
/*
 * Send string to UART1
 */
U1_WriteString:
    movf    TOSL,W,c
    movwf   TBLPTRL,c
    movf    TOSH,W,c
    movwf   TBLPTRH,c
    movf    TOSU,W,c
    movwf   TBLPTRU,c
U1_WriteStringLoop:
    tblrd*+             /* fetch low 8-bits */
    movf    TABLAT,W,c  /* load character into WREG and set zero flag */
    tblrd*+             /* fetch high 8-bits */
    bz      U1_WriteStringExit
    call    U1_Write
    bra     U1_WriteStringLoop
U1_WriteStringExit:
    btfsc   TBLPTRL,0,c
    reset               /* critical fauit if table pointer is missalingned on return */
    movf    TBLPTRL,W,c
    movwf   TOSL,c
    movf    TBLPTRH,W,c
    movwf   TOSH,c
    movf    TBLPTRU,W,c
    movwf   TOSU,c
    return
;
U1_ShowHEX:
    movwf   PRODL,c
    swapf   PRODL,W,c
    rcall   $+4
    movf    PRODL,W,C
    andlw   0x0F
    addlw   -10
    btfsc   STATUS,STATUS_C_POSITION,c
    addlw   'A'-'9'-1
    addlw   '0'+10
    call    U1_Write
    return
 
U1_ShowBuffer:
    movff   Buffer+1,WREG
    call    U1_ShowHEX
    movff   Buffer+0,WREG
    call    U1_ShowHEX
    return
 
U1_ShowFSR2:
    movf    FSR2H,W,c
    call    U1_ShowHEX
    movf    FSR2L,W,c
    call    U1_ShowHEX
    return
;
U1_CRLF:
    movlw   0x0D
    call    U1_Write
    movlw   0x0A
    call    U1_Write
    return
;
; main entry point
;
main:
    /* disable all interrupt sources */
    clrf    INTCON0,c
    /* select 4MHz system oscillator */
    banksel OSCCON1
    movlw   0x60
    movwf   OSCCON1,b
    movlw   0x02
    movwf   OSCFRQ,b
 
    call    U1_Init
 
;
; Application initialization
;
    /* setup to drive LED0 */
    banksel ANSELF
    bcf     ANSELF,ANSELF_ANSELF3_POSITION,b
    bcf     SLRCONF,SLRCONF_SLRF3_POSITION,b
    bcf     LATF,LATF_LATF3_POSITION,c
    bcf     TRISF,TRISF_TRISF3_POSITION,c
    
    /* setup to read SW0 */
    banksel ANSELB
    bcf     ANSELB,4,b
    bsf     WPUB,WPUB_WPUB4_POSITION,b
    bsf     TRISB,TRISB_TRISB4_POSITION,c
 
    /* spin wait so UART has a few millisecods at idle */
    movlw   2
    clrf    PRODH,c
    clrf    PRODL,c
    decfsz  PRODL,F,c
    bra     $-2
    decfsz  PRODH,F,c
    bra     $-6
    addlw   -1
    bnz     $-10
 
    /* wait while SW0 is preaaed */
    btfss   PORTB,PORTB_RB4_POSITION,c
    bra     $-2
 
    /* announce to the world tep applicaiton has started */
    call    U1_WriteString
    dw      13,10,"PIC18F57Q43 start built on "
    dw      __DATE__
    dw      " at "
    dw      __TIME__
    dw      13,10,0
 
    /* Initialize index for selecting PUSHL opcpde */
    push
    setf    TOSL,c
;
; Application Loop
;
AppLoop:
    btfss   PORTB,PORTB_RB4_POSITION,c
    reset
    tstfsz  TOSL,c
    bra     Test_Loop
    bra     AppLoop
 
Test_Loop:
    /* initialize buffer with the complement of what PUSHL is expected to write */
    lfsr    2,Buffer+6
    comf    TOSL,W,c
    movwf   POSTINC2,c
    movwf   INDF2,c
;
; This is the buisness end of the test.
;
; Test part 1:
;   load FSR2 with the address of Buffer+7 (last byte of buffer space)
;   call a function that executes ONE PUSHL opcode
;   validate that the buffer RAM changed to the expected literal value
;   validate that FSR2 decremented by one.
;
; Test part 2:
;   load FSR2 with the address of Buffer+6 (second to last byte of buffer space)
;   call a function that executes the same PUSHL opcode used in part 1
;   validate that the buffer RAM changed to the expected literal value
;   validate that FSR2 decremented by one.
;
    clrf    TOSH,c          /* clear test result flags */
;
; Start part 1 test
    lfsr    2,Buffer+7
    movf    TOSL,W,c
    movlb   0x04            /* selecting bank 4, a different bank causes PUSHL to fail in different ways */
    lfsr    0,0x507         /* The fault in the PUSHL opcode appears to access the SFRs associated with  */
    lfsr    1,0x506         /* indirect operations of the FSR registers. So initialise them too.         */
    call    TestPUSHL
    movff   FSR2L,Buffer+0     /* save whatever PUSHL did to FSR2 */
    movff   FSR2H,Buffer+1
;
; Part 1 validation
    movlw   LOW(Buffer+6)
    xorwf   FSR2L,W,c
    btfss   STATUS,STATUS_Z_POSITION,c
    bsf     TOSH,0,c        /* Set bit 0, FS2 corrupt after PUSHL */
    banksel Buffer+7
    movf    TOSL,W,c
    xorwf   Buffer+7,W,b
    btfss   STATUS,STATUS_Z_POSITION,c
    bsf     TOSH,1,c        /* Set bit 1, Buffer does not match PUSHL literal */
;
; Start part 2 test
    lfsr    2,Buffer+6
    movf    TOSL,W,c
    movlb   0x04            /* selecting bank 4, a different bank causes PUSHL to fail in different ways */
    lfsr    0,0x507         /* The fault in the PUSHL opcode appears to access the SFRs associated with  */
    lfsr    1,0x506         /* indirect operations of the FSR registers. So initialise them too.         */
    call    TestPUSHL
;
; Part 2 validation
    movlw   LOW(Buffer+5)
    xorwf   FSR2L,W,c
    btfss   STATUS,STATUS_Z_POSITION,c
    bsf     TOSH,0,c        /* Set bit 0, FS2 corrupt after PUSHL */
    banksel Buffer+7
    movf    TOSL,W,c
    xorwf   Buffer+7,W,b
    btfss   STATUS,STATUS_Z_POSITION,c
    bsf     TOSH,1,c        /* Set bit 1, Buffer does not match PUSHL literal */
;
    movf    TOSH,F,c
    bz      LooksGood
    
    btg     LATF,LATF_LATF3_POSITION,c  ; toggle LED
 
    /* spin wait so LED state can be observed */
    movlw   3
    clrf    PRODH,c
    clrf    PRODL,c
    decfsz  PRODL,F,c
    bra     $-2
    decfsz  PRODH,F,c
    bra     $-6
    addlw   -1
    bnz     $-10
 
    /* send diagnostic to UART1 */
    call    U1_WriteString
    dw      "FSR2 (t1):",0
 
    call    U1_ShowBuffer
 
    call    U1_WriteString
    dw      ", (t2):",0
 
    call    U1_ShowFSR2
 
    call    U1_WriteString
    dw      ", PUSHL 0x",0
 
    movf    TOSL,W,c
    call    U1_ShowHEX
 
    call    U1_WriteString
    dw      " ; failed",0
 
Diag_FSR:
    btfss   TOSH,0,c
    goto    Diag_Buffer
 
    call    U1_WriteString
    dw      ", FSR2 corrupt",0
 
Diag_Buffer:
    btfsc   TOSH,1,c
    goto    DiagsDone
 
    call    U1_WriteString
    dw      ", literal not pushed into Buffer",0
 
DiagsDone:
    call    U1_CRLF
 
LooksGood:
    tstfsz  TOSL,c
    decfsz  TOSL,F,c    ; select next PUSHL opcode
    goto    AppLoop
    bsf     LATF,LATF_LATF3_POSITION,c  ; turn LED off
    goto    Test_Loop   ; Special case to test PUSHL with zero as the literal
 
;
; Table 0f PUSHL opcodes and lookup function
;
    PSECT   TablePUSHL,class=CODE,reloc=2
;
LookupPUSHL:                            ; The pic-as assembler usually does a crap job of pointer arithmatic but
    mullw   HIGH(TableEnd-TableStart)   ; this only works because there are exactly 256 elements in the table.
    movf    PRODL,W,c
    addwf   TOSL,F,c
    movf    PRODH,W,c
    addwfc  TOSH,F,c
    movlw   0
    addwfc  TOSU,F,c
    return
;
; Function: TestPUSHL
;
; Input:    WREG (00 to FF) selects PUSHL literal opcdoe
;
TestPUSHL:
    rcall   LookupPUSHL
TableStart:
; Table of all 256 PUSHL literal opcodes
Literal  set 0
    REPT 256
    movlw   0       /* the value in WREG affects how PUSHL fails */
#if defined(PUSHL_WORKAROUND)
  if (Literal < 0xDB)
    pushl   Literal
    return
    nop
  else
    if (Literal < 0xF0)
      pushl   Literal-128
      bsf     [1],7
      return
    else
      pushl   Literal
      return
      nop
    endif
  endif
#else
      pushl   Literal
      return
#endif
Literal set Literal+1
    ENDM
TableEnd:
    END     resetVec