@echo off

cd %~dp0tools\zxlikepascal
if errorlevel 1 exit /B 1

zxlikepascal %~dp0game.pas "23900" -a
if errorlevel 1 exit /B 1

cd %~dp0
if errorlevel 1 exit /B 1

tools\sjasmplus\sjasmplus --sld=game.sld --syntax=af --lst=game.lst --dirbol --fullpath game.asm
if errorlevel 1 exit /B 1
