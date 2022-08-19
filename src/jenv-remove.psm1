function Invoke-Remove {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv remove" <name>'
        Write-Host 'With this command you can remove any java version you registered with "jenv add"'
        Write-Host '<name> is the alias you asigned to the path with "jenv add <name> <path>"'
        return
    }

    # Remove the JEnv
    $config.jenvs = @($config.jenvs | Where-Object { $_.name -ne $name })
    # Remove any jenv local with that name
    $config.locals = @($config.locals | Where-Object { $_.name -ne $name })
    Write-Output 'Your JEnv was removed successfully'
}