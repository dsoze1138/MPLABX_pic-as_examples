# Examples from XC8-PIC-Assembler-UG-for-EE-50002994A.pdf
---------------------------------------------------------

This repository contains assembly language source code 
examples found in the Microchip documentation for using 
the pic-as(v2.20) tool chain.

The code has been corrected and expanded where necessary 
so that these projects will build with MPLABX v5.40

~~Note that MPLABX v5.40 is broken when trying to use symbolic
debugging with the pic-as(v2.20) tool chain.~~

~~Projects are included in this repository that will get 
MPLABX v5.40 to start a debug session with the symbolic 
debug information loaded. Using them is a finicky 
process.~~

## Date: 2020-July-19

Microchip has pushed an update to the pic-as(v2.20) tool chain 
in MPLABX v5.40. 

Specifically the plugin for the toolchainPICASM stepped from 
version 1.0.0 to 1.0.1

What this plugin does is "Adds to MPLAB the ability to create projects using the PIC Assembler."

So at this point the workaround I have been using is no longer necessary.

Those project have been removed.

I may expand these notes in the future to have a step 
by step guide on how to use them.

## Date: 2020-July-25

Added example for PIC10F200

## Date: 2020-August-5

Added example for PIC10F320

## Date: 2020-August-6

Added example of port of PIC18F2550 code from MPASM to pic-as(v2.20)

## Date: 2020-August-14

Added example for PIC10F206

## Date: 2020-August-24

With base line PIC controllers there is a bug in the pic-as(v2.xx) toolchain.

The workaround for the bug is to add: "-Wl,-DCODE=2" to the Additional options field, in the pic-as Linker category of the project properties.

See: https://www.microchip.com/forums/FindPost/1150913

## Date: 2021-September-28

Add an example for the PIC16F1503.

## Date: 2022-January-10

Modify 10F200_Example to test skip macros.

## Date: 2022-October-20

Add PIC16F877A example to show a method using the HC-SR04 ultrasonic range finder with an HD44780 LCD character display module.

