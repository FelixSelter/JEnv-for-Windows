<#
.Description
Source: https://github.com/FelixSelter/JEnv-for-Windows/
This is the root script of an application called JEnv for Windows
JEnv allows you to change your current JDK Version.
This is helpful for testing or if you have projects requiring different versions of java
For example you can build a gradle project which requires java8 without changing your enviroment variables and then switch back to work with java15
It"s written in cmd and powershell so it can change the enviroment variables and can run on any Windows-10+.
#>

# Setup params
param (
    <#
    "jenv list"                     List all registered Java-Envs.
    "jenv add <name> <path>"        Adds a new Java-Version to JEnv which can be refferenced by the given name
    "jenv remove <name>"            Removes the specified Java-Version from JEnv
    "jenv change <name>"            Applys the given Java-Version globaly for all restarted shells and this one
    "jenv use <name>"               Applys the given Java-Version locally for the current shell
    "jenv local <name>"             Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well
    "jenv autoscan <path> [-y]"     Will scan the given path for java installations and ask to add them to JEnv. Path is optional and "--yes|-y" accepts defaults.
    #>
    [Parameter(Position = 0)][validateset("list", "add", "change", "use", "remove", "local", "getjava", "link", "uninstall", "autoscan")] [string]$action,

    # Displays this helpful message
    [Alias("h")]
    [Switch]$help,

    # Creates a jenv.path.tmp and jenv.home.tmp file when anything changes so for example the batch file can change its vars so no reboot is required
    [Alias("o")]
    [Switch]$output,

    # Accept defaults
    [Alias("y")]
    [Switch]$yes,

    [parameter(mandatory = $false, position = 1, ValueFromRemainingArguments = $true)]$arguments
)

#region Load all required modules
Import-Module $PSScriptRoot\util.psm1  # Provides the Open-Prompt function
Import-Module $PSScriptRoot\jenv-list.psm1 -Force
Import-Module $PSScriptRoot\jenv-add.psm1 -Force
Import-Module $PSScriptRoot\jenv-remove.psm1 -Force
Import-Module $PSScriptRoot\jenv-change.psm1 -Force
Import-Module $PSScriptRoot\jenv-use.psm1 -Force
Import-Module $PSScriptRoot\jenv-local.psm1 -Force
Import-Module $PSScriptRoot\jenv-getjava.psm1 -Force
Import-Module $PSScriptRoot\jenv-link.psm1 -Force
Import-Module $PSScriptRoot\jenv-uninstall.psm1 -Force
Import-Module $PSScriptRoot\jenv-autoscan.psm1 -Force
#endregion

#region Installation
# TODO: Check for autoupdates
$JENV_VERSION = "v2.2.1"

#region Remove any java versions from path
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)


# Windows will check the PATH environment variable for java executables.
# But actually there are two different PATHs.
# The first one is set by the administrator of the machine and cannot be edited by the user. It is used for global shared software
# The second one can be set by the user. It is used for individual software
# Jenv needs to ensure that its dummy java.bat script is the first one to be found by windows
# When searching for an executable, windows checks the systems PATH first and the users afterwards
$javaPaths = (Get-Command java -All).source
$root = (get-item $PSScriptRoot).parent.fullname
$dummyScript = ("{0}\java.bat" -f $root)
if ($javaPaths.IndexOf($dummyScript) -eq -1) {
    $wrongJavaPaths = $javaPaths
}
else {
    $wrongJavaPaths = ($javaPaths | Select-Object -SkipLast ($javaPaths.Length - $javaPaths.IndexOf($dummyScript)))
}

# Remove all javas from system path
foreach ($java in $wrongJavaPaths) {
    if ($systemPath.Contains((get-item $java).Directory.FullName)) {
        # Filter out any existing JEnv
        $systemPath = ($systemPath | Where-Object { !($_ -eq $root) })
        # Prepend JEnv
        $systemPath = , $root + $systemPath

        Write-Host ("JEnv found a java executable in your machines PATH environment variable.`nJEnv places a dummy java executable inside your PATH to work properly.`nTherefore you need to manually remove any other java executable from the PATH.`nOptionally you could also put '{0}' at the top of your machines PATH" -f $root)
        switch (Open-Prompt "JEnv install" "Would you like to append JEnv to the start of your machines path? (This operation requires administrator rights!)" "Yes", "No" ("Append JEnv ({0}) to the start of your machines PATH environment variable" -f $root), "Abort and exit the script" 1) {
            0 {
                Write-Host "Ok. This could take a few seconds"
                # Write to PATH
                try {
                    [System.Environment]::SetEnvironmentVariable("PATH", $systemPath -join ";", [System.EnvironmentVariableTarget]::Machine) # Set globally
                }
                catch [System.Management.Automation.MethodInvocationException] {
                    Write-Host "JEnv wants to change your system environment vars. Therefore you need to restart it with administration rights. This should only once be required. If you do not want to, you have to call JEnv on every terminal opening to change your session vars"
                }
            }
            1 {
                Write-Host "Aborted. The PATH will only be modified for this shell session. You should consider changing the PATH manually"
            }
        }
        # Its fine to break here. If we already put something in the machines path we do not need to change the users path as windows checks the machines path first
        break
    }

    # This block only executes if no java was found in the systems path. Because the paths array contains the machine elements followed by the user elements.
    if ($userPath.Contains((get-item $java).Directory.FullName)) {
        # Filter out any existing JEnv
        $userPath = ($userPath | Where-Object { !($_ -eq $root) })
        # Prepend JEnv
        $userPath = , $root + $userPath

        Write-Host ("JEnv found a java executable in your users PATH environment variable.`nJEnv places a dummy java executable inside your PATH to work properly.`nTherefore you need to manually remove any other java executable from the PATH.`nOptionally you could also put '{0}' at the top of your users PATH" -f $root)
        switch (Open-Prompt "JEnv install" "Would you like to append JEnv to the start of your users path?" "Yes", "No" ("Append JEnv ({0}) to the start of your users PATH environment variable" -f $root), "Abort and exit the script" 1) {
            0 {
                Write-Host "Ok. This could take a few seconds"
                # Write to PATH
                [System.Environment]::SetEnvironmentVariable("PATH", $userPath -join ";", [System.EnvironmentVariableTarget]::User) # Set globally
            }
            1 {
                Write-Host "Aborted. The PATH will only be modified for this shell session. You should consider changing the PATH manually"
            }
        }
        break
    }

}

