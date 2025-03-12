# Import the Active Directory module
Import-Module ActiveDirectory

# Define the time period for inactivity (3 months)
$inactiveThreshold = (Get-Date).AddMonths(-3)

# Get all active users who have not logged in for the past 3 months
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $inactiveThreshold -and Enabled -eq $true} -Properties LastLogonDate

# Check if there are any inactive users
if ($inactiveUsers.Count -eq 0) {
    Write-Host "No inactive users found."
} else {
    Write-Host "Inactive users (not logged in for the past 3 months):"
    foreach ($user in $inactiveUsers) {
        Write-Host "$($user.SamAccountName) - Last Logon: $($user.LastLogonDate)"
    }
}