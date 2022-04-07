#Requires -RunAsAdministrator
[cmdletbinding()]param()

BeforeAll {
    Start-Transcript -Path $PSScriptRoot/test-log.txt
    Write-Host Creating Backups
    
    # Create backups folder if neccessary. Pipe to null to avoid created message
    if (!(test-path $PSScriptRoot/backups/)) {
        New-Item -ItemType Directory -Force -Path $PSScriptRoot/backups/ | Out-Null
    }
    
    # Getting the script so it can be run
    $jenv = ((get-item $PSScriptRoot).parent.fullname + "\src\jenv.ps1")
    
        
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
    
    function Invoke-JEnvBatch {
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
        $stdout, $stderr = Invoke-JEnvBatch @("list")
        $stdout | Should -Be @('Neither pwsh.exe nor powershell.exe was found in your path.', 'Please install powershell it is required')
    }
    It "If theres powershell, it should use it" {  
        $env:Path = ($env:Path + ";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell")   
        $stdout, $stderr = Invoke-JEnvBatch @("list")
        $stdout | Should -Be "JEnv is using powershell"
    }
    It "If theres pwsh, it should use it" {  
        $env:Path = ($env:Path.Replace(";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell", "") + ";" + $PSScriptRoot + "/Fake-Executables/powershell/pwsh")   
        $stdout, $stderr = Invoke-JEnvBatch @("list")
        $stdout | Should -Be "JEnv is using pwsh"
    }
    It "If theres powershell and pwsh it should use pwsh" {  
        $env:Path = ($env:Path + ";" + $PSScriptRoot + "/Fake-Executables/powershell/powershell")   
        $stdout, $stderr = Invoke-JEnvBatch @("list")
        $stdout | Should -Be "JEnv is using pwsh"
    }
}
    
Describe 'JEnv add command' {

    BeforeAll {
        $env:Path = $userPath + ";" + $PSHOME + ";" + $systemPath
    }

    It "Should not accept remove as name" {
        & $jenv add remove wrongpath | Should -Be 'Your JEnv name cannot be "remove". Checkout "jenv remove"'
    }

    It "Should add a valid java version" {
        & $jenv add fake1 $PSScriptRoot/Fake-Executables/java/v1 | Should -Be 'Successfully added the new JEnv: fake1'
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json
        $template = [PSCustomObject]@{
            name = "fake1"
            path = "$($PSScriptRoot)/Fake-Executables/java/v1"
        }
        $config.jenvs | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should add another valid java version" {
        & $jenv add fake2 $PSScriptRoot/Fake-Executables/java/v2 | Should -Be 'Successfully added the new JEnv: fake2'
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json
        $template = @([PSCustomObject]@{
                name = "fake1"
                path = "$($PSScriptRoot)/Fake-Executables/java/v1"
            }, [PSCustomObject]@{
                name = "fake2"
                path = "$($PSScriptRoot)/Fake-Executables/java/v2"
            })
        $config.jenvs | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should not add another jenv with same name" {
        & $jenv add fake1 $PSScriptRoot/Fake-Executables/java/v2 | Should -Be 'Theres already a JEnv with that name. Consider using "jenv list"'
    }

    It "Should not add an invalid jenv" {
        & $jenv add invalid $PSScriptRoot/Fake-Executables/java/ | Should -Be $PSScriptRoot/Fake-Executables/java/"/bin/java.exe not found. Your Path is not a valid JAVA_HOME"
    }
}
    
Describe 'JEnv local command' {

    BeforeAll {
        $env:Path = $userPath + ";" + $PSHOME + ";" + $systemPath
    }

    It "Should add a valid local" {
        & $jenv local fake1 | Should -Be  @('fake1', 'is now your local java version for', "C:\JEnv-for-Windows\tests")
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @([PSCustomObject]@{
                path = "C:\JEnv-for-Windows\tests"
                name = "fake1"
            })
        $config.locals | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should add a valid local with different path and jdk" {
        Set-Location $HOME
        & $jenv local fake2 | Should -Be  @('fake2', 'is now your local java version for', $HOME)
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @([PSCustomObject]@{
                path = "C:\JEnv-for-Windows\tests"
                name = "fake1"
            }, [PSCustomObject]@{
                path = $HOME
                name = "fake2"
            })
        $config.locals | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should replace jenv for path if path already in config" {
        & $jenv local fake1 | Should -Be  @('Your replaced your java version for', $HOME, 'with', 'fake1')
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @([PSCustomObject]@{
                path = "C:\JEnv-for-Windows\tests"
                name = "fake1"
            }, [PSCustomObject]@{
                path = $HOME
                name = "fake1"
            })
        $config.locals | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should not set a local if jenv was not added to the config" {
        & $jenv local notavaible | Should -Be  'Theres no JEnv with name notavaible Consider using "jenv list"'
    }

    It "Should remove jenv from config" {
        & $jenv local remove | Should -Be  "Your local JEnv was unset"
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @([PSCustomObject]@{
                path = "C:\JEnv-for-Windows\tests"
                name = "fake1"
            })
        $config.locals | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }
}

Describe 'JEnv remove command' {

    It "Should remove jenv from jenvs and locals" {
        & $jenv remove fake1 | Should -Be 'Your JEnv was removed successfully'
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @()
        $config.locals | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)

        $template = @([PSCustomObject]@{
                name = "fake2"
                path = "$($PSScriptRoot)/Fake-Executables/java/v2"
            })
        $config.jenvs | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should remove jenv from jenvs" {
        & $jenv remove fake2 | Should -Be 'Your JEnv was removed successfully'
        $config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json

        $template = @()
        $config.jenvs | ConvertTo-Json | Should -Be ($template | ConvertTo-Json)
    }

    It "Should not fail if it does not exist" {
        & $jenv remove fake2 | Should -Be 'Your JEnv was removed successfully'
    }

    AfterAll {
        Set-Location ((get-item $PSScriptRoot).parent.fullname + "/tests")
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
