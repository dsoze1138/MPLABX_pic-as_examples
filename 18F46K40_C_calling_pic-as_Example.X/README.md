# Example calling an assembly language function from XC8
-----------------------------------

Example for PIC18F46K40 that shows a way to implement  calling a function implemented in pic-as(v2.xx) assembly language from a XC8 C language application.

The documentation found in XC8 fails to describe the calling conventions that the compiler actually uses when calling a function.



This project is an example of what seems to work but it is doubtful if it is a complete and correct description of how the compiler creates the parameter list for all types of parameters.



This is because when the first parameter is a byte it is passed in the WREG and not stored on the compiled stack. It's unknown if there are any other "special" things that XC8 does with function prameters.