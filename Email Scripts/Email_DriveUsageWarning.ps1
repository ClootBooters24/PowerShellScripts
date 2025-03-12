# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Path to the CSV file
$csvPath = "C:\temp\StorageSpace\DiskUsage.csv"

# Import the CSV file
$diskInfo = Import-Csv -Path $csvPath

# Filter computers with UsedSpacePercentage > 85%
$highUsageComputers = $diskInfo | Where-Object { $_.UsedSpacePercentage -gt 85 }

# Email parameters
# Update the SMTP server, port, user, and password with your SMTP server details
$smtpServer = ""
$smtpPort = 
$smtpUser = ""
$smtpPass = ""
$from = ""
$to = ""
$subject = "High Disk Usage Report"

# Create the HTML body
$body = "<html><body>"
$body += "<h2>High Disk Usage Report</h2>"

# Check if there are any high usage computers
if ($highUsageComputers.Count -gt 0) {
    $body += "<p>The following computers have disk usage greater than 85%:</p>"
    $body += "<table border='1' cellpadding='5' cellspacing='0'>"
    $body += "<tr><th>Computer Name</th><th>Used Space (%)</th></tr>"

    # Append computer details to the email body
    foreach ($computer in $highUsageComputers) {
        $computerName = $computer.ComputerName
        $usedSpace = $([math]::Round($computer.UsedSpacePercentage, 2)).ToString("F2")
        $body += "<tr>"
        $body += "<td>$computerName</td>"
        $body += "<td>$usedSpace%</td>"
        $body += "</tr>"
    }
    $body += "</table>"
} else {
    $body += "<p>All computers have disk usage below 85%.</p>"
}

$body += "</body></html>"

# Must download and install the MailKit and MimeKit libraries from https://www.nuget.org/packages/MailKit/ and https://www.nuget.org/packages/MimeKit/
# Will need to create a folder in C:\Libraries and extract the contents of the downloaded zip files to the respective folders

# Load the MailKit and MimeKit assemblies
# Update the paths to the MailKit and MimeKit DLLs based on your installation
Add-Type -Path "C:\Libraries\mailkit.4.8.0\lib\netstandard2.0\MailKit.dll"
Add-Type -Path "C:\Libraries\mimekit.4.8.0\lib\netstandard2.0\MimeKit.dll"

try {
    # Create the email message
    $message = New-Object MimeKit.MimeMessage
    $message.From.Add($from)
    $message.To.Add($to)
    $message.To.Add($to2)
    $message.To.Add($to3)
    $message.Subject = $subject
    $message.Body = New-Object MimeKit.TextPart("html")
    $message.Body.Text = $body

    # Create the SMTP client
    $client = New-Object MailKit.Net.Smtp.SmtpClient
    $client.Connect($smtpServer, $smtpPort, [MailKit.Security.SecureSocketOptions]::StartTls)

    # Authenticate using your SMTP credentials
    $client.Authenticate($smtpUser, $smtpPass)

    # Send the email
    $client.Send($message)

    # Disconnect and dispose the client
    $client.Disconnect($true)
    $client.Dispose()
} catch {
    Write-Warning "Error sending email: $_"
}