#Requires -RunAsAdministrator
[cmdletbinding()]param()


BeforeAll {
    Start-Transcript -Path $PSScriptRoot/test-log.txt
    Write-Host Creating Backups

    # Create backups folder if neccessary. Pipe to null to avoid created message
    if (!(test-path $PSScriptRoot/backups/)) {
        New-Item -ItemType Directory -Force -Path $PSScriptRoot/backups/ | Out-Null
    }

    Write-Host Backing up your path environment vars
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    Out-File -FilePath $PSScriptRoot/backups/jenv.userPath.bak -InputObject $userPath
    Write-Verbose "Backed up the following UserPath:"
    Write-Verbose $userPath
    $systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    Out-File -FilePath $PSScriptRoot/backups/jenv.systemPath.bak -InputObject $systemPath
    Write-Verbose "Backed up the following SystemPath:"
    Write-Verbose $systemPath

    Out-File -FilePath $PSScriptRoot/backups/jenv.path.bak -InputObject $env:Path
    Write-Verbose "Backed up the following Path:"
    Write-Verbose $env:Path

    Write-Host Backing up your JEnv Config
    if (test-path $Env:APPDATA\JEnv\jenv.config.json) {
        Copy-Item -Path $Env:APPDATA\JEnv\jenv.config.json -Destination $PSScriptRoot/backups/jenv.config.bak
        Write-Verbose "Backed up the following JEnv config:"
        Write-Verbose (Get-Content -Path $PSScriptRoot/backups/jenv.config.bak -Raw)
        Write-Host Deleting old JEnv config
        Remove-Item -Path $Env:APPDATA\JEnv\jenv.config.json
    }
    else {
        Write-Verbose "No JEnv config was found"
    }
    Write-Host Setting up path enviroment for testing
    $userPath = (get-item $PSScriptRoot).parent.fullname
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User)
    Write-Verbose "Changed UserPath to:"
    Write-Verbose $userPath
    $systemPath = "C:\Windows\system32;"
    [System.Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Verbose "Changed SystemPath to:"
    Write-Verbose $systemPath
    $env:Path = $userPath + ";" + $systemPath

    function Invoke-JEnvCommand {
        param (
            $arguments = @()
        )
    
        Start-Process -FilePath  ((get-item $PSScriptRoot).parent.fullname + "\jenv.bat") -ArgumentList $arguments -Wait -NoNewWindow -RedirectStandardOutput $PSScriptRoot/jenv.test.stdout -RedirectStandardError $PSScriptRoot/jenv.test.stderr
        $stdout = Get-Content -Path jenv.test.stdout
        Remove-Item -Path jenv.test.stdout
        $stderr = Get-Content -Path jenv.test.stderr
        Remove-Item -Path jenv.test.stderr
        return $stdout, $stderr
        
    }

    Write-Host -----------------------------------------------
}

Describe 'JEnv Batch file using correct powershell' {
    It "If theres no powershell or pwsh installed it should throw an error" {        
        $stdout, $stderr = Invoke-JEnvCommand @("list")
        $stdout | Should -Be @('Neither pwsh.exe nor powershell.exe was found in your path.', 'Please install powershell it is required')
    }
    It "If theres powershell, it should use it" {  
        $env:Path = ($env:Path + ";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell")   
        $stdout, $stderr = Invoke-JEnvCommand @("list")
        $stdout | Should -Be "JEnv is using powershell"
    }
    It "If theres pwsh, it should use it" {  
        $env:Path = ($env:Path.Replace(";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell", "") + ";" + $PSScriptRoot + "/Fake-Executables/powershell/pwsh")   
        $stdout, $stderr = Invoke-JEnvCommand @("list")
        $stdout | Should -Be "JEnv is using pwsh"
    }
    It "If theres powershell and pwsh it should use pwsh" {  
        $env:Path = ($env:Path + ";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell")   
        $stdout, $stderr = Invoke-JEnvCommand @("list")
        $stdout | Should -Be "JEnv is using pwsh"
    }
}

AfterAll {
    Write-Host -----------------------------------------------
    Write-Host Restoring your system from backups
    Write-Host Restoring your path environment vars
    $userPath = (Get-Content -Path $PSScriptRoot/backups/jenv.userPath.bak)
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User)
    Write-Verbose "Your UserPath was restored from the backup to:"
    Write-Verbose $userPath
    $systemPath = (Get-Content -Path $PSScriptRoot/backups/jenv.systemPath.bak)
    [System.Environment]::SetEnvironmentVariable("PATH", $systemPath , [System.EnvironmentVariableTarget]::Machine)
    Write-Verbose "Your SystemPath was restored from the backup to:"
    Write-Verbose $systemPath

    $env:Path = (Get-Content -Path $PSScriptRoot/backups/jenv.path.bak)
    Write-Verbose "Your path was restored from the backup to:"
    Write-Verbose $env:Path

    Write-Host Restoring your JEnv config
    if (test-path $PSScriptRoot/backups/jenv.config.bak) {
        Copy-Item -Path $PSScriptRoot/backups/jenv.config.bak -Destination $Env:APPDATA\JEnv\jenv.config.json
        Write-Verbose "Restored the following JEnv config:"
        Write-Verbose (Get-Content -Path  $Env:APPDATA\JEnv\jenv.config.json -Raw)
    }
    else {
        Write-Verbose "No JEnv config backup was found"
    }
    Stop-Transcript
}

