# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for the user's SamAccountName
$samAccountName = Read-Host "Enter the user's Account (e.g., john.doe)"

# Define the target OU for disabled users
$targetOU = "OU=,DC=,DC=com"

# Disable the user and move them to the target OU
try {
    # Disable the user account
    Disable-ADAccount -Identity $samAccountName
    Write-Output "User $samAccountName has been disabled."

    # Move the user to the target OU
    Move-ADObject -Identity (Get-ADUser -Filter { SamAccountName -eq $samAccountName }).DistinguishedName -TargetPath $targetOU
    Write-Output "User $samAccountName has been moved to $targetOU."
} catch {
    Write-Error "Failed to disable and move user: $_"
}