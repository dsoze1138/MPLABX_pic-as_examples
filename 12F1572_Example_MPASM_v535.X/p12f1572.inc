        LIST

;==========================================================================
; Build date : Jan 06 2020
;  MPASM PIC12F1572 processor include
; 
;  (c) Copyright 1999-2020 Microchip Technology, All rights reserved
;==========================================================================

        NOLIST

;==========================================================================
;  This header file defines configurations, registers, and other useful
;  bits of information for the PIC12F1572 microcontroller.  These names
;  are taken to match the data sheets as closely as possible.
;
;  Note that the processor must be selected before this file is included.
;  The processor may be selected the following ways:
;
;       1. Command line switch:
;               C:\MPASM MYFILE.ASM /PIC12F1572
;       2. LIST directive in the source file
;               LIST   P=PIC12F1572
;       3. Processor Type entry in the MPASM full-screen interface
;       4. Setting the processor in the MPLAB Project Dialog
;==========================================================================

;==========================================================================
;
;       Verify Processor
;
;==========================================================================
        IFNDEF __12F1572
           MESSG "Processor-header file mismatch.  Verify selected processor."
        ENDIF



;==========================================================================
;
;       Register Definitions
;
;==========================================================================

W                EQU  H'0000'
F                EQU  H'0001'

;----- Register Files -----------------------------------------------------

;-----Bank0------------------
INDF0            EQU  H'0000'
INDF1            EQU  H'0001'
PCL              EQU  H'0002'
STATUS           EQU  H'0003'
FSR0             EQU  H'0004'
FSR0L            EQU  H'0004'
FSR0H            EQU  H'0005'
FSR1             EQU  H'0006'
FSR1L            EQU  H'0006'
FSR1H            EQU  H'0007'
BSR              EQU  H'0008'
WREG             EQU  H'0009'
PCLATH           EQU  H'000A'
INTCON           EQU  H'000B'
PORTA            EQU  H'000C'
PIR1             EQU  H'0011'
PIR2             EQU  H'0012'
PIR3             EQU  H'0013'
TMR0             EQU  H'0015'
TMR1             EQU  H'0016'
TMR1L            EQU  H'0016'
TMR1H            EQU  H'0017'
T1CON            EQU  H'0018'
T1GCON           EQU  H'0019'
TMR2             EQU  H'001A'
PR2              EQU  H'001B'
T2CON            EQU  H'001C'

;-----Bank1------------------
TRISA            EQU  H'008C'
PIE1             EQU  H'0091'
PIE2             EQU  H'0092'
PIE3             EQU  H'0093'
OPTION_REG       EQU  H'0095'
PCON             EQU  H'0096'
WDTCON           EQU  H'0097'
OSCTUNE          EQU  H'0098'
OSCCON           EQU  H'0099'
OSCSTAT          EQU  H'009A'
ADRES            EQU  H'009B'
ADRESL           EQU  H'009B'
ADRESH           EQU  H'009C'
ADCON0           EQU  H'009D'
ADCON1           EQU  H'009E'
ADCON2           EQU  H'009F'

;-----Bank2------------------
LATA             EQU  H'010C'
CM1CON0          EQU  H'0111'
CM1CON1          EQU  H'0112'
CMOUT            EQU  H'0115'
BORCON           EQU  H'0116'
FVRCON           EQU  H'0117'
DACCON0          EQU  H'0118'
DACCON1          EQU  H'0119'
APFCON           EQU  H'011D'
APFCON0          EQU  H'011D'

;-----Bank3------------------
ANSELA           EQU  H'018C'
PMADR            EQU  H'0191'
PMADRL           EQU  H'0191'
PMADRH           EQU  H'0192'
PMDAT            EQU  H'0193'
PMDATL           EQU  H'0193'
PMDATH           EQU  H'0194'
PMCON1           EQU  H'0195'
PMCON2           EQU  H'0196'
VREGCON          EQU  H'0197'
RCREG            EQU  H'0199'
TXREG            EQU  H'019A'
SPBRG            EQU  H'019B'
SPBRGL           EQU  H'019B'
SPBRGH           EQU  H'019C'
RCSTA            EQU  H'019D'
TXSTA            EQU  H'019E'
BAUDCON          EQU  H'019F'

;-----Bank4------------------
WPUA             EQU  H'020C'

;-----Bank5------------------
ODCONA           EQU  H'028C'

;-----Bank6------------------
SLRCONA          EQU  H'030C'

;-----Bank7------------------
INLVLA           EQU  H'038C'
IOCAP            EQU  H'0391'
IOCAN            EQU  H'0392'
IOCAF            EQU  H'0393'

;-----Bank13------------------
CWG1DBR          EQU  H'0691'
CWG1DBF          EQU  H'0692'
CWG1CON0         EQU  H'0693'
CWG1CON1         EQU  H'0694'
CWG1CON2         EQU  H'0695'

;-----Bank27------------------
PWMEN            EQU  H'0D8E'
PWMLD            EQU  H'0D8F'
PWMOUT           EQU  H'0D90'
PWM1PH           EQU  H'0D91'
PWM1PHL          EQU  H'0D91'
PWM1PHH          EQU  H'0D92'
PWM1DC           EQU  H'0D93'
PWM1DCL          EQU  H'0D93'
PWM1DCH          EQU  H'0D94'
PWM1PR           EQU  H'0D95'
PWM1PRL          EQU  H'0D95'
PWM1PRH          EQU  H'0D96'
PWM1OF           EQU  H'0D97'
PWM1OFL          EQU  H'0D97'
PWM1OFH          EQU  H'0D98'
PWM1TMR          EQU  H'0D99'
PWM1TMRL         EQU  H'0D99'
PWM1TMRH         EQU  H'0D9A'
PWM1CON          EQU  H'0D9B'
PWM1INTCON       EQU  H'0D9C'
PWM1INTE         EQU  H'0D9C'
PWM1INTF         EQU  H'0D9D'
PWM1INTFLG       EQU  H'0D9D'
PWM1CLKCON       EQU  H'0D9E'
PWM1LDCON        EQU  H'0D9F'
PWM1OFCON        EQU  H'0DA0'
PWM2PH           EQU  H'0DA1'
PWM2PHL          EQU  H'0DA1'
PWM2PHH          EQU  H'0DA2'
PWM2DC           EQU  H'0DA3'
PWM2DCL          EQU  H'0DA3'
PWM2DCH          EQU  H'0DA4'
PWM2PR           EQU  H'0DA5'
PWM2PRL          EQU  H'0DA5'
PWM2PRH          EQU  H'0DA6'
PWM2OF           EQU  H'0DA7'
PWM2OFL          EQU  H'0DA7'
PWM2OFH          EQU  H'0DA8'
PWM2TMR          EQU  H'0DA9'
PWM2TMRL         EQU  H'0DA9'
PWM2TMRH         EQU  H'0DAA'
PWM2CON          EQU  H'0DAB'
PWM2INTCON       EQU  H'0DAC'
PWM2INTE         EQU  H'0DAC'
PWM2INTF         EQU  H'0DAD'
PWM2INTFLG       EQU  H'0DAD'
PWM2CLKCON       EQU  H'0DAE'
PWM2LDCON        EQU  H'0DAF'
PWM2OFCON        EQU  H'0DB0'
PWM3PH           EQU  H'0DB1'
PWM3PHL          EQU  H'0DB1'
PWM3PHH          EQU  H'0DB2'
PWM3DC           EQU  H'0DB3'
PWM3DCL          EQU  H'0DB3'
PWM3DCH          EQU  H'0DB4'
PWM3PR           EQU  H'0DB5'
PWM3PRL          EQU  H'0DB5'
PWM3PRH          EQU  H'0DB6'
PWM3OF           EQU  H'0DB7'
PWM3OFL          EQU  H'0DB7'
PWM3OFH          EQU  H'0DB8'
PWM3TMR          EQU  H'0DB9'
PWM3TMRL         EQU  H'0DB9'
PWM3TMRH         EQU  H'0DBA'
PWM3CON          EQU  H'0DBB'
PWM3INTCON       EQU  H'0DBC'
PWM3INTE         EQU  H'0DBC'
PWM3INTF         EQU  H'0DBD'
PWM3INTFLG       EQU  H'0DBD'
PWM3CLKCON       EQU  H'0DBE'
PWM3LDCON        EQU  H'0DBF'
PWM3OFCON        EQU  H'0DC0'

