# Path to the Downloads folder for the current user
$downloadsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')

# Define the cutoff date (6 months ago)
$cutoffDate = (Get-Date).AddMonths(-6)

# Check if the Downloads folder exists
if (Test-Path -Path $downloadsPath) {
    # Get all files and directories in the Downloads folder
    $items = Get-ChildItem -Path $downloadsPath

    # Remove items older than 6 months
    foreach ($item in $items) {
        if ($item.LastAccessTime -lt $cutoffDate) {
            Remove-Item -Path $item.FullName -Recurse -Force
        }
    }

    Write-Output "Old items in Downloads folder cleared."
} else {
    Write-Output "Downloads folder does not exist."
}