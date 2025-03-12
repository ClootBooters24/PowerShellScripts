# Function to get user by email prefix
function Get-UserByEmailPrefix {
    param (
        [string]$emailPrefix
    )
    $user = Get-ADUser -Filter "EmailAddress -like '$emailPrefix*'"
    return $user
}

# Function to add or remove user from groups
function Set-UserGroups {
    param (
        [string]$userName,
        [string]$action,
        [string[]]$groups
    )
    $user = Get-ADUser -Identity $userName
    if ($null -eq $user) {
        Write-Host "User not found."
        return
    }

    foreach ($group in $groups) {
        $isMember = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.SamAccountName -eq $user.SamAccountName }
        if ($action -eq "add" -and $null -eq $isMember) {
            Add-ADGroupMember -Identity $group -Members $user
            Write-Host "Added $($user.SamAccountName) to $group"
        } elseif ($action -eq "remove" -and $null -ne $isMember) {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
            Write-Host "Removed $($user.SamAccountName) from $group"
        }
    }
}

# Main script
$emailPrefix = Read-Host "Enter the email prefix of the user"
$user = Get-UserByEmailPrefix -emailPrefix $emailPrefix

if ($null -eq $user) {
    Write-Host "User not found."
    exit
}

$action = Read-Host "Enter the action (add/remove)"
$groupInput = Read-Host "Enter the groups separated by a comma"
$groups = $groupInput -split ','

Set-UserGroups -userName $user.SamAccountName -action $action -groups $groups