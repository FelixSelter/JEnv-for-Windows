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
    "jenv list"                 List all registered Java-Envs.
    "jenv add <name> <path>"    Adds a new Java-Version to JEnv which can be refferenced by the given name
    "jenv remove <name>"        Removes the specified Java-Version from JEnv
    "jenv change <name>"        Applys the given Java-Version globaly for all restarted shells and this one
    "jenv use <name>"           Applys the given Java-Version locally for the current shell
    "jenv local <name>"         Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well
    #>
    [Parameter(Position = 0)][validateset("list", "add", "change", "use", "remove", "local", "getjava", "link", "uninstall", "autoscan")] [string]$action,

    # Displays this helpful message
    [Alias("h")]
    [Switch]$help,

    # Creates a jenv.path.tmp and jenv.home.tmp file when anything changes so for example the batch file can change its vars so no reboot is required
    [Alias("o")]
    [Switch]$output,

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
$JENV_VERSION = "v2.0.32"

#region Remove any java versions from path
# Get all javas except for our fake java script
$javaPaths = (Get-Command java -All | Where-Object { $_.source -ne ((get-item $PSScriptRoot).parent.fullname + "\java.bat") }).source
# Only change something when java versions are found
if ($javaPaths.Length -gt 0) {
    Write-Host "JEnv is changing your environment variables. This process could take longer but it happens only when a java executable is found in your path"
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
    $systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
    # Remove all javas from path
    $userPath = ($userPath | Where-Object { !$javaPaths.Contains($_ + "\java.exe") } ) -join ";"
    $systemPath = ($systemPath | Where-Object { !$javaPaths.Contains($_ + "\java.exe") } ) -join ";"
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User) # Set globally

    try {
        [System.Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine) # Set globally
    }
    catch [System.Management.Automation.MethodInvocationException] {
        Write-Host "JEnv wants to change your system environment vars. Therefore you need to restart it with administration rights. This should only once be required. If you dont want to, you have to call JEnv on every terminal opening to change your session vars"
    }
    $path = $userPath + ";" + $systemPath

    $Env:PATH = $path # Set for powershell users
    if ($output) {
        Set-Content -path "jenv.path.tmp" -value $path # Create temp file so no restart of the active shell is required
    }
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
    Write-Host '"jenv list"                 List all registered Java-Envs.'
    Write-Host '"jenv add <name> <path>"    Adds a new Java-Version to JEnv which can be refferenced by the given name'
    Write-Host '"jenv remove <name>"        Removes the specified Java-Version from JEnv'
    Write-Host '"jenv change <name>"        Applys the given Java-Version globaly for all restarted shells and this one'
    Write-Host '"jenv use <name>"           Applys the given Java-Version locally for the current shell'
    Write-Host '"jenv local <name>"         Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well'
    Write-Host '"jenv link <executable>"    Creates shortcuts for executables inside JAVA_HOME. For example "javac"'
    Write-Host '"jenv uninstall <name>"     Deletes JEnv and restores the specified java version to the system. You may keep your config file'
    Write-Host '"jenv autoscan ?<path>?"    Will scan the given path for java installations and ask to add them to JEnv. Path is optional'
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
        autoscan { Invoke-AutoScan $config $help @arguments }
    }

    #region Save the config
    ConvertTo-Json $config | Out-File $Env:APPDATA\JEnv\jenv.config.json
    #endregion
}