;-----Bank31------------------
STATUS_SHAD      EQU  H'0FE4'
WREG_SHAD        EQU  H'0FE5'
BSR_SHAD         EQU  H'0FE6'
PCLATH_SHAD      EQU  H'0FE7'
FSR0L_SHAD       EQU  H'0FE8'
FSR0_SHAD        EQU  H'0FE8'
FSR0H_SHAD       EQU  H'0FE9'
FSR1L_SHAD       EQU  H'0FEA'
FSR1_SHAD        EQU  H'0FEA'
FSR1H_SHAD       EQU  H'0FEB'
STKPTR           EQU  H'0FED'
TOS              EQU  H'0FEE'
TOSL             EQU  H'0FEE'
TOSH             EQU  H'0FEF'

;----- STATUS Bits -----------------------------------------------------
C                EQU  H'0000'
DC               EQU  H'0001'
Z                EQU  H'0002'
NOT_PD           EQU  H'0003'
NOT_TO           EQU  H'0004'


;----- BSR Bits -----------------------------------------------------
BSR0             EQU  H'0000'
BSR1             EQU  H'0001'
BSR2             EQU  H'0002'
BSR3             EQU  H'0003'
BSR4             EQU  H'0004'



;----- INTCON Bits -----------------------------------------------------
IOCIF            EQU  H'0000'
INTF             EQU  H'0001'
TMR0IF           EQU  H'0002'
IOCIE            EQU  H'0003'
INTE             EQU  H'0004'
TMR0IE           EQU  H'0005'
PEIE             EQU  H'0006'
GIE              EQU  H'0007'

T0IF             EQU  H'0002'
T0IE             EQU  H'0005'


;----- PORTA Bits -----------------------------------------------------
RA0              EQU  H'0000'
RA1              EQU  H'0001'
RA2              EQU  H'0002'
RA3              EQU  H'0003'
RA4              EQU  H'0004'
RA5              EQU  H'0005'



;----- PIR1 Bits -----------------------------------------------------
TMR1IF           EQU  H'0000'
TMR2IF           EQU  H'0001'
TXIF             EQU  H'0004'
RCIF             EQU  H'0005'
ADIF             EQU  H'0006'
TMR1GIF          EQU  H'0007'


;----- PIR2 Bits -----------------------------------------------------
C1IF             EQU  H'0005'


;----- PIR3 Bits -----------------------------------------------------
PWM1IF           EQU  H'0004'
PWM2IF           EQU  H'0005'
PWM3IF           EQU  H'0006'


;----- T1CON Bits -----------------------------------------------------
TMR1ON           EQU  H'0000'
NOT_T1SYNC       EQU  H'0002'
T1CKPS0          EQU  H'0004'
T1CKPS1          EQU  H'0005'
TMR1CS0          EQU  H'0006'
TMR1CS1          EQU  H'0007'



;----- T1GCON Bits -----------------------------------------------------
T1GSS0           EQU  H'0000'
T1GSS1           EQU  H'0001'
T1GVAL           EQU  H'0002'
T1GGO_NOT_DONE   EQU  H'0003'
T1GSPM           EQU  H'0004'
T1GTM            EQU  H'0005'
T1GPOL           EQU  H'0006'
TMR1GE           EQU  H'0007'

T1GGO            EQU  H'0003'


;----- T2CON Bits -----------------------------------------------------
T2CKPS0          EQU  H'0000'
T2CKPS1          EQU  H'0001'
T2OUTPS0         EQU  H'0003'
T2OUTPS1         EQU  H'0004'
T2OUTPS2         EQU  H'0005'
T2OUTPS3         EQU  H'0006'

TMR2ON           EQU  H'0002'


;----- TRISA Bits -----------------------------------------------------
TRISA0           EQU  H'0000'
TRISA1           EQU  H'0001'
TRISA2           EQU  H'0002'
TRISA3           EQU  H'0003'
TRISA4           EQU  H'0004'
TRISA5           EQU  H'0005'



;----- PIE1 Bits -----------------------------------------------------
TMR1IE           EQU  H'0000'
TMR2IE           EQU  H'0001'
TXIE             EQU  H'0004'
RCIE             EQU  H'0005'
ADIE             EQU  H'0006'
TMR1GIE          EQU  H'0007'


;----- PIE2 Bits -----------------------------------------------------
C1IE             EQU  H'0005'


;----- PIE3 Bits -----------------------------------------------------
PWM1IE           EQU  H'0004'
PWM2IE           EQU  H'0005'
PWM3IE           EQU  H'0006'


;----- OPTION_REG Bits -----------------------------------------------------
PS0_OPTION_REG   EQU  H'0000'
PS1_OPTION_REG   EQU  H'0001'
PS2_OPTION_REG   EQU  H'0002'
PSA              EQU  H'0003'
TMR0SE           EQU  H'0004'
TMR0CS           EQU  H'0005'
INTEDG           EQU  H'0006'
NOT_WPUEN        EQU  H'0007'

T0SE             EQU  H'0004'
T0CS             EQU  H'0005'


;----- PCON Bits -----------------------------------------------------
NOT_BOR          EQU  H'0000'
NOT_POR          EQU  H'0001'
NOT_RI           EQU  H'0002'
NOT_RMCLR        EQU  H'0003'
NOT_RWDT         EQU  H'0004'
STKUNF           EQU  H'0006'
STKOVF           EQU  H'0007'


