; 
; Code example from section 3.  A Basic Example For PIC18 Devices
;
; From document: http://ww1.microchip.com/downloads/en/DeviceDoc/XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
;
; Add this line in the project properties box, pic-as Global Options -> Additional options: 
;   -Wl,-Map=test.map -Wl,-presetVec=0h
;
    PROCESSOR 18F47K42

#include <xc.inc>

// configuration word 1
 CONFIG FEXTOSC=XT          // crystal oscillator
 CONFIG RSTOSC=EXTOSC       // EXTOSC operating per FEXTOSC bits
 CONFIG CLKOUTEN=OFF        // CLKOUT function is disabled
 CONFIG PR1WAY=ON           // PRLOCK bit can be cleared and set only once
 CONFIG CSWEN=ON            // Writing to NOSC and NDIV is allowed
 CONFIG FCMEN=ON            // Fail-Safe Clock Monitor enabled
// configuration word 2
 CONFIG MCLRE=EXTMCLR       // If LVP=0, MCLR pin is MCLR; If LVP=1, RE3 pin function is MCLR
 CONFIG PWRTS=PWRT_OFF      // PWRT is disabled
 CONFIG MVECEN=OFF          // Vector table isn't used to prioritize interrupts
 CONFIG IVT1WAY=ON          // IVTLOCK bit can be cleared and set only once
 CONFIG LPBOREN=OFF         // ULPBOR disabled
 CONFIG BOREN=SBORDIS       // Brown-out Reset enabled, SBOREN bit is ignored
 CONFIG BORV=VBOR_2P45      // Brown-out Reset Voltage (VBOR) set to 2.45V
 CONFIG ZCD=OFF             // ZCD disabled, enable by setting the ZCDSEN bit of ZCDCON
 CONFIG PPS1WAY=ON          // PPSLOCK cleared/set only once; PPS locked after clear/set cycle
 CONFIG STVREN=ON           // Stack full/underflow will cause Reset
 CONFIG DEBUG=OFF           // Background debugger disabled
 CONFIG XINST=OFF           // Extended Instruction Set and Indexed Addressing Mode disabled
// configuration word 3
 CONFIG WDTCPS=WDTCPS_31    // Divider ratio 1:65536; software control of WDTPS
 CONFIG WDTE=OFF            // WDT Disabled; SWDTEN is ignored
 CONFIG WDTCWS=WDTCWS_7     // window open 100%; software control; keyed access not required
 CONFIG WDTCCS=SC           // Software Control
// configuration word 4
 CONFIG BBSIZE=BBSIZE_512   // Boot Block size is 512 words
 CONFIG BBEN=OFF            // Boot block disabled
 CONFIG SAFEN=OFF           // SAF disabled
 CONFIG WRTAPP=OFF          // Application Block not write protected
 CONFIG WRTB=OFF            // Configuration registers (300000-30000Bh) not write-protected
 CONFIG WRTC=OFF            // Boot Block (000000-0007FFh) not write-protected
 CONFIG WRTD=OFF            // Data EEPROM not write-protected
 CONFIG WRTSAF=OFF          // SAF not Write Protected
 CONFIG LVP=ON              // Low voltage programming enabled, MCLR pin, MCLRE ignored
// configuration word 5
 CONFIG CP=OFF              // PFM and Data EEPROM code protection disabled

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
    movff   max,ANSELA  ;write 0 to select digital input for port
loop:
    movff   PORTA,tmp   ;read and store the port value
    movf    tmp,w,c     ;is this value larger than max?
    subwf   max,w,c
    bc      loop        ;no - read again
    movff   tmp,max     ;yes - record this new high value
    goto    loop        ;read again
    END     resetVec
