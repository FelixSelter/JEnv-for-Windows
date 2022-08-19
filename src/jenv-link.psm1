function Invoke-Link {
    param (
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$executable
    )

    if ($help) {
        Write-Host '"jenv link" <executable>'
        Write-Host "With this command you can create shortcuts for executables inside JAVA_HOME"
        Write-Host '<executable> is the name of the binary file for example "javac" or "javaw"'
        Write-Host 'For example enable javac with: "jenv link javac"'
        Write-Host 'List all registered java versions with "jenv list"'
        return
    }

    $payload = @'
        @echo off
        for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

        if exist "%var%/bin/{0}.exe" (
            "%var%/bin/{0}.exe" %*
        ) else (
            echo There was an error:
            echo %var%
        )
'@ -f $executable

    Set-Content ((get-item $PSScriptRoot).parent.fullname + "/$executable.bat") $payload

}