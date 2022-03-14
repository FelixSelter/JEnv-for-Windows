@echo off

rem #TODO: Check if powershell.exe is in path
Powershell.exe -executionpolicy remotesigned -File  %~dp0/src/jenv.ps1 %* --output

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

if exist jenv.use.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.use.tmp) DO (
        set JENVUSE=%%x
    )
    del -f jenv.use.tmp
)