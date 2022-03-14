function Invoke-Local {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][boolean]$output,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv local <name>"'
        Write-Host 'This command allows you to specify a java version that will always be used in this folder and all subfolders'
        Write-Host 'This is overwriten by "jenv use"'
        Write-Host '<name> is the alias of the JEnv you want to specify'
        Write-Host Attention! You might have to call jenv first before it changes your JAVA_HOME to the local environment. The java command will work out of the box
    }
    else {

        # Remove the local JEnv
        if ($name -eq "remove") {
            $config.locals = @($config.locals | Where-Object { $_.path -ne (Get-Location) })
            Write-Host Your local JEnv was unset
            return
        }

        # Check if specified JEnv is avaible
        $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
        if ($null -eq $jenv) {
            Write-Host Theres no JEnv with name $name Consider using "jenv list"
            return
        }

        # Check if path is already used
        foreach ($jenv in $config.locals) {
            if ($jenv.path -eq (Get-Location)) {
                # if path is used replace with new version
                $jenv.name = $name
                Write-Host "Your replaced your java version for" (Get-Location) with $name
                return
            }
        }

        # Add new JEnv
        $config.locals += [PSCustomObject]@{
            path = (Get-Location).path
            name = $name
        }

        Write-Host $name "is now your local java version for" (Get-Location)
    }
}