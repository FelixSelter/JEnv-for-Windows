function Invoke-Change {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][boolean]$output,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv change <name>"'
        Write-Host 'With this command you set your JAVA_HOME and the version of java to be used globally. This is overwriten by both "jenv local" and "jenv use"'
        Write-Host '<name> is the alias you asigned to the path with "jenv add <name> <path>"'
        return
    }

    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Host ('Theres no JEnv with name {0} Consider using "jenv list"' -f $name)
        return
    }
    else {
        Write-Host "Setting JAVA_HOME globally. This could take some time"
        $config.global = $jenv.path
        $Env:JAVA_HOME = $jenv.path # Set for powershell users
        if ($output) {
            Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
        }
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jenv.path, [System.EnvironmentVariableTarget]::User) # Set globally}
        Write-Host "JEnv changed globally"
    }
}