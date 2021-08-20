@echo off
Powershell.exe -executionpolicy remotesigned -File  jenv.ps1 %* -o

if exist jenv.home.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.home.tmp) DO (
        set JAVA_HOME=%%x
    )
    del -f jenv.home.tmp
)

if exist jenv.path.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.path.tmp) DO (
        set path=%%x
    )
    del -f jenv.path.tmp
)