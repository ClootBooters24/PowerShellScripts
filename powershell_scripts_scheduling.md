# PowerShell, Scripting, and Scheduling Scripts
This SWI document provides detailed instructions for running various PowerShell scripts used for IT tasks at ` `. These scripts perform tasks such as managing Active Directory users, checking system health, and sending email reports. The document includes information on prerequisites, installation steps, and scheduling the scripts to run automatically.

If any scripts fail, you may need to set the execution policy using this command:
```Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass```
## Before Running Scripts
Each of these scripts is written for PowerShell 7. Be sure to download and install PowerShell 7 before proceeding.

---
## To Run `ActiveDirectory_` Scripts
These scripts are located in the `ActiveDirectory Scripts` folder. They perform various Active Directory tasks such as adding new users, removing users from groups, disabling users, and resetting user passwords.

In order to run the Active Directory module on PowerShell, the server needs to have AD DS and AD LDS Tools installed.

### To install AD DS and AD LDS Tools:
After logging in to the server, when Server Manager starts, click `Manage > Add Roles and Features`.  
Ensure `Role-based or feature-based installation` is selected.  
Ensure `` is selected.  
Do not change anything in `Server Roles`.  
In Features, scroll down to `Remote Server Administration Tools > Role Administration Tools > AD DS and AD LDS Tools`.  
Ensure `Restart Server if Needed` is NOT enabled.  
Allow the server to install the tools.

The server is now able to scan all of `` Facilities using Active Directory.

---
## To Run `Email_` Scripts
These scripts are located in the `Email Scripts` folder. They send various email reports such as drive usage warnings, local admin checks, and disk health reports.

You must download and install the MailKit and MimeKit libraries from https://www.nuget.org/packages/MailKit/ and https://www.nuget.org/packages/MimeKit/.  
Change the packages from `.nupkg` to `.zip`.  
Create a folder in `C:\Libraries` and extract the contents of the downloaded zip files to the respective folders.

The end folder should look something like this:
```C:\Libraries\mailkit.4.8.0\lib\netstandard2.0\MailKit.dll```
```C:\Libraries\mimekit.4.8.0\lib\netstandard2.0\MimeKit.dll```

---
## To Run `Check_` Scripts
These scripts are located in the `Check Scripts` folder. They perform various checks such as checking all installed programs, C drive usage, disk health, inactive users, and local admin presence.

Each of these scripts runs through the Active Directory, so be sure to have the module installed.

**Note:** Be sure to check and update the Windows Versions that are being checked in `Check_WindowsVersion.ps1`.

---
## To Run `Misc_` Scripts
These scripts are located in the `Misc Scripts` folder. There are mulitple miscellaneous scripts in this folder.

---
## To Schedule Scripts to Run
You can schedule scripts to run using Task Scheduler or a similar tool. Create a new task and set the trigger, action, and conditions as needed.

Scripts are scheduled to run on the first of each month, with each script running an hour after the previous one. The batch files are used to ensure the scripts run in sequence.

### Steps to Schedule Scripts:
Open Task Scheduler.  
Click on "Create Basic Task".  
Name the task and provide a description.  
Select "Monthly" and click "Next".  
Set the start date and time. Ensure the time is set to the desired start time for the first script.  
Select "Monthly" and select all months and the first day of the month.  
For the time, set it an hour after the others.  
Click "Next" and select "Start a program".  
Browse to the batch file you want to run (e.g., `Scheduler_RunCDriveCheck.bat`).  
Click "Next" and then "Finish" to create the task.  
  
Repeat the above steps for each batch file, setting the start time for each subsequent script to be an hour after the previous one.

---
## Changes Made in ACP010
1. Installed PowerShell 7 - `https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi`  
2. Installed MailKit - `https://www.nuget.org/packages/MailKit`  
3. Installed MimeKit - `https://www.nuget.org/packages/MimeKit`  

---
## Script Descriptions and Commands

### ActiveDirectory Scripts
- **ActiveDirectory_AddNewUser.ps1**: Adds a new user to Active Directory.
  ```powershell

  ./ActiveDirectory_AddNewUser.ps1

  ```
- **ActiveDirectory_AddRemoveUserGroups.ps1**: Adds or removes a user from specified groups.
  ```powershell

  ./ActiveDirectory_AddRemoveUserGroups.ps1

  ```
