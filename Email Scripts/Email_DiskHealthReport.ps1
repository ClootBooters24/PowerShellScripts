# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Path to the CSV file
$csvPath = "C:\temp\DiskHealth\DiskHealthReport.csv"

# Import the CSV file
$diskHealthReport = Import-Csv -Path $csvPath

# Filter disks with issues
$diskFailing = $diskHealthReport | Where-Object { $_.HealthStatus -ne "Healthy" -or $_.OperationalStatus -ne "OK" }

# Email parameters
# Update the SMTP server, port, user, and password with your SMTP server details
$smtpServer = ""
$smtpPort = 
$smtpUser = ""
$smtpPass = ""
$from = ""
$to = ""
$subject = "Disk Health Report"

# Create the HTML body
$body = "<html><body>"
$body += "<h2>Disk Health Report</h2>"

if ($diskFailing.Count -gt 0) {
    $body += "<p>The following disks are failing or have issues:</p>"
    $body += "<table border='1' cellpadding='5' cellspacing='0'>"
    $body += "<tr><th>Computer Name</th><th>Disk Name</th><th>Serial Number</th><th>Health Status</th><th>Operational Status</th></tr>"
    
    foreach ($disk in $diskFailing) {
        $healthColor = if ($disk.HealthStatus -eq "Healthy") { "green" } else { "red" }
        $operationalColor = if ($disk.OperationalStatus -eq "OK") { "green" } else { "red" }
        
        $body += "<tr>"
        $body += "<td>$($disk.ComputerName)</td>"
        $body += "<td>$($disk.DiskFriendlyName)</td>"
        $body += "<td>$($disk.DiskSerialNumber)</td>"
        $body += "<td style='color:$healthColor;'>$($disk.HealthStatus)</td>"
        $body += "<td style='color:$operationalColor;'>$($disk.OperationalStatus)</td>"
        $body += "</tr>"
        
        if ($disk.HealthStatus -ne "Healthy" -or $disk.OperationalStatus -ne "OK") {
            $body += "<tr><td colspan='5' style='color:orange;'>WARNING: Disk $($disk.DiskFriendlyName) on $($disk.ComputerName) is failing or has issues. Investigate further!</td></tr>"
        }
    }
    $body += "</table>"
} else {
    $body += "<p style='color:green;'>All disks are healthy.</p>"
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
    Write-Host "Error sending email: $_"
}