# Powershell-Goodies
A living repository to share useful Powershell scripts I've created and regularly use for various projects.
<br><br>

## Password Scripts

### Confirm-PwnedPassword
Determines if a password has been compromised according to [HaveIBeenPwned.com](https://HaveIBeenPwned.com). You can provide either a `-PlaintextPassword` or a `-HashedPassword` hashed with `SHA1` or `NTLM`, specified with the `-HashFormat` parameter.
#### API Documentation, License, and Acceptable Use Policy
The Have I Been Pwned PwnedPasswords API has no licensing or attribution requirements. It is a completely free service, provided by [HaveIBeenPwned.com](https://HaveIBeenPwned.com), a [Troy Hunt](https://www.troyhunt.com) project.

For additional information about this endpoint, including the Acceptable Use policy, please refer to the API documentation on HaveIBeenPwned.com:
[https://haveibeenpwned.com/API/v3#PwnedPasswords](https://haveibeenpwned.com/API/v3#PwnedPasswords).

### New-RandomPassword
Generates a random password based on the provided complexity requirements.

| Parameter             | Default Value | Description |
| --------              | -------       | -------       |
| MinLowercase          | 1             | Minimum number of lowercase characters in the password            |
| MinUppercase          | 1             | Minimum number of uppercase characters in the password              |
| MinNumeric            | 1             | Minimum number of digits in the password             |
| MinSpecial            | 1             | Minimum number of special characters in the password, chosen from the `-AllowedSpecialChars` parameter.              |
| Length                | 16            | The length of the password            |
| AllowedSpecialChars                | !"#$%&'()*+,-./:;<=>?@[\\]^_`{\|}~            | The special characters that may be included in the password            |
| AsSecureString    | False         | Return a `SecureString` instead of a plaintext password |

### New-RandomPassphrase
Generates a random passphrase with various options for meeting complexity requirements.

This script uses the [EFF's Long Wordlist for Random Passphrases](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases) as its source. You may download the list offline and provide it or any other word list as a `string[]` list via the `-Words` parameter.

| Parameter         | Default Value | Description |
| --------          | -------       | -------       |
| Words             | [EFF Word List](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt)       | The list of words to randomly select from |
| Delimiter         | -             | The delimiter to use between words |
| WordCount         | 3             | How many words to include in the passphrase |
| DigitCount        | 0             | How many random digits to append to the passphrase |
| Capitalize        | False         | Capitalize the first letter of each word |
| AsSecureString    | False         | Return a `SecureString` instead of a plaintext passphrase |
