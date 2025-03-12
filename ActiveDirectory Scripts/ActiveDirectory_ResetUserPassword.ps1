# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for the user's email prefix and new password
$emailPrefix = Read-Host "Enter the user's email prefix (e.g., john.doe)"
$newPassword = Read-Host "Enter the user's new password" -AsSecureString

# Function to check password complexity
function Test-PasswordComplexity {
    param (
        [string]$password
    )

    # Define the complexity requirements
    $minLength = 12
    $hasUpperCase = $password -cmatch '[A-Z]'
    $hasLowerCase = $password -cmatch '[a-z]'
    $hasDigit = $password -cmatch '\d'
    # $hasSpecialChar = $password -cmatch '[^a-zA-Z\d]'

    # Check if the password meets the requirements
    if ($password.Length -ge $minLength -and $hasUpperCase -and $hasLowerCase -and $hasDigit) {
        return $true
    } else {
        return $false
    }
}

# Convert the secure string password to plain text for complexity check
$newPasswordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))

# Check if the password meets the complexity requirements
if (-not (Test-PasswordComplexity -password $newPasswordPlainText)) {
    Write-Error "The password does not meet the complexity requirements."
    return
}

# Clear the plain text password from memory as soon as possible
$newPasswordPlainText = $null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# Locate the user account using the email prefix
try {
    $user = Get-ADUser -Filter { SamAccountName -eq $emailPrefix }
    if ($user) {
        # Reset the user's password
        Set-ADAccountPassword -Identity $user -Reset -NewPassword $newPassword
    Set-ADUser -Identity $user -ChangePasswordAtLogon $true
        Write-Output "Password for user $emailPrefix has been reset successfully."
    } else {
        Write-Error "User with email prefix $emailPrefix not found."
    }
} catch {
    Write-Error "Failed to reset password for user: $_"
}