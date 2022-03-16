@echo off

rem # Check if powershell is in path
where /q pwsh.exe
IF ERRORLEVEL 1 (
    where /q powershell.exe
    IF ERRORLEVEL 1 (
        echo Neither pwsh.exe nor powershell.exe was found in your path.
        echo Please install powershell it is required
        exit /B
    ) ELSE (
        set ps=powershell.exe
    )
) ELSE (
    set ps=pwsh.exe
)

rem ps is the installed powershell
%ps% -executionpolicy remotesigned -File  %~dp0/src/jenv.ps1 %* --output

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
