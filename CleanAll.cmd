@if not exist *.x goto NoMPLABX
@FOR /F  %%i IN ('dir /b *.x') DO @call CleanDir.cmd %%i NoPause
:NoMPLABX
@if not exist *.8 goto NoMPLAB8
@FOR /F  %%i IN ('dir /b *.8') DO @call CleanDir.cmd %%i NoPause
:NoMPLAB8
@pause