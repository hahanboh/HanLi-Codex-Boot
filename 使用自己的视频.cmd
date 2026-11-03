@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\Start.ps1" -Theme custom %*
if errorlevel 1 pause
