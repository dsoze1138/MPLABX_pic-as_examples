# Examples PIC10F202
--------------------

Example for PIC10F202 that show one way to build 
an assembly language project for a base-line PIC 
using multiple source files.

Note: The table size used is too large. It consumes 
all of the available entry points for callable 
functions. For base-line PIC controllers 
that need tables at the maximum size of 256 
elements must use devices with more that 512 words 
of instruction code space memory.

This code does implement a table with 256 elements 
in a 10F202 controller with just 512 words of 
instruction code space memory. The issue is that 
the main application code has no way to add 
another callable function.
