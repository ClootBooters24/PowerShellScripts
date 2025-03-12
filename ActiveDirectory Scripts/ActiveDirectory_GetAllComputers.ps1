# Ensure the output directory exists
$outputDirectory = "C:\temp"
New-Item -Path $outputDirectory -ItemType Directory -Force

# Start transcript with a unique filename
$transcriptPath = Join-Path $outputDirectory ("transcript_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
Start-Transcript -Path $transcriptPath -Force

# Get active computers and select desired properties
$activeComputers = Get-ADComputer -Filter "Enabled -eq 'True'" -Properties Name, OperatingSystem, LastLogon | Select-Object Name, OperatingSystem, LastLogon, @{Name="";Expression={$_.ResourceRecord}}

# Output results to the console and transcript with custom formatting
$activeComputers | Format-Table -AutoSize -Property Name, OperatingSystem, LastLogon

Stop-Transcript