;----- WDTCON Bits -----------------------------------------------------
SWDTEN           EQU  H'0000'
WDTPS0           EQU  H'0001'
WDTPS1           EQU  H'0002'
WDTPS2           EQU  H'0003'
WDTPS3           EQU  H'0004'
WDTPS4           EQU  H'0005'



;----- OSCTUNE Bits -----------------------------------------------------
TUN0             EQU  H'0000'
TUN1             EQU  H'0001'
TUN2             EQU  H'0002'
TUN3             EQU  H'0003'
TUN4             EQU  H'0004'
TUN5             EQU  H'0005'



;----- OSCCON Bits -----------------------------------------------------
SCS0             EQU  H'0000'
SCS1             EQU  H'0001'
IRCF0            EQU  H'0003'
IRCF1            EQU  H'0004'
IRCF2            EQU  H'0005'
IRCF3            EQU  H'0006'
SPLLEN           EQU  H'0007'



;----- OSCSTAT Bits -----------------------------------------------------
HFIOFS           EQU  H'0000'
LFIOFR           EQU  H'0001'
MFIOFR           EQU  H'0002'
HFIOFL           EQU  H'0003'
HFIOFR           EQU  H'0004'
OSTS             EQU  H'0005'
PLLR             EQU  H'0006'


;----- ADCON0 Bits -----------------------------------------------------
ADON             EQU  H'0000'
GO_NOT_DONE      EQU  H'0001'
CHS0             EQU  H'0002'
CHS1             EQU  H'0003'
CHS2             EQU  H'0004'
CHS3             EQU  H'0005'
CHS4             EQU  H'0006'

ADGO             EQU  H'0001'

GO               EQU  H'0001'

NOT_DONE         EQU  H'0001'


;----- ADCON1 Bits -----------------------------------------------------
ADPREF0          EQU  H'0000'
ADPREF1          EQU  H'0001'
ADCS0            EQU  H'0004'
ADCS1            EQU  H'0005'
ADCS2            EQU  H'0006'
ADFM             EQU  H'0007'



;----- ADCON2 Bits -----------------------------------------------------
TRIGSEL0         EQU  H'0004'
TRIGSEL1         EQU  H'0005'
TRIGSEL2         EQU  H'0006'
TRIGSEL3         EQU  H'0007'



;----- LATA Bits -----------------------------------------------------
LATA0            EQU  H'0000'
LATA1            EQU  H'0001'
LATA2            EQU  H'0002'
LATA4            EQU  H'0004'
LATA5            EQU  H'0005'



;----- CM1CON0 Bits -----------------------------------------------------
C1SYNC           EQU  H'0000'
C1HYS            EQU  H'0001'
C1SP             EQU  H'0002'
C1POL            EQU  H'0004'
C1OE             EQU  H'0005'
C1OUT            EQU  H'0006'
C1ON             EQU  H'0007'


;----- CM1CON1 Bits -----------------------------------------------------
C1NCH0           EQU  H'0000'
C1NCH1           EQU  H'0001'
C1NCH2           EQU  H'0002'
C1PCH0           EQU  H'0004'
C1PCH1           EQU  H'0005'
C1INTN           EQU  H'0006'
C1INTP           EQU  H'0007'



;----- CMOUT Bits -----------------------------------------------------
MC1OUT           EQU  H'0000'


;----- BORCON Bits -----------------------------------------------------
BORRDY           EQU  H'0000'
BORFS            EQU  H'0006'
SBOREN           EQU  H'0007'


;----- FVRCON Bits -----------------------------------------------------
ADFVR0           EQU  H'0000'
ADFVR1           EQU  H'0001'
CDAFVR0          EQU  H'0002'
CDAFVR1          EQU  H'0003'
TSRNG            EQU  H'0004'
TSEN             EQU  H'0005'
FVRRDY           EQU  H'0006'
FVREN            EQU  H'0007'



;----- DACCON0 Bits -----------------------------------------------------
DACPSS0          EQU  H'0002'
DACPSS1          EQU  H'0003'
DACOE            EQU  H'0005'
DACLPS           EQU  H'0006'
DACEN            EQU  H'0007'



;----- DACCON1 Bits -----------------------------------------------------
DACR0            EQU  H'0000'
DACR1            EQU  H'0001'
DACR2            EQU  H'0002'
DACR3            EQU  H'0003'
DACR4            EQU  H'0004'



;----- APFCON Bits -----------------------------------------------------
P1SEL            EQU  H'0000'
P2SEL            EQU  H'0001'
TXCKSEL          EQU  H'0002'
T1GSEL           EQU  H'0003'
CWGBSEL          EQU  H'0005'
CWGASEL          EQU  H'0006'
RXDTSEL          EQU  H'0007'


;----- APFCON0 Bits -----------------------------------------------------
P1SEL            EQU  H'0000'
P2SEL            EQU  H'0001'
TXCKSEL          EQU  H'0002'
T1GSEL           EQU  H'0003'
CWGBSEL          EQU  H'0005'
CWGASEL          EQU  H'0006'
RXDTSEL          EQU  H'0007'


;----- ANSELA Bits -----------------------------------------------------
ANSA0            EQU  H'0000'
ANSA1            EQU  H'0001'
ANSA2            EQU  H'0002'
ANSA4            EQU  H'0004'



;----- PMCON1 Bits -----------------------------------------------------
RD               EQU  H'0000'
WR               EQU  H'0001'
WREN             EQU  H'0002'
WRERR            EQU  H'0003'
FREE             EQU  H'0004'
LWLO             EQU  H'0005'
CFGS             EQU  H'0006'


;----- VREGCON Bits -----------------------------------------------------
VREGPM           EQU  H'0001'


;----- RCSTA Bits -----------------------------------------------------
RX9D             EQU  H'0000'
OERR             EQU  H'0001'
FERR             EQU  H'0002'
ADDEN            EQU  H'0003'
CREN             EQU  H'0004'
SREN             EQU  H'0005'
RX9              EQU  H'0006'
SPEN             EQU  H'0007'


;----- TXSTA Bits -----------------------------------------------------
TX9D             EQU  H'0000'
TRMT             EQU  H'0001'
BRGH             EQU  H'0002'
SENDB            EQU  H'0003'
SYNC             EQU  H'0004'
TXEN             EQU  H'0005'
TX9              EQU  H'0006'
CSRC             EQU  H'0007'


;----- BAUDCON Bits -----------------------------------------------------
ABDEN            EQU  H'0000'
WUE              EQU  H'0001'
BRG16            EQU  H'0003'
SCKP             EQU  H'0004'
RCIDL            EQU  H'0006'
ABDOVF           EQU  H'0007'


;----- WPUA Bits -----------------------------------------------------
WPUA0            EQU  H'0000'
WPUA1            EQU  H'0001'
WPUA2            EQU  H'0002'
WPUA3            EQU  H'0003'
WPUA4            EQU  H'0004'
WPUA5            EQU  H'0005'



