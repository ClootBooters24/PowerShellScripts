# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure the output directory exists
$outputDirectory = "C:\temp\WindowsVersions"
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

# Loop through each computer and get the OS version using Invoke-Command
foreach ($computer in $computers) {
    $computerName = $computer.Name
# $computerName = ""

    try {
        Write-Host "Connecting to $computerName..."
        $osInfo = Invoke-Command -ComputerName $computerName -ScriptBlock {
            try {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem
                if ($os) {
                    Write-Host "OS information retrieved for $env:COMPUTERNAME: $($os.Caption) $($os.Version)"
                    [PSCustomObject]@{
                        Caption = $os.Caption
                        Version = $os.Version
                    }
                } else {
                    Write-Host "No OS information found on $env:COMPUTERNAME"
                    $null
                }
            } catch {
                Write-Host "Error retrieving OS information on $env:COMPUTERNAME: $_"
                $null
            }
        } -ErrorAction Stop

        # Check if OS information was retrieved
        if ($null -ne $osInfo) {
            Write-Host "Processing OS information for $computerName"
            $osCaption = $osInfo.Caption
            $osVersion = [System.Version]$osInfo.Version
            $note = ""
            if ($osCaption -like "*Windows 10*") {
                if ($osVersion.Build -ne 19045) {
                    $note = "Update Required for Windows 10"
                }
            } elseif ($osCaption -like "*Windows 11*") {
                if ($osVersion.Build -ne 26100 -and $osVersion.Build -ne 22631) {
                    $note = "Update Required for Windows 11"
                }
            } elseif ($osCaption -like "*Windows Server 2019*") {
                if ($osVersion.Build -ne 17763) {
                    $note = "Update Required for Windows Server 2019"
                }
            }

            # Add the result to the array
            $results += [PSCustomObject]@{
                ComputerName = $computerName
                WindowsVersion = $osCaption
                Version = $osVersion
                Note = $note
            }
        } else {
            Write-Warning "No OS Version information returned for $computerName"
        }
    } catch {
        Write-Warning "Failed to connect to ${computerName}: $_"
    }
}

# Export the results to a CSV file
$csvPath = Join-Path $outputDirectory "WindowsVersions.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

# Stop the transcript
Stop-Transcript

Write-Host "Script completed. Results exported to $csvPath"