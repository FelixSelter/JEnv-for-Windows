function Invoke-Add {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name,
        [Parameter(Mandatory = $true)][string]$path
    )

    if ($help) {
        Write-Host '"jenv add" <name> <path>'
        Write-Host "With this command you can tell JEnv which java versions you have installed"
        Write-Host '<name> is an alias you have to give the java version for easier referencing. It cannot be remove'
        Write-Host '<path> is the path to the parent of your bin folder. For example: "C:\Program Files\Java\jdk-17"'
        Write-Host 'You have to register your JEnvs first before you can use "jenv change", "jenv use" or "jenv local"'
        Write-Host 'List all registered java versions with "jenv list"'
        Write-Host 'This command is not used to specify local JEnvs. Use "jenv local" for this approach'
        return
    }

    # Name cannot be remove due to the local remove
    if ($name -eq "remove") {
        Write-Output 'Your JEnv name cannot be "remove". Checkout "jenv remove"'
        return
    }

    # Check if name is already used
    foreach ($jenv in $config.jenvs) {
        if ($jenv.name -eq $name) {
            Write-Output 'Theres already a JEnv with that name. Consider using "jenv list"'
            return
        }
    }
    # Check if the path is a valid java home
    if (!(Test-Path -Path $path/bin/java.exe -PathType Leaf)) {
        Write-Output ($path + "/bin/java.exe not found. Your Path is not a valid JAVA_HOME")
        return
    }

    # Add new JEnv
    $config.jenvs += [PSCustomObject]@{
        name = $name
        path = $path
    }
    Write-Output ("Successfully added the new JEnv: " + $name)
}