;----- ODCONA Bits -----------------------------------------------------
ODA0             EQU  H'0000'
ODA1             EQU  H'0001'
ODA2             EQU  H'0002'
ODA4             EQU  H'0004'
ODA5             EQU  H'0005'



;----- SLRCONA Bits -----------------------------------------------------
SLRA0            EQU  H'0000'
SLRA1            EQU  H'0001'
SLRA2            EQU  H'0002'
SLRA4            EQU  H'0004'
SLRA5            EQU  H'0005'



;----- INLVLA Bits -----------------------------------------------------
INLVLA0          EQU  H'0000'
INLVLA1          EQU  H'0001'
INLVLA2          EQU  H'0002'
INLVLA3          EQU  H'0003'
INLVLA4          EQU  H'0004'
INLVLA5          EQU  H'0005'



;----- IOCAP Bits -----------------------------------------------------
IOCAP0           EQU  H'0000'
IOCAP1           EQU  H'0001'
IOCAP2           EQU  H'0002'
IOCAP3           EQU  H'0003'
IOCAP4           EQU  H'0004'
IOCAP5           EQU  H'0005'



;----- IOCAN Bits -----------------------------------------------------
IOCAN0           EQU  H'0000'
IOCAN1           EQU  H'0001'
IOCAN2           EQU  H'0002'
IOCAN3           EQU  H'0003'
IOCAN4           EQU  H'0004'
IOCAN5           EQU  H'0005'



;----- IOCAF Bits -----------------------------------------------------
IOCAF0           EQU  H'0000'
IOCAF1           EQU  H'0001'
IOCAF2           EQU  H'0002'
IOCAF3           EQU  H'0003'
IOCAF4           EQU  H'0004'
IOCAF5           EQU  H'0005'



;----- CWG1DBR Bits -----------------------------------------------------
CWG1DBR0         EQU  H'0000'
CWG1DBR1         EQU  H'0001'
CWG1DBR2         EQU  H'0002'
CWG1DBR3         EQU  H'0003'
CWG1DBR4         EQU  H'0004'
CWG1DBR5         EQU  H'0005'


;----- CWG1DBF Bits -----------------------------------------------------
CWG1DBF0         EQU  H'0000'
CWG1DBF1         EQU  H'0001'
CWG1DBF2         EQU  H'0002'
CWG1DBF3         EQU  H'0003'
CWG1DBF4         EQU  H'0004'
CWG1DBF5         EQU  H'0005'


;----- CWG1CON0 Bits -----------------------------------------------------
G1CS0            EQU  H'0000'
G1POLA           EQU  H'0003'
G1POLB           EQU  H'0004'
G1OEA            EQU  H'0005'
G1OEB            EQU  H'0006'
G1EN             EQU  H'0007'



;----- CWG1CON1 Bits -----------------------------------------------------
G1IS0            EQU  H'0000'
G1IS1            EQU  H'0001'
G1IS2            EQU  H'0002'

G1ASDLA0         EQU  H'0004'
G1ASDLA1         EQU  H'0005'
G1ASDLB0         EQU  H'0006'
G1ASDLB1         EQU  H'0007'


;----- CWG1CON2 Bits -----------------------------------------------------
G1ASDSFLT        EQU  H'0001'
G1ASDSC1         EQU  H'0002'
G1ARSEN          EQU  H'0006'
G1ASE            EQU  H'0007'


;----- PWMEN Bits -----------------------------------------------------
PWM1EN_A         EQU  H'0000'
PWM2EN_A         EQU  H'0001'
PWM3EN_A         EQU  H'0002'

MPWM1EN          EQU  H'0000'
MPWM2EN          EQU  H'0001'
MPWM3EN          EQU  H'0002'


;----- PWMLD Bits -----------------------------------------------------
PWM1LDA_A        EQU  H'0000'
PWM2LDA_A        EQU  H'0001'
PWM3LDA_A        EQU  H'0002'

MPWM1LD          EQU  H'0000'
MPWM2LD          EQU  H'0001'
MPWM3LD          EQU  H'0002'


;----- PWMOUT Bits -----------------------------------------------------
PWM1OUT_A        EQU  H'0000'
PWM2OUT_A        EQU  H'0001'
PWM3OUT_A        EQU  H'0002'

MPWM1OUT         EQU  H'0000'
MPWM2OUT         EQU  H'0001'
MPWM3OUT         EQU  H'0002'


;----- PWM1PHL Bits -----------------------------------------------------
PWM1PHL0         EQU  H'0000'
PWM1PHL1         EQU  H'0001'
PWM1PHL2         EQU  H'0002'
PWM1PHL3         EQU  H'0003'
PWM1PHL4         EQU  H'0004'
PWM1PHL5         EQU  H'0005'
PWM1PHL6         EQU  H'0006'
PWM1PHL7         EQU  H'0007'



;----- PWM1PHH Bits -----------------------------------------------------
PWM1PHH0         EQU  H'0000'
PWM1PHH1         EQU  H'0001'
PWM1PHH2         EQU  H'0002'
PWM1PHH3         EQU  H'0003'
PWM1PHH4         EQU  H'0004'
PWM1PHH5         EQU  H'0005'
PWM1PHH6         EQU  H'0006'
PWM1PHH7         EQU  H'0007'



;----- PWM1DCL Bits -----------------------------------------------------
PWM1DCL0         EQU  H'0000'
PWM1DCL1         EQU  H'0001'
PWM1DCL2         EQU  H'0002'
PWM1DCL3         EQU  H'0003'
PWM1DCL4         EQU  H'0004'
PWM1DCL5         EQU  H'0005'
PWM1DCL6         EQU  H'0006'
PWM1DCL7         EQU  H'0007'



;----- PWM1DCH Bits -----------------------------------------------------
PWM1DCH0         EQU  H'0000'
PWM1DCH1         EQU  H'0001'
PWM1DCH2         EQU  H'0002'
PWM1DCH3         EQU  H'0003'
PWM1DCH4         EQU  H'0004'
PWM1DCH5         EQU  H'0005'
PWM1DCH6         EQU  H'0006'
PWM1DCH7         EQU  H'0007'



;----- PWM1PRL Bits -----------------------------------------------------
PWM1PRL0         EQU  H'0000'
PWM1PRL1         EQU  H'0001'
PWM1PRL2         EQU  H'0002'
PWM1PRL3         EQU  H'0003'
PWM1PRL4         EQU  H'0004'
PWM1PRL5         EQU  H'0005'
PWM1PRL6         EQU  H'0006'
PWM1PRL7         EQU  H'0007'



;----- PWM1PRH Bits -----------------------------------------------------
PWM1PRH0         EQU  H'0000'
PWM1PRH1         EQU  H'0001'
PWM1PRH2         EQU  H'0002'
PWM1PRH3         EQU  H'0003'
PWM1PRH4         EQU  H'0004'
PWM1PRH5         EQU  H'0005'
PWM1PRH6         EQU  H'0006'
PWM1PRH7         EQU  H'0007'



