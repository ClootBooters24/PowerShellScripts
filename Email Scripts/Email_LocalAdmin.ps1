# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Path to the CSV file
$csvPath = "C:\temp\LocalAdminCheck\LocalAdminCheck.csv"

# Import the CSV file
$localAdminInfo = Import-Csv -Path $csvPath

# Filter computers without the local admin user
$computersWithoutLocalAdmin = $localAdminInfo | Where-Object { $_.Caption -eq "" }

# Email parameters
# Update the SMTP server, port, user, and password with your SMTP server details
$smtpServer = ""
$smtpPort = 
$smtpUser = ""
$smtpPass = ""
$from = ""
$to = ""
$subject = "Local Administrator Report"

# Create the HTML body
$body = "<html><body>"
$body += "<h2>Local Administrator Report</h2>"

# Check if there are any computers without the local admin user
if ($computersWithoutLocalAdmin.Count -gt 0) {
    $body += "<p>The following computers do not have the local admin user rradmin:</p>"
    $body += "<table border='1' cellpadding='5' cellspacing='0'>"
    $body += "<tr><th>Computer Name</th><th>Note</th></tr>"
    
    foreach ($computer in $computersWithoutLocalAdmin) {
        $computerName = $computer.ComputerName
        $note = $computer.Note
        $body += "<tr>"
        $body += "<td>$computerName</td>"
        $body += "<td>$note</td>"
        $body += "</tr>"
    }
    $body += "</table>"
} else {
    $body += "<p>Every computer scanned has the local admin user rradmin.</p>"
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
    Write-Warning "Error sending email: $_"
}