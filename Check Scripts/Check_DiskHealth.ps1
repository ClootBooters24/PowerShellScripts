Import-Module Storage
Import-Module ActiveDirectory

# Ensure the output directory exists
$outputDirectory = "C:\temp\DiskHealth"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force

# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Get active computers
$computers = Get-ADComputer -Filter "Enabled -eq 'True'" -Properties Name

# Create an array to store the results
$results = @()

# Iterate over each computer
foreach ($computer in $computers) {
    $computerName = $computer.Name
# $computerName = ""

    # Check if the computer is online
    Write-Host "----------------------------------------"
    Write-Output "$computerName..."
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        $disks = Invoke-Command -ComputerName $computerName -ScriptBlock {
            Get-PhysicalDisk
        }
        foreach ($disk in $disks) {
            Write-Host "Checking disk: $($disk.FriendlyName) (Serial: $($disk.SerialNumber))" -ForegroundColor Cyan
        
            # Check health status
            if ($disk.HealthStatus -eq "Healthy") {
                Write-Host "Status: Healthy" -ForegroundColor Green
            } else {
                Write-Host "Status: $($disk.HealthStatus)" -ForegroundColor Red
            }
        
            # Check operational status
            if ($disk.OperationalStatus -eq "OK") {
                Write-Host "Operational Status: OK" -ForegroundColor Green
            } else {
                Write-Host "Operational Status: $($disk.OperationalStatus)" -ForegroundColor Red
            }
        
            # Check for any warnings or errors
            if ($disk.HealthStatus -ne "Healthy" -or $disk.OperationalStatus -ne "OK") {
                Write-Host "WARNING: Disk $($disk.FriendlyName) may be failing or has issues. Investigate further!" -ForegroundColor Yellow
            }

            Write-Host ""

            # Add the result to the results array
            $results += [PSCustomObject]@{
                ComputerName       = $computerName
                DiskFriendlyName   = $disk.FriendlyName
                DiskSerialNumber   = $disk.SerialNumber
                HealthStatus       = $disk.HealthStatus
                OperationalStatus  = $disk.OperationalStatus
            }
        }
        
    } 
    else {
        Write-Warning "Computer $computerName is offline. Skipping."
    }
}

# Export the results to a CSV file
$csvPath = Join-Path $outputDirectory "DiskHealthReport.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

# Stop the transcript
Stop-Transcript

Write-Host "Script completed. Results exported to $csvPath"