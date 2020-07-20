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