$path = ($systemPath + $userPath) -join ";"

$Env:PATH = $path # Set for powershell users
if ($output) {
    Set-Content -path "jenv.path.tmp" -value $path # Create temp file so no restart of the active shell is required
}
#endregion

#region Load the config
# Create folder if neccessary. Pipe to null to avoid created message
if (!(test-path $Env:APPDATA\JEnv\)) {
    New-Item -ItemType Directory -Force -Path $Env:APPDATA\JEnv\ | Out-Null
}
# Creates the config file if neccessary
if (!(test-path $Env:APPDATA\JEnv\jenv.config.json)) {
    New-Item -type "file" -path $Env:APPDATA\JEnv\ -name jenv.config.json | Out-Null
}
# Load the config
$config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json
# Initialize with empty object if config file is empty so Add-Member works
if ($null -eq $config) {
    $config = New-Object -TypeName psobject
}
# Add jenvs property if it does not exist
if (!($config | Get-Member jenvs)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name jenvs -Value @()
}
# Add locals property if it does not exist
if (!($config | Get-Member locals)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name locals -Value @()
}
# Add locals property if it does not exist
if (!($config | Get-Member global)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name global -Value ""
}
#endregion

#endregion

#region Apply java_home for jenv local
$localname = ($config.locals | Where-Object { $_.path -eq (Get-Location) }).name
$javahome = ($config.jenvs | Where-Object { $_.name -eq $localname }).path
if ($null -eq $localname) {
    $javahome = $config.global
}
$Env:JAVA_HOME = $javahome # Set for powershell users
if ($output) {
    Set-Content -path "jenv.home.tmp" -value $javahome # Create temp file so no restart of the active shell is required
}
#endregion

if ($help -and $action -eq "") {
    Write-Host '"jenv list"                            List all registered Java-Envs.'
    Write-Host '"jenv add <name> <path>"               Adds a new Java-Version to JEnv which can be refferenced by the given name'
    Write-Host '"jenv remove <name>"                   Removes the specified Java-Version from JEnv'
    Write-Host '"jenv change <name>"                   Applys the given Java-Version globaly for all restarted shells and this one'
    Write-Host '"jenv use <name>"                      Applys the given Java-Version locally for the current shell'
    Write-Host '"jenv local <name>"                    Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well'
    Write-Host '"jenv link <executable>"               Creates shortcuts for executables inside JAVA_HOME. For example "javac"'
    Write-Host '"jenv uninstall <name>"                Deletes JEnv and restores the specified java version to the system. You may keep your config file'
    Write-Host '"jenv autoscan [--yes|-y] ?<path>?"    Will scan the given path for java installations and ask to add them to JEnv. Path is optional and "--yes|-y" accepts defaults.'
    Write-Host 'Get help for individual commands using "jenv <list/add/remove/change/use/local> --help"'
}
else {

    # Call the specified command
    # Action has to be one of the following because of the validateset
    switch ( $action ) {
        list { Invoke-List $config $help }
        add { Invoke-Add $config $help @arguments }
        remove { Invoke-Remove $config $help @arguments }
        use { Invoke-Use $config $help $output @arguments }
        change { Invoke-Change $config $help $output @arguments }
        local { Invoke-Local $config $help @arguments }
        getjava { Get-Java $config }
        link { Invoke-Link $help @arguments }
        uninstall { Invoke-Uninstall $config $help @arguments }
        autoscan { Invoke-AutoScan $config $help $yes @arguments }
    }

    #region Save the config
    ConvertTo-Json $config | Out-File $Env:APPDATA\JEnv\jenv.config.json
    #endregion
}