;----- PWM1OFL Bits -----------------------------------------------------
PWM1OFL0         EQU  H'0000'
PWM1OFL1         EQU  H'0001'
PWM1OFL2         EQU  H'0002'
PWM1OFL3         EQU  H'0003'
PWM1OFL4         EQU  H'0004'
PWM1OFL5         EQU  H'0005'
PWM1OFL6         EQU  H'0006'
PWM1OFL7         EQU  H'0007'



;----- PWM1OFH Bits -----------------------------------------------------
PWM1OFH0         EQU  H'0000'
PWM1OFH1         EQU  H'0001'
PWM1OFH2         EQU  H'0002'
PWM1OFH3         EQU  H'0003'
PWM1OFH4         EQU  H'0004'
PWM1OFH5         EQU  H'0005'
PWM1OFH6         EQU  H'0006'
PWM1OFH7         EQU  H'0007'



;----- PWM1TMRL Bits -----------------------------------------------------
PWM1TMRL0        EQU  H'0000'
PWM1TMRL1        EQU  H'0001'
PWM1TMRL2        EQU  H'0002'
PWM1TMRL3        EQU  H'0003'
PWM1TMRL4        EQU  H'0004'
PWM1TMRL5        EQU  H'0005'
PWM1TMRL6        EQU  H'0006'
PWM1TMRL7        EQU  H'0007'



;----- PWM1TMRH Bits -----------------------------------------------------
PWM1TMRH0        EQU  H'0000'
PWM1TMRH1        EQU  H'0001'
PWM1TMRH2        EQU  H'0002'
PWM1TMRH3        EQU  H'0003'
PWM1TMRH4        EQU  H'0004'
PWM1TMRH5        EQU  H'0005'
PWM1TMRH6        EQU  H'0006'
PWM1TMRH7        EQU  H'0007'



;----- PWM1CON Bits -----------------------------------------------------
POL              EQU  H'0004'
OUT              EQU  H'0005'
OE               EQU  H'0006'
EN               EQU  H'0007'

PWM1MODE0        EQU  H'0002'
PWM1MODE1        EQU  H'0003'

PWM1POL          EQU  H'0004'
PWM1OUT          EQU  H'0005'
PWM1OE           EQU  H'0006'
PWM1EN           EQU  H'0007'

MODE0            EQU  H'0002'
MODE1            EQU  H'0003'


;----- PWM1INTCON Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM1PRIE         EQU  H'0000'
PWM1DCIE         EQU  H'0001'
PWM1PHIE         EQU  H'0002'
PWM1OFIE         EQU  H'0003'


;----- PWM1INTE Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM1PRIE         EQU  H'0000'
PWM1DCIE         EQU  H'0001'
PWM1PHIE         EQU  H'0002'
PWM1OFIE         EQU  H'0003'


;----- PWM1INTF Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM1PRIF         EQU  H'0000'
PWM1DCIF         EQU  H'0001'
PWM1PHIF         EQU  H'0002'
PWM1OFIF         EQU  H'0003'


;----- PWM1INTFLG Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM1PRIF         EQU  H'0000'
PWM1DCIF         EQU  H'0001'
PWM1PHIF         EQU  H'0002'
PWM1OFIF         EQU  H'0003'


;----- PWM1CLKCON Bits -----------------------------------------------------
PWM1CS0          EQU  H'0000'
PWM1CS1          EQU  H'0001'
PWM1PS0          EQU  H'0004'
PWM1PS1          EQU  H'0005'
PWM1PS2          EQU  H'0006'


CS0              EQU  H'0000'
CS1              EQU  H'0001'
PS0_PWM1CLKCON   EQU  H'0004'
PS1_PWM1CLKCON   EQU  H'0005'
PS2_PWM1CLKCON   EQU  H'0006'


;----- PWM1LDCON Bits -----------------------------------------------------
LDT              EQU  H'0006'
LDA              EQU  H'0007'

PWM1LDS0         EQU  H'0000'
PWM1LDS1         EQU  H'0001'

PWM1LDM          EQU  H'0006'
PWM1LD           EQU  H'0007'

LDS0             EQU  H'0000'
LDS1             EQU  H'0001'


;----- PWM1OFCON Bits -----------------------------------------------------
OFO              EQU  H'0004'

PWM1OFS0         EQU  H'0000'
PWM1OFS1         EQU  H'0001'
PWM1OFM0         EQU  H'0005'
PWM1OFM1         EQU  H'0006'

PWM1OFMC         EQU  H'0004'

OFS0             EQU  H'0000'
OFS1             EQU  H'0001'
OFM0             EQU  H'0005'
OFM1             EQU  H'0006'


;----- PWM2PHL Bits -----------------------------------------------------
PWM2PHL0         EQU  H'0000'
PWM2PHL1         EQU  H'0001'
PWM2PHL2         EQU  H'0002'
PWM2PHL3         EQU  H'0003'
PWM2PHL4         EQU  H'0004'
PWM2PHL5         EQU  H'0005'
PWM2PHL6         EQU  H'0006'
PWM2PHL7         EQU  H'0007'



;----- PWM2PHH Bits -----------------------------------------------------
PWM2PHH0         EQU  H'0000'
PWM2PHH1         EQU  H'0001'
PWM2PHH2         EQU  H'0002'
PWM2PHH3         EQU  H'0003'
PWM2PHH4         EQU  H'0004'
PWM2PHH5         EQU  H'0005'
PWM2PHH6         EQU  H'0006'
PWM2PHH7         EQU  H'0007'



;----- PWM2DCL Bits -----------------------------------------------------
PWM2DCL0         EQU  H'0000'
PWM2DCL1         EQU  H'0001'
PWM2DCL2         EQU  H'0002'
PWM2DCL3         EQU  H'0003'
PWM2DCL4         EQU  H'0004'
PWM2DCL5         EQU  H'0005'
PWM2DCL6         EQU  H'0006'
PWM2DCL7         EQU  H'0007'



;----- PWM2DCH Bits -----------------------------------------------------
PWM2DCH0         EQU  H'0000'
PWM2DCH1         EQU  H'0001'
PWM2DCH2         EQU  H'0002'
PWM2DCH3         EQU  H'0003'
PWM2DCH4         EQU  H'0004'
PWM2DCH5         EQU  H'0005'
PWM2DCH6         EQU  H'0006'
PWM2DCH7         EQU  H'0007'



;----- PWM2PRL Bits -----------------------------------------------------
PWM2PRL0         EQU  H'0000'
PWM2PRL1         EQU  H'0001'
PWM2PRL2         EQU  H'0002'
PWM2PRL3         EQU  H'0003'
PWM2PRL4         EQU  H'0004'
PWM2PRL5         EQU  H'0005'
PWM2PRL6         EQU  H'0006'
PWM2PRL7         EQU  H'0007'



