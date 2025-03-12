# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Path to the CSV file
$csvPath = "C:\temp\WindowsVersions\WindowsVersions.csv"

# Import the CSV file
$windowsVersionInfo = Import-Csv -Path $csvPath

# Filter computers with most recent Windows version
$computersWithUpdates = $windowsVersionInfo | Where-Object { $_.Note -ne "" }

# Email parameters
# Update the SMTP server, port, user, and password with your SMTP server details
$smtpServer = ""
$smtpPort = 
$smtpUser = ""
$smtpPass = ""
$from = ""
$to = ""
$subject = "Windows Version Report"

# Create the HTML body
$body = "<html><body>"
$body += "<h2>Windows Version Report</h2>"

if ($computersWithUpdates.Count -gt 0) {
    $body += "<p>The following computers have outdated Windows versions:</p>"
    $body += "<table border='1' cellpadding='5' cellspacing='0'>"
    $body += "<tr><th>Computer Name</th><th>Windows Version</th><th>Updates Available</th></tr>"
    
    foreach ($computer in $computersWithUpdates) {
        $computerName = $computer.ComputerName
        $windowsVersion = $computer.WindowsVersion
        $updatesAvailable = $computer.Note
        $body += "<tr>"
        $body += "<td>$computerName</td>"
        $body += "<td>$windowsVersion</td>"
        $body += "<td>$updatesAvailable</td>"
        $body += "</tr>"
    }
    $body += "</table>"
} else {
    $body += "<p>All computers are up to date with the latest Windows versions.</p>"
}

if ($computersFailedToConnect.Count -gt 0) {
    $body += "<p>The following computers failed to connect:</p>"
    $body += "<table border='1' cellpadding='5' cellspacing='0'>"
    $body += "<tr><th>Computer Name</th><th>Note</th></tr>"
    
    foreach ($computer in $computersFailedToConnect) {
        $computerName = $computer.ComputerName
        $note = "Failed to connect"
        $body += "<tr>"
        $body += "<td>$computerName</td>"
        $body += "<td>$note</td>"
        $body += "</tr>"
    }
    $body += "</table>"
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