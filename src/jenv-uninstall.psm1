function Invoke-Uninstall {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv uninstall" <name>'
        Write-Host 'This command deletes jenv and restores the specified jenv as java'
        Write-Host '<name> is the alias you asigned to the path with "jenv add <name> <path>"'
        return
    }

    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Host ('Theres no JEnv with name {0} Consider using "jenv list"' -f $name)
        return
    }

    # Abort Uninstall
    if ((Open-Prompt "Uninstalling JEnv" "Are you sure you want to delete JEnv entirely from this computer?" "Yes", "No" "This will remove JEnv from your computer", "Last chance to abort the disaster" 1) -eq 1) {
        Write-Host "Aborted uninstallation"
        return
    }

    #region Restore the specified java version

    # Restore PATH
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
    $systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)

    # Filter out the jenv path
    $root = (get-item $PSScriptRoot).parent.fullname
    $userPath = ($userPath | Where-Object { $_ -ne $root } ) -join ";"
    $systemPath = ($systemPath | Where-Object { $_ -ne $root } ) -join ";"

    #Update user path
    $userPath = $userPath + ";" + $jenv.path + "\bin"

    # Set the new PATH
    $path = $userPath + ";" + $systemPath
    $Env:PATH = $path # Set for powershell users
    if ($output) {
        Set-Content -path "jenv.path.tmp" -value $path # Create temp file so no restart of the active shell is required
    }

    # Restore JAVA_HOME
    $Env:JAVA_HOME = $jenv.path # Set for powershell users
    if ($output) {
        Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
    }

    # Set globally
    Write-Host "JEnv is changing your environment variables. This process could take longer"
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javahome, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User) # Set globally

    # Either delete %appdata%/jenv or keep config
    $uninstall = Open-Prompt "Uninstalling JEnv" "Do you want to keep your config file" "Yes", "No" "If you reinstall JEnv later it will use all your configured java_homes and locals", "If you reinstall JEnv it has to be set up from the ground on. Pick this if you dont plan reinstalling JEnv" 0
    if ($uninstall -eq 1) {
        Remove-Item $env:appdata/jenv -recurse -force
    }
    #endregion

    # Delete jenv folder
    Remove-Item (get-item $PSScriptRoot).Parent.FullName -Recurse -Force

    # Exit the script so jenv.ps1 wont continue to run
    Write-Host "Successfully uninstalled JEnv"
    Exit 0


}