@rem This script cleans up after MPLABX or MPLAB 8.92 
@rem development environments have been use to build 
@rem a project in a folder.
@rem
@rem When creating an MPLAB v8.92 folder use ".8" as 
@rem the last two character of the folder name.
@rem
@rem This script can be used with drag-and-drop or
@rem invoked from a script like:
@rem
@rem @FOR /F  %%i IN ('dir /b *.x') DO @call CleanDir.cmd %%i NoPause
@rem @FOR /F  %%i IN ('dir /b *.8') DO @call CleanDir.cmd %%i NoPause
@rem @pause
@rem
@if "%1."=="." goto End
@set FOLDER2CLEAN=%1
@set LAST_CHARS=%FOLDER2CLEAN:~-2%
@pushd %FOLDER2CLEAN%
@echo Cleaning folder: %1
@if "%LAST_CHARS%."==".8." goto Clean8
@if exist html              rmdir /s /q html
@if exist nbproject\private rmdir /s /q nbproject\private
@if exist debug             rmdir /s /q debug
@if exist build             rmdir /s /q build
@if exist nbuild            rmdir /s /q nbuild
@if exist dist              rmdir /s /q dist
@if exist ndist             rmdir /s /q ndist
@if exist disassembly       rmdir /s /q disassembly
@if exist .generated_files  rmdir /s /q .generated_files
@if exist nbactions.xml     del   /f /q nbactions.xml
@if exist funclist          del   /f /q funclist
@if exist nbproject\Package-*.bash del   /f /q nbproject\Package-*.bash
@if exist nbproject\Makefile-* del   /f /q nbproject\Makefile-*
@if exist *.lst             del   /f /q *.lst
@if exist *.err             del   /f /q *.err
@if exist *.map             del   /f /q *.map
@goto CleanDone
:Clean8
@if exist funclist          del   /f /q funclist
@if exist *.cof             del   /f /q *.cof
@if exist *.hxl             del   /f /q *.hxl
@if exist *.map             del   /f /q *.map
@if exist *.mcs             del   /f /q *.mcs
@if exist *.obj             del   /f /q *.obj
@if exist *.rlf             del   /f /q *.rlf
@if exist *.sdb             del   /f /q *.sdb
@if exist *.sym             del   /f /q *.sym
@if exist *.p1              del   /f /q *.p1 
@if exist *.pre             del   /f /q *.pre
@if exist *.lst             del   /f /q *.lst
@if exist *.hex             del   /f /q *.hex
@if exist *.err             del   /f /q *.err
@if exist *.o               del   /f /q *.o
@if exist *.d               del   /f /q *.d
@if exist *.cmf             del   /f /q *.cmf
@if exist startup.as        del   /f /q startup.as
@FOR /F  %%i IN ('dir /b *.mcp') DO @if exist %%~ni.as del   /f /q %%~ni.as
:CleanDone
@popd
@set FOLDER2CLEAN=
@set LAST_CHARS=
@if not "%2."=="NoPause." pause
:End
