# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all computers from Active Directory
$excludedComputers = @()
$computers = Get-ADComputer -Filter * | Where-Object { $excludedComputers -notcontains $_.Name } | Select-Object -ExpandProperty Name

# Define the URL for the uBlock Origin extension
$extensionUrl = "https://addons.mozilla.org/firefox/downloads/file/4391011/ublock_origin-1.62.0.xpi"

# Script to install uBlock Origin extension for Firefox
$scriptBlock = {
    param ($extensionUrl)

    $settings = 
    [PSCustomObject]@{
        Path  = "SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install"
        Value = $extensionUrl
        Name  = "1"
    } | Group-Object Path

    # This ensures that the extension is installed for all users on every computer
    foreach($setting in $settings){
        $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
        if ($null -eq $registry) {
            $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
        }
        $setting.Group | ForEach-Object{
            $registry.SetValue($_.name, $_.value)
        }
        $registry.Dispose()
    }
}

# Script to install Firefox
$scriptBlock2 = {
    $workdir = "c:\installer\"
    $firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"

    if (Test-Path -Path $firefoxPath) {
        Write-Host "Firefox is already installed." -ForegroundColor Green
    } else {
        if (Test-Path -Path $workdir -PathType Container) {
            Write-Host "$workdir already exists" -ForegroundColor Red
        } else {
            New-Item -Path $workdir -ItemType directory
        }

        $source = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
        $destination = "$workdir\firefox.exe"

        if (Get-Command 'Invoke-Webrequest') {
            Invoke-WebRequest $source -OutFile $destination
        } else {
            $WebClient = New-Object System.Net.WebClient
            $webclient.DownloadFile($source, $destination)
        }

        Start-Process -FilePath "$workdir\firefox.exe" -ArgumentList "/S"

        Write-Host "Installing Firefox..." -ForegroundColor Green
        
        Start-Sleep -s 15

        Remove-Item -Force $workdir/firefox*
    }
}

# Run the script block on each computer
foreach ($computer in $computers) {
# $computer = ""
    try {
        Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock2 -ErrorAction Stop
        Write-Output "Successfully installed Firefox on $computer"
    } catch {
        Write-Output "Failed to install Firefox on ($computer): $_"
    }

    try {
        Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $extensionUrl -ErrorAction Stop
        Write-Output "Successfully installed uBlock Origin on $computer"
    } catch {
        Write-Output "Failed to install uBlock Origin on ($computer): $_"
    }
}