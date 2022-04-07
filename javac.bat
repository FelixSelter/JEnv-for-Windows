@echo off
for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

if exist "%var%/bin/javac.exe" (
    "%var%/bin/javac.exe" %*
) else (
    echo There was an error:
    echo %var%
)