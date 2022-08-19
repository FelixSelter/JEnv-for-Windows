function Invoke-AutoScan {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [string]$path
    )

    if ($help) {
        Write-Host '"jenv autoscan <path>"'
        Write-Host 'This will search for any java.exe files in the given path and prompt the user to add them to JEnv'
        Write-Host '<path> is the path to search like "C:\Program Files\Java"'
        Write-Host 'If <path> is not provided, JEnv will search the entire system'
        return
    }

    $paths = @($path)
    if ( $path -eq "") {
        # Get Drives including Temp folders
        $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
        # Only keep the physical drive letter
        $drives = $drives | ForEach-Object { $_.Substring(0, 3) }
        # Only keep unique
        $paths = $drives | Select-Object -Unique
    }
    # Check if the provided path exists
    elseif (!(Test-Path -Path $path -PathType Container)) {
        Write-Host "The provided path does not exist"
        return
    }

    # Iterate over paths and find java.exe
    Write-Host "JEnv is now searching for java.exe on your Computer. This could take some time..."
    $javaExecutables = @()
    foreach ($path in $paths) {
        $path = $path + "\\"
        $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction "SilentlyContinue" | Where-Object { $_.FullName.EndsWith("\bin\java.exe") }
        if ($null -ne $files) {
            $files | ForEach-Object {
                $javaExecutables += $_.FullName
            }
        }
    }

    # Filter out jenv tests java.exe
    $root = (get-item $PSScriptRoot).parent.fullname
    $javaExecutables = $javaExecutables | Where-Object { $_.Contains($root) -eq $false }

    # Ask user if java.exe should be added to the list
    foreach ($java in $javaExecutables) {
        $version = Get-JavaVersion $java
        switch (Open-Prompt "JEnv autoscan" ("Found java.exe at {0}. Default name is: '{1}'. Do you want to add it to the list?" -f $java, $version) "Yes", "No", "Rename" ("This will add {0} with alias '{1}' to JEnv" -f $java, $version), ("Skip {0}" -f $java), "Change the default name" 1) {
            0 {
                Invoke-Add $config $false $version ($java -replace "\\bin\\java\.exe$", "")
            }
            2 {
                Invoke-Add $config $false (Read-Host ("Enter the new name for {0}" -f $java)) ($java -replace "\\bin\\java\.exe$", "")
            }
        }
    }

}