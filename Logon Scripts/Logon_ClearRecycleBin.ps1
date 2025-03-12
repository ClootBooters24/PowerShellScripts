# Get the current user's SID
$userSid = (New-Object Security.Principal.WindowsIdentity $env:USERNAME).User.Value

# Define the path to the user's Recycle Bin
$recycleBinPath = "C:\`$Recycle.Bin\$userSid"

# Check if the Recycle Bin path exists
if (Test-Path -Path $recycleBinPath) {
    # Get the list of Recycle Bin directories
    try {
        $recycleBinDirs = Get-ChildItem -Path $recycleBinPath -ErrorAction Stop

        # Clear the Recycle Bin
        foreach ($dir in $recycleBinDirs) {
            try {
                Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction Stop
                Write-Output "Deleted $($dir.FullName)"
            } catch {
                Write-Warning "Failed to delete $($dir.FullName): $_"
            }
        }

        Write-Output "Recycle Bin cleared for user $env:USERNAME."
    } catch {
        Write-Warning "Failed to list Recycle Bin directories: $_"
    }
} else {
    Write-Warning "Recycle Bin path does not exist: $recycleBinPath"
}