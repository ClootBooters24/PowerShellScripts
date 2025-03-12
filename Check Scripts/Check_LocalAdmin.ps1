# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure the output directory exists
$outputDirectory = "C:\temp\LocalAdminCheck"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force

# Import the Active Directory module
Import-Module ActiveDirectory

# Get a list of all computers in the domain
$computers = Get-ADComputer -Filter *

# Create an array to store the results
$results = @()

# Loop through each computer and check if the rradmin user exists
foreach ($computer in $computers) {
    $computerName = $computer.Name
# $computerName = ""

    try {
        Write-Host "Connecting to $computerName..."
        
        # Create a remote session
        $session = New-PSSession -ComputerName $computerName -ErrorAction Stop

        $userInfos = Invoke-Command -Session $session -ScriptBlock {
            try {
                # Check if the rradmin user exists
                $users = Get-CimInstance -ClassName Win32_UserAccount -Filter "Name=''" -ErrorAction Stop
                if ($users) {
                    return $users | ForEach-Object {
                        [PSCustomObject]@{
                            UserName = $_.Name
                            Domain   = $_.Domain
                            Caption  = $_.Caption
                        }
                    }
                } else {
                    return $null
                }
            } catch {
                return $null
            }
        } -ErrorAction Stop

        if ($userInfos) {
            foreach ($userInfo in $userInfos) {
                $caption = "$($userInfo.Caption)"
                $results += [PSCustomObject]@{
                    ComputerName = $computerName
                    Caption      = $caption
                    Note         = "User  exists"
                }
            }
        } else {
            $results += [PSCustomObject]@{
                ComputerName = $computerName
                Caption      = ""
                Note         = "User  does not exist"
            }
        }

        # Close the remote session
        Remove-PSSession -Session $session
    } catch {
        Write-Host "Failed to connect to $computerName"
        $results += [PSCustomObject]@{
            ComputerName = $computerName
            Caption      = ""
            Note         = "Failed to connect"
        }
    }
}

# Filter out the entries with the note "Failed to connect"
$filteredResults = $results | Where-Object { $_.Note -ne "Failed to connect" }

# Output the results
$filteredResults | Format-Table -AutoSize

# Export results to CSV
$csvPath = Join-Path $outputDirectory "LocalAdminCheck.csv"
$filteredResults | Export-Csv -Path $csvPath -NoTypeInformation

Stop-Transcript