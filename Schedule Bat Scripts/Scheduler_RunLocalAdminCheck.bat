@echo off

start pwsh.exe -Command "& {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass;
    C:\Users\\Desktop\Powershell\Check\Check_LocalAdmin.ps1;
    C:\Users\\Desktop\Powershell\Email\Email_LocalAdmin.ps1;
}"