- **ActiveDirectory_DisableUser.ps1**: Disables a user and moves them to a specified OU.
  ```powershell

  ./ActiveDirectory_DisableUser.ps1

  ```
- **ActiveDirectory_GetAllComputers.ps1**: Retrieves all active computers from Active Directory.
  ```powershell

  ./ActiveDirectory_GetAllComputers.ps1

  ```
- **ActiveDirectory_ResetUserPassword.ps1**: Resets a user's password.
  ```powershell

  ./ActiveDirectory_ResetUserPassword.ps1

  ```

### Check Scripts
- **Check_AllInstalledPrograms.ps1**: Checks all installed programs on each computer.
  ```powershell

  ./Check_AllInstalledPrograms.ps1

  ```
- **Check_CDriveUsage.ps1**: Checks the C drive usage on each computer.
  ```powershell

  ./Check_CDriveUsage.ps1

  ```
- **Check_DiskHealth.ps1**: Checks the health of disks on each computer.
  ```powershell

  ./Check_DiskHealth.ps1

  ```
- **Check_InactiveUser.ps1**: Checks for inactive users in Active Directory.
  ```powershell

  ./Check_InactiveUser.ps1

  ```
- **Check_LocalAdmin.ps1**: Checks for the presence of a local admin user on each computer.
  ```powershell

  ./Check_LocalAdmin.ps1

  ```
- **Check_UnavailableComputers.ps1**: Checks for unavailable computers in the domain.
  ```powershell

  ./Check_UnavailableComputers.ps1

  ```
- **Check_WindowsVersion.ps1**: Checks the Windows version on each computer.
  ```powershell

  ./Check_WindowsVersion.ps1

  ```

### Email Scripts
- **Email_DriveUsageWarning.ps1**: Sends an email report for high disk usage.
  ```powershell

  ./Email_DriveUsageWarning.ps1

  ```
- **Email_LocalAdmin.ps1**: Sends an email report for local admin checks.
  ```powershell

  ./Email_LocalAdmin.ps1

  ```
- **Email_WindowsVersionReport.ps1**: Sends an email report for Windows version checks.
  ```powershell

  ./Email_WindowsVersionReport.ps1

  ```
- **Email_DiskHealthReport.ps1**: Sends an email report for disk health checks.
  ```powershell

  ./Email_DiskHealthReport.ps1

  ```

### Misc Scripts
- **Install_AddLocalAdmin.ps1**: Adds a local administrator to a specified computer.
  ```powershell

  ./Install_AddLocalAdmin.ps1

  ```
- **Install_AdduBlockOriginFireFox.ps1**: Installs uBlock Origin extension for Firefox on all computers.
  ```powershell

  ./Install_AdduBlockOriginFireFox.ps1

  ```
- **Uninstall_RemoveSoftware.ps1**: Uninstalls specified software from all computers.
  ```powershell

  ./Uninstall_RemoveSoftware.ps1

  ```

### Logon Scripts
- **Logon_ClearDownloadsFolder.ps1**: Clears the Downloads folder for the current user.
  ```powershell

  ./Logon_ClearDownloadsFolder.ps1

  ```
- **Logon_ClearRecycleBin.ps1**: Clears the Recycle Bin for the current user.
  ```powershell

  ./Logon_ClearRecycleBin.ps1

  ```

### Scheduler Scripts
- **Scheduler_RunCDriveCheck.bat**: Schedules the C drive usage check and sends an email report. Runs `Check_CDriveUsage.ps1` and then `Email_DriveUsageWarning.ps1`.
  ```batch

  ./Scheduler_RunCDriveCheck.bat

  ```
- **Scheduler_RunDiskHealthCheck.bat**: Schedules the disk health check and sends an email report. Runs `Check_DiskHealth.ps1` and then `Email_DiskHealthReport.ps1`.
  ```batch

  ./Scheduler_RunDiskHealthCheck.bat

  ```
- **Scheduler_RunLocalAdminCheck.bat**: Schedules the local admin check and sends an email report. Runs `Check_LocalAdmin.ps1` and then `Email_LocalAdmin.ps1`.
  ```batch

  ./Scheduler_RunLocalAdminCheck.bat

  ```