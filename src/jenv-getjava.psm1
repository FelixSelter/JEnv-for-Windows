
function Get-Java {
    param (
        [object]$config
    )

    $global = $config.global
    $localname = ($config.locals | Where-Object { $_.path -eq (Get-Location) }).name
    $local = ($config.jenvs | Where-Object { $_.name -eq $localname }).path
    $use = $Env:JENVUSE

    # Use command overwrites everything
    if ($use) {
        Write-Output $use
    }
    # Local overwrites global
    elseif ($local) {
        Write-Output $local
    }
    # Global is the default
    elseif ($global) {
        Write-Output $global
    }
    # No JEnv set
    else {
        # ATTENTION: Parantheses in statement will break the batch
        Write-Output 'No global java version found. Use jenv change to set one'
    }
}