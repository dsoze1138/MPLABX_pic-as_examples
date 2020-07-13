@if "%1."=="." goto End
@pushd %1
@echo Cleaning folder: %1
@if exist html              rmdir /s /q html
@if exist nbproject\private rmdir /s /q nbproject\private
@if exist debug             rmdir /s /q debug
@if exist build             rmdir /s /q build
@if exist nbuild            rmdir /s /q nbuild
@if exist dist              rmdir /s /q dist
@if exist ndist             rmdir /s /q ndist
@if exist disassembly       rmdir /s /q disassembly
@if exist nbactions.xml     del   /f /q nbactions.xml
@if exist funclist          del   /f /q funclist
@if exist nbproject\Package-*.bash del   /f /q nbproject\Package-*.bash
@if exist nbproject\Makefile-* del   /f /q nbproject\Makefile-*
@popd
:End
