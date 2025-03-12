# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

if (-not $ComputerName) {
    $ComputerName = Read-Host "Enter the computer name"
}

# Define the local admin
$localAdmin = ""
$localAdminPassword = "" | ConvertTo-SecureString -AsPlainText -Force
$description = ""
$fullname = ""

# Create a PSCredential object
$credential = New-Object System.Management.Automation.PSCredential($localAdmin, $localAdminPassword)

# Create the local admin account on the remote computer
Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    param ($localAdmin, $password, $description, $fullname)
    
    # Check if the user already exists
    $user = Get-LocalUser -Name $localAdmin -ErrorAction SilentlyContinue
    if ($user -eq $null) {
        # Create the user
        $params = @{
            Name        = $localAdmin
            Password    = $password
            FullName    = $fullname
            Description = $description
        }
        New-LocalUser @params
        # Add the user to the Administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $localAdmin
        # Set the "Password cannot be changed" attribute
        Invoke-Expression "net user $localAdmin /Passwordchg:No"
        Write-Host "User $localAdmin created, added to the Administrators group, and password cannot be changed."
    } else {
        Write-Host "User $localAdmin already exists."
        # Check if the user is already a member of the Administrators group
        $adminGroup = Get-LocalGroupMember -Group "Administrators"
        if ($adminGroup.Name -notcontains $localAdmin) {
            Add-LocalGroupMember -Group "Administrators" -Member $localAdmin
            Write-Host "User $localAdmin added to the Administrators group."
        } else {
            Write-Host "User $localAdmin is already a member of the Administrators group."
        }
    }
} -ArgumentList $localAdmin, $localAdminPassword, $description, $fullname