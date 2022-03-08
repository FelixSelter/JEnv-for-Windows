<#
.Description
Source: https://github.com/FelixSelter/JEnv-for-Windows/
This is the root script of an application called JEnv for Windows
JEnv allows you to change your current JDK Version.
This is helpful for testing or if you have projects requiring different versions of java
For example you can build a gradle project which requires java8 without changing your enviroment variables and then switch back to work with java15
It's written in cmd and powershell so it can change the enviroment variables and can run on any Windows-10+.
#>

# Installation
# Remove any java versions from path

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
    [Parameter(ParameterSetName = "action", Mandatory = $true, Position = 0)][validateset("list", "add", "change", "use", "remove", "local")] [string]$action,

    # Displays this helpful message
    [Alias('h')]
    [Switch]$help 
)

# Load all required modules
Import-Module .\src\jenv-list.psm1
Import-Module .\src\jenv-add.psm1
Import-Module .\src\jenv-remove.psm1
Import-Module .\src\jenv-change.psm1
Import-Module .\src\jenv-use.psm1
Import-Module .\src\jenv-local.psm1

# Call the specified command
# Action has to be one of the following because of the validateset
switch ( $action ) {
    add { Invoke-Add $args }
    change { Invoke-Change $args }
    use { Invoke-Use $args }
    list { Invoke-List $args }
    remove { Invoke-Remove $args }
}