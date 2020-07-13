@FOR /F  %%i IN ('dir /b *.x') DO @call CleanDir.cmd %%i
@pause