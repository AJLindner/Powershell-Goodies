<#

    .SYNOPSIS
        ConvertTo-Hash
        
        Hashes the provided $string using the chosen $algorithm

    .DESCRIPTION
        Converts any string into a SHA1, SHA256, SHA384,or SHA512 hash. HIBP uses
        SHA1, and that is the default algorithm if no argument is passed in.

    .EXAMPLE
        PS C:\ ConvertTo-Hash -String "PlaintextPassword" -Algorithm "SHA1"

        0114771c128a1432ba2cb4f4b17e2d78d1644d51

#>
function ConvertTo-Hash {

    [cmdletbinding()]
    param(

        [parameter(position=1,mandatory=$true)]
        [string]
        $String,

        [parameter(position=2,mandatory=$false)]
        [ValidateSet("SHA1","SHA256","SHA384","SHA512")]
        $Algorithm = "SHA1"
    )

    $stringBuilder = New-Object System.Text.StringBuilder
    $Bytes = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($string))
    $Hash = ForEach ($byte in $bytes) {
        $byte.ToString("x2")
    }
    
    Return ($Hash -join "").ToLower()

}


<#

    .SYNOPSIS
        Check if a password is in the HaveIBeenPwned database

    .DESCRIPTION
        Hashes the first 5 characters of the entered password to perform a range check against
        the HIBP database and return a boolean if the $password is compromised.

    .EXAMPLE
        PS C:\ Test-IsCompromisedPassword -Password "Password"

        True

#>
function Test-IsCompromisedPassword {

    [cmdletbinding()]
    param(

        [parameter(position=1,mandatory=$true)]
        [string]
        $Password
    )

    $passwordHash = ConvertTo-Hash -String $Password

    # HIBP uses the first 5 characters of the hash for its Range check
    $hashPrefix = $passwordHash.Substring(0,5)
    $url = "https://api.pwnedpasswords.com/range/$hashPrefix"

    # Enable TLS 1.2 for the web call
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # The -UseBasicParsing parameter bypasses the need to setup IE's initial config
    $HIBP = Invoke-WebRequest -Uri $url -UseBasicParsing

    # The HIBP API returns a CRLF separated string with all matching hashes
    # but only includes the SUFFIX (all characters after the 5 we provide)
    # and also includes the count of compromises, separated by a colon
    # example ABCDEFGHIJKLMN: 24

    # Here we loop through that list, parse out the suffixes, and return an object
    # containing all the complete hashes (forced to lowercase)
    $Matches = ForEach ($result in $HIBP.Content.Split("`n")) {
        
        $hashSuffix = $Result.Split(":")[0].ToLower()
        "$hashPrefix$hashSuffix"

    }

    # Finally, check if the original password is in the compromised list
    $PasswordLeaked = ($passwordHash.ToLower() -in $Matches)

    return $PasswordLeaked
}