# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Import the Active Directory module
Import-Module ActiveDirectory

# Ensure the output directory exists
$outputDirectory = "C:\temp\UnavailableComputers"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force
Write-Output "Transcript started at $transcriptPath"

# Get all computers from Active Directory
Write-Output "Retrieving all computers from Active Directory..."
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
Write-Output "Retrieved $(($computers).Count) computers from Active Directory."

# Initialize an array to store unavailable computers
$unavailableComputers = @()

# Loop through each computer and check connectivity
Write-Output "Checking connectivity for each computer..."
foreach ($computerName in $computers) {
    if (-not (Test-Connection -ComputerName $computerName -Count 1 -Quiet)) {
        Write-Output "Computer $computerName is unavailable."
        $unavailableComputers += [PSCustomObject]@{ ComputerName = $computerName }
    } else {
        Write-Output "Computer $computerName is available."
    }
}

# Output the list of unavailable computers
if ($unavailableComputers.Count -gt 0) {
    Write-Output "Unavailable Computers:"
    $unavailableComputers | ForEach-Object { Write-Output $_.ComputerName }

    # Export the list of unavailable computers to a CSV file
    $csvPath = Join-Path $outputDirectory "UnavailableComputers.csv"
    $unavailableComputers | Export-Csv -Path $csvPath -NoTypeInformation -Force
    Write-Output "Exported unavailable computers to $csvPath"
} else {
    Write-Output "All computers are available."
}

# Stop the transcript
Stop-Transcript
Write-Output "Transcript stopped."