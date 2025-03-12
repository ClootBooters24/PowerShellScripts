# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure the output directory exists
$outputDirectory = "C:\temp\StorageSpace"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force

# Get active computers
$computers = Get-ADComputer -Filter "Enabled -eq 'True'" -Properties Name

# Define a custom object for disk information
$diskInfo = New-Object System.Collections.ArrayList

# Function to get disk information with retry logic
function Get-DiskInfo {
    param (
        [string]$computerName
    )
    $maxRetries = 0
    $retryCount = 0
    $success = $false
    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            $cDrive = Invoke-Command -ComputerName $computerName -ScriptBlock {
                Get-PSDrive -Name C | Select-Object Used,Free
            } -ErrorAction Stop
            $success = $true
            return $cDrive
        } catch {
            $retryCount++
            # Write-Warning "Attempt ${retryCount}: Error retrieving disk information for computer ${computerName}: $_"
            Start-Sleep -Seconds 2
        }
    }
    if (-not $success) {
        Write-Warning "Error retrieving disk information for computer $computerName after $maxRetries retries."
    }
    return $null
}

# Iterate over each computer
foreach ($computer in $computers) {
    $computerName = $computer.Name
# $computerName = ""

    # Check if the computer is online
    Write-Output "Pinging $computerName..."
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        $cDrive = Invoke-Command -ComputerName $computerName -ScriptBlock {
            Get-PSDrive -Name C | Select-Object Used,Free
        }
        if ($cDrive) {
            $freeSpace = $cDrive.Free
            $usedSpace = $cDrive.Used
            $totalSpace = $freeSpace + $usedSpace
            
            if ($totalSpace -ne 0) {
                $usedPercentage = ($usedSpace / $totalSpace) * 100
            } else {
                $usedPercentage = 0
                Write-Warning "Total space is zero for $computerName. Cannot calculate used percentage."
            }
            # Create a custom object for each computer's disk information
            $computerDiskInfo = New-Object PSObject
            $computerDiskInfo | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $computerName
            $computerDiskInfo | Add-Member -NotePropertyName "DriveLetter" -NotePropertyValue "C:"
            $computerDiskInfo | Add-Member -NotePropertyName "TotalCapacityGB" -NotePropertyValue ($totalSpace / 1GB)
            $computerDiskInfo | Add-Member -NotePropertyName "FreeSpaceGB" -NotePropertyValue ($freeSpace / 1GB)
            # $computerDiskInfo | Add-Member -NotePropertyName "UsedSpaceGB" -NotePropertyValue ($usedSpace / 1GB)
            $computerDiskInfo | Add-Member -NotePropertyName "UsedSpacePercentage" -NotePropertyValue $usedPercentage

            # Add the computer's disk information to the list
            [void]$diskInfo.Add($computerDiskInfo)
        } else {
            Write-Warning "Failed to retrieve disk information for $computerName."
        }
    } else {
        Write-Warning "Computer $computerName is offline. Skipping."
    }
}

$csvPath = Join-Path $outputDirectory "DiskUsage.csv"
$diskInfo | Export-Csv -Path $csvPath -NoTypeInformation

# Output results to transcript
$diskInfo | Format-Table -AutoSize

Stop-Transcript