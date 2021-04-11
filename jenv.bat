@echo off


set permanently=FALSE
set argC=0
for %%x in (%*) do Set /A argC+=1

if %argC% LSS 1 goto help

if "%1" EQU "add" goto add
if "%1" EQU "list" goto list
if "%1" EQU "use" goto use
if "%1" EQU "remove" goto remove
if "%1" EQU "change" goto change

if "%1" EQU "help" goto help
if "%1" EQU "-h" goto help
if "%1" EQU "--help" goto help
if "%1" EQU "-?" goto help
if "%1" EQU "/?" goto help


:add
	if %argC% NEQ 3 echo "Systax error: jenv add <name> <javaPath to JAVA_HOME>"

	(echo %2^|%3)>>"%~dp0jenv.config"
	goto exit

:list
	FOR /F "usebackq" %%i in ("%~dp0jenv.config") DO echo %%i
	goto exit

:use
	if %argC% NEQ 2 echo "Systax error: jenv use <name>"
	set toUse=%2

rem need local to wait for the for loop vars
setlocal EnableDelayedExpansion 
rem needs while loop but cant use goto without breaking the for loop. So a sub-process is used
FOR /F "usebackq" %%i in ("%~dp0jenv.config") DO set line=%%i& call :for_loop 
goto for_end
:for_loop
	set javaPath=!line!

	:while_loop
		set prevjavaPath=!javaPath!
		set javaPath=!javaPath:*^|=!
		if !javaPath! EQU !prevjavaPath! goto while_end
		goto while_loop
	:while_end

	set name=!line:^|%javaPath%=!
	if %name% EQU %toUse% set success=%javaPath%
	goto exit

:for_end
	
	rem success is the retrieved path of the name
	if defined success (
	
		for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKCU\Environment" /v "Path" 2^>nul') do if /I "%%N" == "Path" call set "UserPath=%%P"
		call set tempPath=%%UserPath:%java_home%=%success:~1,-1%%%
		
		rem loop to access local vars in gloabl enviroment
		for /F "delims=" %%E in (""!tempPath!"") do (
			endlocal
			
			rem use powershell and not setx to bypass the path limit
			if %permanently% == TRUE powershell.exe "[Environment]::SetEnvironmentVariable('path','%%~E','User');" 
			
			set path=%%~E

		)
		
		if %permanently% == TRUE (
				setx JAVA_HOME "%success:~1,-1%"
				set permanently=FALSE
		)
				set JAVA_HOME=%success:~1,-1%
		
		
		echo Changed to %2
		
		
		
	) else (
		echo "%2 was not found. Please register the name via jenv add <name> <javaPath to JAVA_HOME>"
	)

	goto exit

:change
	set permanently=TRUE
	goto use
	goto exit

:help
	echo "jenv add <name> <javaPath to JAVA_HOME>" adds a new java version
	echo "jenv use <name>" changes the java_home and path for the current session
	echo "jenv change <name>" changes the java_home and path permanently

:exit
