function Invoke-List {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help
    )

    if ($help) {
        Write-Host '"jenv list"'
        Write-Host "This command will display every added java version as well as its name"
        Write-Host 'You have to add java versions with "jenv add"'
        Write-Host 'Then you can set them with various commands like "jenv use" or "jenv change"'
        Write-Host "This command will also tell you every local JEnv that you specified"
        Write-Host 'You can tell JEnv that it should always use jdk8 on the desktop with "jenv local"'
        return
    }

    Write-Host "All avaible versions of java"
    Write-Host ($config.jenvs | Format-Table | Out-String)
    Write-Host "All locally specified versions"
    Write-Host ($config.locals | Format-Table | Out-String)

}