function Invoke-Use {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv use <name>"'
        Write-Host 'With this command you set your JAVA_HOME and the version of java to be used by your current shell session.' 
        Write-Host '<name> is the alias you asigned to the path with "jenv add <name> <path>"'    
        Write-Host Careful this overwrittes "jenv local"
    }
    else {

        # Check if specified JEnv is avaible
        $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
        if ($null -eq $jenv) {
            Write-Host Theres no JEnv with name $name Consider using "jenv list"
            return
        }
        else {
            $Env:JAVA_HOME = $jenv.path # Set for powershell users
            Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
            Set-Content -path "jenv.use.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
            Write-Host JEnv changed for the current shell session. Careful this overwrittes "jenv local"
        }
    }
}