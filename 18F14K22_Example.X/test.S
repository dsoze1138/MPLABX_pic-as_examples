; 
; Code example based on section 3.  A Basic Example For PIC18 Devices
;
; From document: http://ww1.microchip.com/downloads/en/DeviceDoc/XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-Map=test.map -Wl,-presetVec=0h
;
    PROCESSOR 18F14K22

#include <xc.inc>

; CONFIG1H
  CONFIG  FOSC = IRC            ; Oscillator Selection bits (Internal RC oscillator)
;
; Because xc.inc defines the PLLEN symbol the CONFIG syntax fails.
;
; Microchip wants xc.inc "included" before the config directives.
;
; So here is a workaround hack:
#undef PLLEN = OFF
;
  CONFIG  PLLEN = OFF           ; 4 X PLL Enable bit (PLL is under software control)
;
; This define is from the pic18f14k22.inc file, line 4139:
#define PLLEN BANKMASK(OSCTUNE), 6, a
;
  CONFIG  PCLKEN = ON           ; Primary Clock Enable bit (Primary clock enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 19             ; Brown Out Reset Voltage bits (VBOR set to 1.9 V nominal)

; CONFIG2H
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  HFOFST = ON           ; HFINTOSC Fast Start-up bit (HFINTOSC starts clocking the CPU without waiting for the oscillator to stablize.)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled, RA3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  BBSIZ = OFF           ; Boot Block Size Select bit (1kW boot block size)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block not protected from table reads executed in other blocks)

;objects in common (Access bank) memory 

    PSECT   udata_acs
    global  max
    global  tmp
max:
    DS      1       ;reserve 1 byte for max
tmp:
    DS      1       ;1 byte for tmp

;this must be linked to the reset vector

    PSECT   resetVec,class=CODE,reloc=2
resetVec:
    goto    main

/* find the highest PORTA value read, storing this into the object max */

    PSECT   code
main:
    clrf    max,c       ;starting point
    movff   max,ANSEL   ;write 0 to select digital input for port
    movff   max,ANSELH  ;write 0 to select digital input for port
loop:
    movff   PORTA,tmp   ;read and store the port value
    movf    tmp,w,c     ;is this value larger than max?
    subwf   max,w,c
    bc      loop        ;no - read again
    movff   tmp,max     ;yes - record this new high value
    goto    loop        ;read again
    END     resetVec
