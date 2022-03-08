<#
.Description
Source: https://github.com/FelixSelter/JEnv-for-Windows/
This is the root script of an application called JEnv for Windows
JEnv allows you to change your current JDK Version.
This is helpful for testing or if you have projects requiring different versions of java
For example you can build a gradle project which requires java8 without changing your enviroment variables and then switch back to work with java15
It"s written in cmd and powershell so it can change the enviroment variables and can run on any Windows-10+.
#>

# Setup params------------------------------------------------------------------------
param (
    <#
    "jenv list"                 List all registered Java-Envs.
    "jenv add <name> <path>"    Adds a new Java-Version to JEnv which can be refferenced by the given name
    "jenv remove <name>"        Removes the specified Java-Version from JEnv
    "jenv change <name>"        Applys the given Java-Version globaly for all restarted shells and this one
    "jenv use <name>"           Applys the given Java-Version locally for the current shell
    "jenv local <name>"         Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well
    #>
    [Parameter(ParameterSetName = "action", Mandatory = $true, Position = 0)][validateset("list", "add", "change", "use", "remove", "local")] [string]$action,

    # Displays this helpful message
    [Alias("h")]
    [Switch]$help,

    # Creates a jenv.path.tmp and jenv.home.tmp file when anything changes so for example the batch file can change its vars so no reboot is required
    [Alias("o")]
    [Switch]$output 
)
#------------------------------------------------------------------------------------

# Load all required modules
Import-Module $PSScriptRoot\jenv-list.psm1
Import-Module $PSScriptRoot\jenv-add.psm1
Import-Module $PSScriptRoot\jenv-remove.psm1
Import-Module $PSScriptRoot\jenv-change.psm1
Import-Module $PSScriptRoot\jenv-use.psm1
Import-Module $PSScriptRoot\jenv-local.psm1

#region Installation
# TODO: Check for autoupdates

#region Remove any java versions from path and add JEnv + fake java file to the path
# Get all javas except for our fake java script
$javaPaths = (Get-Command java -All | Where-Object { $_.source -ne ((get-item $PSScriptRoot).parent.fullname + "\java.bat") }).source
# Only change something when java versions are found
if ($javaPaths.Length -gt 0) {
    Write-Output "JEnv is changing your environment variables. This process could take longer but it happens only when a java executable is found in your path"
    $userpath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
    # Remove all javas from path
    $userPath = ($userPath | Where-Object { !$javaPaths.Contains($_) }) -join ";"

    $Env:PATH = $userPath # Set for powershell users
    Add-Content -path "jenv.path.tmp" -value $userPath # Create temp file so no restart of the active shell is required
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User) # Set globally
}
#endregion
#endregion

# Call the specified command
# Action has to be one of the following because of the validateset
switch ( $action ) {
    list { Invoke-List $args }
    add { Invoke-Add $args }
    remove { Invoke-Remove $args }
    use { Invoke-Use $args }
    change { Invoke-Change $args }
    local { Invoke-Local $args } 
}