;----- PWM2PRH Bits -----------------------------------------------------
PWM2PRH0         EQU  H'0000'
PWM2PRH1         EQU  H'0001'
PWM2PRH2         EQU  H'0002'
PWM2PRH3         EQU  H'0003'
PWM2PRH4         EQU  H'0004'
PWM2PRH5         EQU  H'0005'
PWM2PRH6         EQU  H'0006'
PWM2PRH7         EQU  H'0007'



;----- PWM2OFL Bits -----------------------------------------------------
PWM2OFL0         EQU  H'0000'
PWM2OFL1         EQU  H'0001'
PWM2OFL2         EQU  H'0002'
PWM2OFL3         EQU  H'0003'
PWM2OFL4         EQU  H'0004'
PWM2OFL5         EQU  H'0005'
PWM2OFL6         EQU  H'0006'
PWM2OFL7         EQU  H'0007'



;----- PWM2OFH Bits -----------------------------------------------------
PWM2OFH0         EQU  H'0000'
PWM2OFH1         EQU  H'0001'
PWM2OFH2         EQU  H'0002'
PWM2OFH3         EQU  H'0003'
PWM2OFH4         EQU  H'0004'
PWM2OFH5         EQU  H'0005'
PWM2OFH6         EQU  H'0006'
PWM2OFH7         EQU  H'0007'



;----- PWM2TMRL Bits -----------------------------------------------------
PWM2TMRL0        EQU  H'0000'
PWM2TMRL1        EQU  H'0001'
PWM2TMRL2        EQU  H'0002'
PWM2TMRL3        EQU  H'0003'
PWM2TMRL4        EQU  H'0004'
PWM2TMRL5        EQU  H'0005'
PWM2TMRL6        EQU  H'0006'
PWM2TMRL7        EQU  H'0007'



;----- PWM2TMRH Bits -----------------------------------------------------
PWM2TMRH0        EQU  H'0000'
PWM2TMRH1        EQU  H'0001'
PWM2TMRH2        EQU  H'0002'
PWM2TMRH3        EQU  H'0003'
PWM2TMRH4        EQU  H'0004'
PWM2TMRH5        EQU  H'0005'
PWM2TMRH6        EQU  H'0006'
PWM2TMRH7        EQU  H'0007'



;----- PWM2CON Bits -----------------------------------------------------
POL              EQU  H'0004'
OUT              EQU  H'0005'
OE               EQU  H'0006'
EN               EQU  H'0007'

PWM2MODE0        EQU  H'0002'
PWM2MODE1        EQU  H'0003'

PWM2POL          EQU  H'0004'
PWM2OUT          EQU  H'0005'
PWM2OE           EQU  H'0006'
PWM2EN           EQU  H'0007'

MODE0            EQU  H'0002'
MODE1            EQU  H'0003'


;----- PWM2INTCON Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM2PRIE         EQU  H'0000'
PWM2DCIE         EQU  H'0001'
PWM2PHIE         EQU  H'0002'
PWM2OFIE         EQU  H'0003'


;----- PWM2INTE Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM2PRIE         EQU  H'0000'
PWM2DCIE         EQU  H'0001'
PWM2PHIE         EQU  H'0002'
PWM2OFIE         EQU  H'0003'


;----- PWM2INTF Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM2PRIF         EQU  H'0000'
PWM2DCIF         EQU  H'0001'
PWM2PHIF         EQU  H'0002'
PWM2OFIF         EQU  H'0003'


;----- PWM2INTFLG Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM2PRIF         EQU  H'0000'
PWM2DCIF         EQU  H'0001'
PWM2PHIF         EQU  H'0002'
PWM2OFIF         EQU  H'0003'


;----- PWM2CLKCON Bits -----------------------------------------------------
PWM2CS0          EQU  H'0000'
PWM2CS1          EQU  H'0001'
PWM2PS0          EQU  H'0004'
PWM2PS1          EQU  H'0005'
PWM2PS2          EQU  H'0006'


CS0              EQU  H'0000'
CS1              EQU  H'0001'
PS0_PWM2CLKCON   EQU  H'0004'
PS1_PWM2CLKCON   EQU  H'0005'
PS2_PWM2CLKCON   EQU  H'0006'


;----- PWM2LDCON Bits -----------------------------------------------------
LDT              EQU  H'0006'
LDA              EQU  H'0007'

PWM2LDS0         EQU  H'0000'
PWM2LDS1         EQU  H'0001'

PWM2LDM          EQU  H'0006'
PWM2LD           EQU  H'0007'

LDS0             EQU  H'0000'
LDS1             EQU  H'0001'


;----- PWM2OFCON Bits -----------------------------------------------------
OFO              EQU  H'0004'

PWM2OFS0         EQU  H'0000'
PWM2OFS1         EQU  H'0001'
PWM2OFM0         EQU  H'0005'
PWM2OFM1         EQU  H'0006'

PWM2OFMC         EQU  H'0004'

OFS0             EQU  H'0000'
OFS1             EQU  H'0001'
OFM0             EQU  H'0005'
OFM1             EQU  H'0006'


;----- PWM3PHL Bits -----------------------------------------------------
PWM3PHL0         EQU  H'0000'
PWM3PHL1         EQU  H'0001'
PWM3PHL2         EQU  H'0002'
PWM3PHL3         EQU  H'0003'
PWM3PHL4         EQU  H'0004'
PWM3PHL5         EQU  H'0005'
PWM3PHL6         EQU  H'0006'
PWM3PHL7         EQU  H'0007'



;----- PWM3PHH Bits -----------------------------------------------------
PWM3PHH0         EQU  H'0000'
PWM3PHH1         EQU  H'0001'
PWM3PHH2         EQU  H'0002'
PWM3PHH3         EQU  H'0003'
PWM3PHH4         EQU  H'0004'
PWM3PHH5         EQU  H'0005'
PWM3PHH6         EQU  H'0006'
PWM3PHH7         EQU  H'0007'



;----- PWM3DCL Bits -----------------------------------------------------
PWM3DCL0         EQU  H'0000'
PWM3DCL1         EQU  H'0001'
PWM3DCL2         EQU  H'0002'
PWM3DCL3         EQU  H'0003'
PWM3DCL4         EQU  H'0004'
PWM3DCL5         EQU  H'0005'
PWM3DCL6         EQU  H'0006'
PWM3DCL7         EQU  H'0007'



;----- PWM3DCH Bits -----------------------------------------------------
PWM3DCH0         EQU  H'0000'
PWM3DCH1         EQU  H'0001'
PWM3DCH2         EQU  H'0002'
PWM3DCH3         EQU  H'0003'
PWM3DCH4         EQU  H'0004'
PWM3DCH5         EQU  H'0005'
PWM3DCH6         EQU  H'0006'
PWM3DCH7         EQU  H'0007'



;----- PWM3PRL Bits -----------------------------------------------------
PWM3PRL0         EQU  H'0000'
PWM3PRL1         EQU  H'0001'
PWM3PRL2         EQU  H'0002'
PWM3PRL3         EQU  H'0003'
PWM3PRL4         EQU  H'0004'
PWM3PRL5         EQU  H'0005'
PWM3PRL6         EQU  H'0006'
PWM3PRL7         EQU  H'0007'



