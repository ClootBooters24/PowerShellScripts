# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure the output directory exists
$outputDirectory = "C:\temp\InstalledPrograms"
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force

# Import the Active Directory module
Import-Module ActiveDirectory

function Get-InstalledPrograms {
    param (
        [string]$computerName
    )

    $programs = @()

    try {
        $regKey32 = Invoke-Command -ComputerName $computerName -ScriptBlock {
            Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue
        }
        $regKey64 = Invoke-Command -ComputerName $computerName -ScriptBlock {
            Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue
        }

        if ($regKey32) {
            $programs += $regKey32 | ForEach-Object {
                [PSCustomObject]@{
                    ComputerName = $computerName
                    ProgramName = $_.DisplayName
                    Version = $_.DisplayVersion
                }
            }
        }

        if ($regKey64) {
            $programs += $regKey64 | ForEach-Object {
                [PSCustomObject]@{
                    ComputerName = $computerName
                    ProgramName = $_.DisplayName
                    Version = $_.DisplayVersion
                }
            }
        }
    } catch {
        Write-Host "Failed to connect to $computerName"
    }

    return $programs
}

# Get the list of computers from Active Directory
$computers = Get-ADComputer -Filter "Enabled -eq 'True'" | Select-Object -ExpandProperty Name

# Iterate over each computer and get installed programs
$allPrograms = @()
foreach ($computerName in $computers) {
    Write-Host "Checking installed programs on $computerName..."
    $programs = Get-InstalledPrograms -computerName $computerName
    $allPrograms += $programs
}

# Group by ProgramName and Version to remove duplicates
$groupedPrograms = $allPrograms | Group-Object -Property ProgramName, Version | ForEach-Object {
    $_.Group | Select-Object -First 1
}

$csvPath = Join-Path $outputDirectory "InstalledPrograms.csv"

# Export the list of installed programs to a CSV file
$groupedPrograms | Export-Csv -Path $csvPath -NoTypeInformation

# Stop the transcript
Stop-Transcript