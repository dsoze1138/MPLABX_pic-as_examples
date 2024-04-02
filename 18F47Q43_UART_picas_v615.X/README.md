# PIC18F47Q43 silicon bug PUSHL
-----------------------------------

The PIC18F47Q43 has a silicon bug when the extended instruction set PUSHL opcode executes.

The code here implements a unit test of all PUSHL opcodes using the DM164150 Curiosity Nano for test hardware.

The test workstation is a Windows 10-pro, MPLABX v6.15, pic-as from XC8 v2.45.

See: https://forum.microchip.com/s/topic/a5CV40000000bxFMAQ/t394614

Note that this opcode works with the simulator it only fails in the real hardware.

See transcript for: [Case_01431152](Case_01431152\Case_01431152.html) .