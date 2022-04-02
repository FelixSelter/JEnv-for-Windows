@echo off
for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

if exist "%var%/bin/java.exe" (
    "%var%/bin/java.exe" %*
) else (
    echo There was an error:
    echo %var%
)