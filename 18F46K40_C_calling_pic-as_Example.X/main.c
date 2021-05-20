/*
 * File:   main.c
 * Author: dan1138
 * Target: PIC18F46K40
 *
 * Created on May 16, 2021, 11:57 AM
 * 
 * Description:
 * 
 *  Proof of concept of how to pass two byte parameters
 *  to ab assembly language source file form an XC8 v2.31
 *  C language program.
 * 
 * Required files:
 * 
 *  func.S
 */
#pragma config FEXTOSC = OFF, RSTOSC = HFINTOSC_64MHZ, CLKOUTEN = OFF, CSWEN = ON
#pragma config FCMEN = ON, MCLRE = EXTMCLR, PWRTE = OFF, LPBOREN = OFF
#pragma config BOREN = SBORDIS, BORV = VBOR_2P45, ZCD = OFF, PPS1WAY = OFF
#pragma config STVREN = ON, XINST = OFF, WDTCPS = WDTCPS_31, WDTE = OFF
#pragma config WDTCWS = WDTCWS_7, WDTCCS = SC
#pragma config WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
#pragma config WRTC = OFF, WRTB = OFF, WRTD = OFF
#pragma config SCANE = ON, LVP = OFF, CP = OFF, CPD = OFF
#pragma config EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
#pragma config EBTRB = OFF

#include <xc.h>

extern void func(unsigned char arg1, unsigned char arg2);

void main(void) {
    for(;;) {
        func(1,2);
    }
}