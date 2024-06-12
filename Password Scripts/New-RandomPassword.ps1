function New-RandomPassword {

    [cmdletbinding()]
    param(
        
        [Parameter(Mandatory = $true, position = 0)]
        [int]
        $MinLowercase,

        [Parameter(Mandatory = $true, position = 1)]
        [int]
        $MinUppercase,

        [Parameter(Mandatory = $true, position = 2)]
        [int]
        $MinNumeric,

        [Parameter(Mandatory = $true, position = 3)]
        [int]
        $MinSpecial,

        [Parameter(Mandatory = $false, position = 4)]
        [int]
        $Length = 16,

        [Parameter(Mandatory = $false, position = 5)]
        [Char[]]
        $AllowedSpecialChars = '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~',

        [Parameter(Mandatory = $false, position = 6)]
        [switch]
        $AsSecureString

    )

    if ( $MinLowercase + $MinUppercase + $MinNumeric + $MinSpecial -gt $Length ) {
        Throw "The sum of the minimum required characters can not exceed the Length parameter"
    }

    $chars = @{
        Special = $AllowedSpecialChars
        Numeric = [char[]](48..57)
        Uppercase = [char[]](65..90)
        Lowercase = [char[]](97..122)
    }

    $PasswordChars = New-Object System.Collections.ArrayList

    $AddCharsFromParameter = {
        param($ParameterName)
        
        $Variable = Get-Variable $ParameterName
        $CharsHashKey = ($Variable.Name -replace "Min","")
        
        if ($Variable.Value -gt 0) {
            1..$Variable.Value | ForEach-Object {
                $Char = ($Chars.$($CharsHashKey) | Get-Random)
                $PasswordChars.Add($char) | Out-Null
            }
        }
        else {
            $chars.Remove($CharsHashKey)
        }
    }
    
    @("MinLowercase","MinUppercase","MinNumeric","MinSpecial") | ForEach-Object {
        & $AddCharsFromParameter -ParameterName $_
    }

    while ($PasswordChars.Count -lt $Length) {
        $PasswordChars.Add(($chars.Values | Get-Random)) | out-null
    }

    $Password = ($PasswordChars | Sort-Object {Get-Random}) -join ""

    If ($AsSecureString) {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
    }

    return $Password

}