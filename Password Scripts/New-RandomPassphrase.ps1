<#
    .SYNOPSIS
        New-RandomPassphrase
        
        Generates a random passphrase with various options for meeting complexity requirements.

        This script uses the [EFF's Long Wordlist for Random Passphrases](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases) as its source.
        You may download the list offline and provide it or any other word list as a `string[]` list via the `-Words` parameter.
    
    .LINK
        https://github.com/AJLindner/Powershell-Goodies
#>
function New-RandomPassphrase {

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $false, position = 0, ValueFromPipeline)]
        [string[]]
        $Words = (Invoke-RestMethod -Uri "" -Method Get | ConvertFrom-Csv -Delimiter "`t" -Header "id","word" | Select-Object -ExpandProperty Word),
    
        [Parameter(Mandatory = $false, position = 1)]
        [string]
        $Delimiter = "-",

        [Parameter(Mandatory = $false, position = 2)]
        [int]
        $WordCount = 3,

        [Parameter(Mandatory = $false, position = 3)]
        [int]
        $DigitCount = 0,

        [Parameter(Mandatory = $false, position = 4)]
        [switch]
        $Capitalize,

        [Parameter(Mandatory = $false, position = 5)]
        [switch]
        $AsSecureString
    )

    $PassphraseSegments = New-Object System.Collections.ArrayList

    1..$WordCount | ForEach-Object {
        Do {
            $Word = $Words | Get-Random
        } Until (
            $Word -notin $PassphraseSegments
        )

        If ($Capitalize) {
            $Word = $word.substring(0,1).ToUpper() + $word.substring(1).ToLower()
        }

        $PassphraseSegments.Add($word) | Out-Null
    }

    If ($DigitCount -gt 0) {
        $Number = (1..$DigitCount | ForEach-Object {
            0..9 | Get-Random
        }) -join ""

        $PassphraseSegments.Add($Number) | Out-Null
    }

    $Passphrase = $PassphraseSegments -join $Delimiter

    If ($AsSecureString) {
        $Passphrase = $Passphrase  | ConvertTo-SecureString -AsPlainText -Force
    }

    Return $Passphrase

}