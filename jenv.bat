@echo off

Powershell.exe -executionpolicy remotesigned -File  %~dp0/src/jenv.ps1 %*