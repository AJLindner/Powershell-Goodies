# Powershell-Goodies
An ongoing repository for various useful Powershell Scripts I've created over the years

## HaveIBeenPwned Compromised Password Check
Checks a string against the HaveIBeenPwned compromised password database using their free API. Returns a boolean; **true** if the password is compromised, otherwise **false**.

## New-RandomPerson
Generates 1 or more random people for testing purposes. The objects look like this:

```
FirstName    : Greg
LastName     : Alphonso
Username     : Greg.Alphonso
JobTitle     : Technical Specialist
Department   : Finance
Location     : NY - New York City
EmployeeType : Temporary Employee
Password     : 1abhs;-^0(uOeX^{w5+&J
```
First & Last Name come from the free "names.drycodes.com" API.

Username is based on the $UsernameFormat parameter, and will replace {FirstName} and {LastName} in the string.

JobTitle, Department, and Location are selected at random from the parameters. Defaults are included.

EmployeeType is selected randomly from a weighted list of employee types, so e.g. you can make sure 50% are "Full-Time Employee"

Password is randomly generated based on the $PasswordRequirements parameter.
