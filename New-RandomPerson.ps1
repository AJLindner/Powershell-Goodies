function New-RandomPerson {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [int]
        $Count = 1,

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [string]
        $UsernameFormat = "{firstname}.{lastname}",

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [string[]]
        $JobTitles = @(
            'Accountant',
            'Account Manager',
            'Administrative Assistant',
            'Business Analyst',
            'Cloud Architect',
            'Economist',
            'Information Security Analyst',
            'Manager', 
            'Marketing Agent',
            'Network Administrator',
            'Office Manager',
            'Operations Coordinator',
            'Project Manager',
            'Scrum Master',
            'Security Engineer',
            'Software Developer',
            'Support Agent',
            'Technical Specialist',
            'Web Designer'
        ),

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [string[]]
        $Departments = @(
            'Accounting',
            'Engineering',
            'Finance',
            'Human Resources',
            'Information Technology',
            'Marketing',
            'Production',
            'Purchasing',
            'Sales'
         ),

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [string[]]
        $Locations = @(
            'AL - Huntsville',
            'AZ - Phoenix',
            'CA - Los Angeles',
            'CA - San Diego',
            'CO - Denver',
            'GA - Atlanta',
            'IL - Chicago',
            'KY - Louisville',
            'NY - New York City',
            'OH - Cincinnati',
            'PA - Philadelphia',
            'TN - Nashville',
            'TX - Dallas',
            'TX - Houston',
            'WA - Seattle'
        ),

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [hashtable]
        $WeightedEmployeeTypes = @{
            'Full Time Employee' = 45
            'Part Time Employee' = 15
            'Seasonal Employee' = 5
            'Temporary Employee' = 5
            'Leased Employee' = 5
            'Contractor' = 5
            'Volunteer' = 5
            'On-Call Worker' = 5
            'Vendor' = 5
            'Affiliate' = 5
        },

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [ValidateScript({
            $AllKeys = $True
            ForEach ($Key in @("MinLowercase","MinUppercase","MinNumeric","MinSpecial","MinLength","MaxLength")) {
                if (!($_.ContainsKey($Key))) {
                    $AllKeys = $False
                }
            }
            Return $Allkeys
        })]
        [hashtable]
        $Passwordrequirements = @{
            MinLowercase = 1
            MinUppercase = 1
            MinNumeric = 1
            MinSpecial = 1
            MinLength = 12
            MaxLength = 64
        },

        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [int]
        [validateRange(0,100)]
        $PercentDisabled = 0
    )
    
    # Function to generate a Random Password based on the $PasswordRequirements
    $GeneratePassword = {
        if ( $MinLowercase + $MinUppercase + $MinNumeric + $MinSpecial -gt $Length ) {
            Throw "The sum of the minimum required characters can not exceed the Length parameter"
        }

        $chars = @{
            Special = [char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'
            Numeric = [char[]](48..57)
            Uppercase = [char[]](65..90)
            Lowercase = [char[]](97..122)
        }

        $PasswordChars = New-Object System.Collections.ArrayList

        ForEach ($Req in $Passwordrequirements.GetEnumerator() | Where-Object Name -in "MinSpecial", "MinNumeric", "MinLowercase", "MinUppercase") {
            $CharsHashKey = ($Req.Name -replace "Min","")

            if ($Req.Value -gt 0) {
                1..$Req.Value | ForEach-Object {
                    $Char = ($Chars.$($CharsHashKey) | Get-Random)
                    $PasswordChars.Add($char) | Out-Null
                }
            }
            else {
                $chars.Remove($CharsHashKey)
            }
        }

        $Length = $Passwordrequirements.MinLength..$Passwordrequirements.MaxLength | Get-Random

        while ($PasswordChars.Count -lt $Length) {
            $PasswordChars.Add(($chars.Values | Get-Random)) | out-null
        }

        $Password = ($PasswordChars | Sort-Object {Get-Random}) -join ""
        Return $Password
    }

    # Build the weighted employee types list
    $WeightedEmployees = ForEach ($Type in $WeightedEmployeeTypes.GetEnumerator()) {
    
        1..($Type.Value) | ForEach-Object {
            $Type.Name
        }
    
    }

    # Get all the names. The API returns either "Boy" or "Girl" names
    # So we will split the $count in half and call both endpoints to get equal results
    $Half = [int](([math]::ceiling($Count/2)))

    $BoyNames = (Invoke-RestMethod -Method GET -URI "https://names.drycodes.com/$($half)?nameOptions=boy_names" | Select-Object -unique) -split "`n"
    $GirlNames = (Invoke-RestMethod -Method GET -URI "https://names.drycodes.com/$($half)?nameOptions=girl_names" | Select-Object -unique) -split "`n"
    
    $PersonList = New-Object System.Collections.ArrayList

    # For Each Name, generate a Person Object
    # First & Last, Username based on $UsernameFormat
    # Job Title, Department, Location, and Employee Type randomized from parameters
    # Randomly generated password based on $PasswordRequirements

    ForEach ($List in @($BoyNames,$GirlNames)) {

        Foreach ($Name in $List) {

            $Split = $Name -split "_"
            $FirstName = $Split[0]
            $LastName = $Split[1]

            $ThisPerson = [pscustomobject]@{
                FirstName = $FirstName
                LastName = $LastName
                Username = ($UsernameFormat -replace "{firstname}",$FirstName) -replace "{lastname}",$LastName
                JobTitle = $JobTitles | Get-Random
                Department = $Departments | Get-Random
                Location = $Locations | Get-Random
                EmployeeType = $WeightedEmployees | Get-Random
                Password = & $GeneratePassword
            }

            $PersonList.Add($ThisPerson) | Out-Null

        }
    }

    Return $PersonList
}