;----- PWM3PRH Bits -----------------------------------------------------
PWM3PRH0         EQU  H'0000'
PWM3PRH1         EQU  H'0001'
PWM3PRH2         EQU  H'0002'
PWM3PRH3         EQU  H'0003'
PWM3PRH4         EQU  H'0004'
PWM3PRH5         EQU  H'0005'
PWM3PRH6         EQU  H'0006'
PWM3PRH7         EQU  H'0007'



;----- PWM3OFL Bits -----------------------------------------------------
PWM3OFL0         EQU  H'0000'
PWM3OFL1         EQU  H'0001'
PWM3OFL2         EQU  H'0002'
PWM3OFL3         EQU  H'0003'
PWM3OFL4         EQU  H'0004'
PWM3OFL5         EQU  H'0005'
PWM3OFL6         EQU  H'0006'
PWM3OFL7         EQU  H'0007'



;----- PWM3OFH Bits -----------------------------------------------------
PWM3OFH0         EQU  H'0000'
PWM3OFH1         EQU  H'0001'
PWM3OFH2         EQU  H'0002'
PWM3OFH3         EQU  H'0003'
PWM3OFH4         EQU  H'0004'
PWM3OFH5         EQU  H'0005'
PWM3OFH6         EQU  H'0006'
PWM3OFH7         EQU  H'0007'



;----- PWM3TMRL Bits -----------------------------------------------------
PWM3TMRL0        EQU  H'0000'
PWM3TMRL1        EQU  H'0001'
PWM3TMRL2        EQU  H'0002'
PWM3TMRL3        EQU  H'0003'
PWM3TMRL4        EQU  H'0004'
PWM3TMRL5        EQU  H'0005'
PWM3TMRL6        EQU  H'0006'
PWM3TMRL7        EQU  H'0007'



;----- PWM3TMRH Bits -----------------------------------------------------
PWM3TMRH0        EQU  H'0000'
PWM3TMRH1        EQU  H'0001'
PWM3TMRH2        EQU  H'0002'
PWM3TMRH3        EQU  H'0003'
PWM3TMRH4        EQU  H'0004'
PWM3TMRH5        EQU  H'0005'
PWM3TMRH6        EQU  H'0006'
PWM3TMRH7        EQU  H'0007'



;----- PWM3CON Bits -----------------------------------------------------
POL              EQU  H'0004'
OUT              EQU  H'0005'
OE               EQU  H'0006'
EN               EQU  H'0007'

PWM3MODE0        EQU  H'0002'
PWM3MODE1        EQU  H'0003'

PWM3POL          EQU  H'0004'
PWM3OUT          EQU  H'0005'
PWM3OE           EQU  H'0006'
PWM3EN           EQU  H'0007'

MODE0            EQU  H'0002'
MODE1            EQU  H'0003'


;----- PWM3INTCON Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM3PRIE         EQU  H'0000'
PWM3DCIE         EQU  H'0001'
PWM3PHIE         EQU  H'0002'
PWM3OFIE         EQU  H'0003'


;----- PWM3INTE Bits -----------------------------------------------------
PRIE             EQU  H'0000'
DCIE             EQU  H'0001'
PHIE             EQU  H'0002'
OFIE             EQU  H'0003'

PWM3PRIE         EQU  H'0000'
PWM3DCIE         EQU  H'0001'
PWM3PHIE         EQU  H'0002'
PWM3OFIE         EQU  H'0003'


;----- PWM3INTF Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM3PRIF         EQU  H'0000'
PWM3DCIF         EQU  H'0001'
PWM3PHIF         EQU  H'0002'
PWM3OFIF         EQU  H'0003'


;----- PWM3INTFLG Bits -----------------------------------------------------
PRIF             EQU  H'0000'
DCIF             EQU  H'0001'
PHIF             EQU  H'0002'
OFIF             EQU  H'0003'

PWM3PRIF         EQU  H'0000'
PWM3DCIF         EQU  H'0001'
PWM3PHIF         EQU  H'0002'
PWM3OFIF         EQU  H'0003'


;----- PWM3CLKCON Bits -----------------------------------------------------
PWM3CS0          EQU  H'0000'
PWM3CS1          EQU  H'0001'
PWM3PS0          EQU  H'0004'
PWM3PS1          EQU  H'0005'
PWM3PS2          EQU  H'0006'


CS0              EQU  H'0000'
CS1              EQU  H'0001'
PS0_PWM3CLKCON   EQU  H'0004'
PS1_PWM3CLKCON   EQU  H'0005'
PS2_PWM3CLKCON   EQU  H'0006'


;----- PWM3LDCON Bits -----------------------------------------------------
LDT              EQU  H'0006'
LDA              EQU  H'0007'

PWM3LDS0         EQU  H'0000'
PWM3LDS1         EQU  H'0001'

PWM3LDM          EQU  H'0006'
PWM3LD           EQU  H'0007'

LDS0             EQU  H'0000'
LDS1             EQU  H'0001'


;----- PWM3OFCON Bits -----------------------------------------------------
OFO              EQU  H'0004'

PWM3OFS0         EQU  H'0000'
PWM3OFS1         EQU  H'0001'
PWM3OFM0         EQU  H'0005'
PWM3OFM1         EQU  H'0006'

PWM3OFMC         EQU  H'0004'

OFS0             EQU  H'0000'
OFS1             EQU  H'0001'
OFM0             EQU  H'0005'
OFM1             EQU  H'0006'


;----- STATUS_SHAD Bits -----------------------------------------------------
C_SHAD           EQU  H'0000'
DC_SHAD          EQU  H'0001'
Z_SHAD           EQU  H'0002'



