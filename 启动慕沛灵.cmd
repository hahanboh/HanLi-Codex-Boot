@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\Start.ps1" -Theme mupeiling %*
if errorlevel 1 pause
