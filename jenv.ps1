#Requires -Version 5.0

# The location for the config file
If(!(test-path $Env:APPDATA\JEnv\))
{
      New-Item -ItemType Directory -Force -Path $Env:APPDATA\JEnv\
}
$jenvConfig = $Env:APPDATA + "\JEnv\jenv.config"
$jenvConfigTmp = $Env:APPDATA + "\JEnv\jenv.config.tmp"


function Invoke-Help {

    param (
        [string]$command
    )

    Write-Output "__HELP__"
    if (!$command -or $command -eq "add") { Write-Output '"jenv add <name> <javaPath to JAVA_HOME>" adds a new java version"' }
    if (!$command -or $command -eq "use") { Write-Output '"jenv use <name>" changes the java_home and path for the current session' }
    if (!$command -or $command -eq "change") { Write-Output '"jenv change <name>" changes the java_home and path permanently' }
    if (!$command -or $command -eq "list") { Write-Output '"jenv list" lists all added JAVA Environments' }
    if (!$command -or $command -eq "remove") { Write-Output '"jenv remove <name>" removes an existing java version' }
    Exit
}

function Invoke-Add {
    #checking params
    param (
        [string[]]$arguments
    )

    $name = $arguments[1]
    $path = $arguments[2]

    if (!$name) {
        Write-Output "No name was given to jenv."
        Invoke-Help "add"
    }
    if (!$path) {
        Write-Output "No path was given to jenv."
        Invoke-Help "add"
    }

    if ($name.Contains("=") -or $path.Contains("=")) { Write-Output 'Name and path cant contain "=" characters'; Exit }
    if (! (Test-Path $path"\bin\java.exe")) { Write-Output 'The specified path is not a valid JAVA_HOME. File not found: '$path"\bin\java.exe"; Exit }

    #Actual action
    if ($config.ContainsKey($name)) {
        Write-Output ("A JEnv with name $name already exists" -Replace ('\n', ''))
        Exit 
    }
    if ($config.ContainsValue($path)) {
        Write-Output ("A JEnv with path $path already exists" -Replace ('\n', ''))
        Invoke-List
    }
    Add-Content -path $jenvConfig -value $name"="$path
    Write-Output "Added new JEnv successfully"
    Exit
}

function Invoke-Use {
    #checking params
    param (
        [string[]]$arguments,
        [boolean]$saveEnv
    )

    $name = $arguments[1]
    if (!$name) {
        Write-Output "No name was given to jenv."
        Invoke-Help "use"
    }

    if (!$config.ContainsKey($name)) {
        Write-Output ("No JEnv with name $name exists" -Replace ('\n', ''))
        Exit 
    }

    #Actual action
    if (Test-Path "jenv.home.tmp") { Remove-Item "jenv.home.tmp" }
    if ($arguments.Contains("--output") -or $arguments.Contains("-o")) {
        Add-Content -path jenv.home.tmp -value $config.Get_Item($name)
    }
    $Env:JAVA_HOME = $config.Get_Item($name)
    
    $newPath = ""
    $([System.Environment]::GetEnvironmentVariable('PATH','User').split(';', [System.StringSplitOptions]::RemoveEmptyEntries)).foreach{
        $path = $_
        if ($path -notmatch '\\$') { $path += '\' }
        if (!(Test-Path $path"java.exe")) {
            $newPath += $path + ";"
        }
        else {
            Write-Output ("Removed " + $path + " from path" -Replace ('\n', ''))
        }
    }
    $newPath += $config.Get_Item($name) + "\bin"
    Write-Output ("Added " + $config.Get_Item($name) + "\bin to the path" -Replace ('\n', ''))

    if (Test-Path "jenv.path.tmp") { Remove-Item "jenv.path.tmp" }
    if ($arguments.Contains("--output") -or $arguments.Contains("-o")) {
        Add-Content -path jenv.path.tmp -value $newPath
    }
    $Env:PATH = $newPath
    
    if ($saveEnv) {
        [System.Environment]::SetEnvironmentVariable('JAVA_HOME', $config.Get_Item($name), [System.EnvironmentVariableTarget]::User)
        [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::User)
    }
    Exit
}
function Invoke-Change {
    #checking params
    param (
        [string[]]$arguments
    )

    $name = $arguments[1]
    if (!$name) {
        Write-Output "No name was given to jenv."
        Invoke-Help "change"
    }

    Invoke-Use $arguments $True


    #Actual action
    Exit
}
function Invoke-List {
    Write-Output __JEnvs__
    foreach ($entry in $config.GetEnumerator()) {
        Write-Host "$($entry.Name): $($entry.Value)"
    }
    Exit
}
function Invoke-Remove {
    #checking params
    param (
        [string[]]$arguments
    )

    $name = $arguments[1]
    if (!$name) {
        Write-Output "No name was given to jenv."
        Invoke-Help "add"
    }

    #Actual action
    if (!$config.ContainsKey($name)) {
        Write-Output ("No JEnv with name $name exists" -Replace ('\n', ''))
        Exit 
    }
    Get-Content -path $jenvConfig | Where-Object { $_ -notmatch "^$name=" } | Set-Content -path $jenvConfigTmp
    Remove-Item -path $jenvConfig
    Rename-Item -path $jenvConfigTmp -NewName $jenvConfig
    Write-Output "Removed JEnv $name successfully"
    Exit
}

# Load config file
if (!(Test-Path $jenvConfig)) {
    #create config if not exist
    New-Item -path $jenvConfig -type "file" | Out-Null
}
Get-Content $jenvConfig | foreach-object -begin { $config = @{} } -process { $k = [regex]::split($_, '='); if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $config.Add($k[0], $k[1]) } }

# Actual evaluation starts here
$action = $args[0]

if (!$action) {
    Write-Output "No argument was given to jenv."
    Invoke-Help
}

switch ( $action ) {
    add { Invoke-Add $args }
    use { Invoke-Use $args $False }
    change { Invoke-Change $args }
    list { Invoke-List $args }
    remove { Invoke-Remove $args }
    -h { Invoke-Help }
    --help { Invoke-Help }
}
Write-Output "No valid argument was given to jenv."
Invoke-Help
