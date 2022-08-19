function Open-Prompt {
    param (
        [Parameter(Mandatory = $true)][string]$title,
        [Parameter(Mandatory = $true)][string]$question,
        [Parameter(Mandatory = $true)][string[]]$choices,
        [Parameter(Mandatory = $true)][string[]]$choice_descriptions,
        [Parameter(Mandatory = $true)][int]$default_choice
    )

    [System.Management.Automation.Host.ChoiceDescription[]] $options = @()
    for ($i = 0; $i -lt $choices.Length; $i++) {
        $options += New-Object System.Management.Automation.Host.ChoiceDescription ("&{0}" -f $choices[$i]), $choice_descriptions[$i]
    }

    return $Host.UI.PromptForChoice($title, $question, $options, $default_choice)
}

function Get-JavaVersion {
    param (
        [Parameter(Mandatory = $true)][string]$javaexe
    )
    $version = (Get-Command $javaexe | Select-Object -ExpandProperty Version).toString()
    $version = $version -replace "(?>\.0)*(?!.+)", "" # Remove trailing zeros
    return $version
}