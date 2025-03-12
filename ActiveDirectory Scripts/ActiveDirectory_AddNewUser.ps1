# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for user details
$firstName = Read-Host "Enter the user's first name"
$lastName = Read-Host "Enter the user's last name"
$emailPrefix = Read-Host "Enter the user's email prefix (e.g., john.doe)"
$password = Read-Host "Enter the user's password" -AsSecureString

# Define the domain
$domain = ""

# Construct the full email address
$email = "$emailPrefix@$domain"

# Combine first name and last name to get the full name
$name = "$firstName $lastName"

# Define the user properties
$userProperties = @{
    SamAccountName = $emailPrefix
    UserPrincipalName = $email
    Name = $name
    GivenName = $firstName
    Surname = $lastName
    DisplayName = $name
    EmailAddress = $email
    AccountPassword = $password
    Enabled = $true
    Path = "OU=,DC=,DC=com"
    HomeDirectory = '\\\Profiles$\' + $emailPrefix
    HomeDrive = "U:"
}

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

function createHomeFolder {
    param (
        [string]$emailPrefix,
        [string]$domain
    )
    
    $folderPath = "\\\Profiles$\$emailPrefix"

    # Check if the folder already exists
    if (-not (Test-Path -Path $folderPath)) {
        try {
            # Create the home folder
            New-Item -ItemType Directory -Path $folderPath -Force
            Write-Output "Home folder created at $folderPath"
        } catch {
            Write-Error "Failed to create home folder: $_"
        }
    } else {
        Write-Output "Home folder already exists at $folderPath"
    }

    # Set the permissions for the home folder
    try {
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$emailPrefix", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")   
        $acl = Get-Acl -Path $folderPath
        $acl.SetAccessRule($accessRule)
        Set-Acl -Path $folderPath -AclObject $acl
        Write-Output "Permissions set for $domain\$emailPrefix on $folderPath"
    } catch {
        Write-Error "Failed to set permissions on home folder: $_"
    }
}

# Convert the secure string password to plain text for complexity check
$passwordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Check if the password meets the complexity requirements
if (-not (Test-PasswordComplexity -password $passwordPlainText)) {
    Write-Error "The password does not meet the complexity requirements."
    return  # Exit the script if the password does not meet the requirements
}

# Clear the plain text password from memory as soon as possible
$passwordPlainText = $null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# Create the new user
try {
    New-ADUser @userProperties -PassThru | Set-ADUser -ChangePasswordAtLogon $true
    createHomeFolder -emailPrefix $emailPrefix -domain $domain
    Write-Output "User $name ($email) created successfully."
} catch {
    Write-Error "Failed to create user: $_"
}