;==========================================================================
;
;       RAM Definitions
;
;==========================================================================
       __MAXRAM  H'0FFF'
       __BADRAM  H'000D'-H'0010'
       __BADRAM  H'0014'
       __BADRAM  H'001D'-H'001F'
       __BADRAM  H'008D'-H'0090'
       __BADRAM  H'0094'
       __BADRAM  H'010D'-H'0110'
       __BADRAM  H'0113'-H'0114'
       __BADRAM  H'011A'-H'011C'
       __BADRAM  H'011E'-H'011F'
       __BADRAM  H'018D'-H'0190'
       __BADRAM  H'0198'
       __BADRAM  H'01A0'-H'01EF'
       __BADRAM  H'020D'-H'021F'
       __BADRAM  H'0220'-H'026F'
       __BADRAM  H'028D'-H'029F'
       __BADRAM  H'02A0'-H'02EF'
       __BADRAM  H'030D'-H'031F'
       __BADRAM  H'0320'-H'036F'
       __BADRAM  H'038D'-H'0390'
       __BADRAM  H'0394'-H'039F'
       __BADRAM  H'03A0'-H'03EF'
       __BADRAM  H'040C'-H'041F'
       __BADRAM  H'0420'-H'046F'
       __BADRAM  H'048C'-H'049F'
       __BADRAM  H'04A0'-H'04EF'
       __BADRAM  H'050C'-H'051F'
       __BADRAM  H'0520'-H'056F'
       __BADRAM  H'058C'-H'059F'
       __BADRAM  H'05A0'-H'05EF'
       __BADRAM  H'060C'-H'061F'
       __BADRAM  H'0620'-H'066F'
       __BADRAM  H'068C'-H'0690'
       __BADRAM  H'0696'-H'069F'
       __BADRAM  H'06A0'-H'06EF'
       __BADRAM  H'070C'-H'071F'
       __BADRAM  H'0720'-H'076F'
       __BADRAM  H'078C'-H'079F'
       __BADRAM  H'07A0'-H'07EF'
       __BADRAM  H'080C'-H'081F'
       __BADRAM  H'0820'-H'086F'
       __BADRAM  H'088C'-H'089F'
       __BADRAM  H'08A0'-H'08EF'
       __BADRAM  H'090C'-H'091F'
       __BADRAM  H'0920'-H'096F'
       __BADRAM  H'098C'-H'099F'
       __BADRAM  H'09A0'-H'09EF'
       __BADRAM  H'0A0C'-H'0A1F'
       __BADRAM  H'0A20'-H'0A6F'
       __BADRAM  H'0A8C'-H'0A9F'
       __BADRAM  H'0AA0'-H'0AEF'
       __BADRAM  H'0B0C'-H'0B1F'
       __BADRAM  H'0B20'-H'0B6F'
       __BADRAM  H'0B8C'-H'0B9F'
       __BADRAM  H'0BA0'-H'0BEF'
       __BADRAM  H'0C0C'-H'0C1F'
       __BADRAM  H'0C20'-H'0C6F'
       __BADRAM  H'0C8C'-H'0C9F'
       __BADRAM  H'0CA0'-H'0CEF'
       __BADRAM  H'0D0C'-H'0D1F'
       __BADRAM  H'0D20'-H'0D6F'
       __BADRAM  H'0D8C'-H'0D8D'
       __BADRAM  H'0DC1'-H'0DEF'
       __BADRAM  H'0E0C'-H'0E1F'
       __BADRAM  H'0E20'-H'0E6F'
       __BADRAM  H'0E8C'-H'0E9F'
       __BADRAM  H'0EA0'-H'0EEF'
       __BADRAM  H'0F0C'-H'0F1F'
       __BADRAM  H'0F20'-H'0F6F'
       __BADRAM  H'0F8C'-H'0FE3'
       __BADRAM  H'0FEC'

;==========================================================================
;
;       Configuration Bits
;
;   NAME            Address
;   CONFIG1           8007h
;   CONFIG2           8008h
;
;==========================================================================

; The following is an assignment of address values for all of the
; configuration registers for the purpose of table reads
_CONFIG1        EQU  H'8007'
_CONFIG2        EQU  H'8008'

;----- CONFIG1 Options --------------------------------------------------
_FOSC_INTOSC         EQU  H'3FFC'; INTOSC oscillator; I/O function on CLKIN pin
_FOSC_ECL            EQU  H'3FFD'; ECL, External Clock, Low Power Mode (0-0.5 MHz); device clock supplied to CLKIN pin
_FOSC_ECM            EQU  H'3FFE'; ECM, External Clock, Medium Power Mode (0.5-4 MHz); device clock supplied to CLKIN pin
_FOSC_ECH            EQU  H'3FFF'; ECH, External Clock, High Power Mode (4-32 MHz); device clock supplied to CLKIN pin

_WDTE_OFF            EQU  H'3FE7'; WDT disabled
_WDTE_SWDTEN         EQU  H'3FEF'; WDT controlled by the SWDTEN bit in the WDTCON register
_WDTE_NSLEEP         EQU  H'3FF7'; WDT enabled while running and disabled in Sleep
_WDTE_ON             EQU  H'3FFF'; WDT enabled

_PWRTE_ON            EQU  H'3FDF'; PWRT enabled
_PWRTE_OFF           EQU  H'3FFF'; PWRT disabled

_MCLRE_OFF           EQU  H'3FBF'; MCLR/VPP pin function is digital input
_MCLRE_ON            EQU  H'3FFF'; MCLR/VPP pin function is MCLR

_CP_ON               EQU  H'3F7F'; Program memory code protection is enabled
_CP_OFF              EQU  H'3FFF'; Program memory code protection is disabled

_BOREN_OFF           EQU  H'39FF'; Brown-out Reset disabled
_BOREN_SBODEN        EQU  H'3BFF'; Brown-out Reset controlled by the SBOREN bit in the BORCON register
_BOREN_NSLEEP        EQU  H'3DFF'; Brown-out Reset enabled while running and disabled in Sleep
_BOREN_ON            EQU  H'3FFF'; Brown-out Reset enabled

_CLKOUTEN_ON         EQU  H'37FF'; CLKOUT function is enabled on the CLKOUT pin
_CLKOUTEN_OFF        EQU  H'3FFF'; CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin

;----- CONFIG2 Options --------------------------------------------------
_WRT_ALL             EQU  H'3FFC'; 000h to 7FFh write protected, no addresses may be modified by EECON control
_WRT_HALF            EQU  H'3FFD'; 000h to 3FFh write protected, 400h to 7FFh may be modified by EECON control
_WRT_BOOT            EQU  H'3FFE'; 000h to 1FFh write protected, 200h to 7FFh may be modified by EECON control
_WRT_OFF             EQU  H'3FFF'; Write protection off

_PLLEN_OFF           EQU  H'3EFF'; 4x PLL disabled
_PLLEN_ON            EQU  H'3FFF'; 4x PLL enabled

_STVREN_OFF          EQU  H'3DFF'; Stack Overflow or Underflow will not cause a Reset
_STVREN_ON           EQU  H'3FFF'; Stack Overflow or Underflow will cause a Reset

_BORV_HI             EQU  H'3BFF'; Brown-out Reset Voltage (Vbor), high trip point selected.
_BORV_LO             EQU  H'3FFF'; Brown-out Reset Voltage (Vbor), low trip point selected.
_BORV_19             EQU  H'3FFF'; Brown-out Reset Voltage (Vbor), low trip point selected.

_LPBOREN_ON          EQU  H'37FF'; LPBOR is enabled
_LPBOREN_OFF         EQU  H'3FFF'; LPBOR is disabled

_LVP_OFF             EQU  H'1FFF'; High-voltage on MCLR/VPP must be used for programming
_LVP_ON              EQU  H'3FFF'; Low-voltage programming enabled

;----- DEVID Equates --------------------------------------------------
_DEVID1          EQU  H'8006'

;----- IDLOC Equates --------------------------------------------------
_IDLOC0          EQU  H'8000'
_IDLOC1          EQU  H'8001'
_IDLOC2          EQU  H'8002'
_IDLOC3          EQU  H'8003'

        LIST
