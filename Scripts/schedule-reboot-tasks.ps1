# Auto-elevate if not running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`nScheduling admin and WSL tasks to run after reboot..."

# Paths
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$adminLoader = "$dotfilesPath\master-admin-bootstrap.ps1"
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# --- Enable WSL Task / Kan fjernes ---
$mwslAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`""
$mwslTrigger = New-ScheduledTaskTrigger -AtLogOn
$mwslPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -Action $mwslAction -Trigger $mwslTrigger -Principal $mwslPrincipal -TaskName "EnableMWSL" -Force

# --- Finish Ubuntu Setup ---
$wslAction = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-d Ubuntu"
$wslTrigger = New-ScheduledTaskTrigger -AtLogOn
$wslTrigger.Delay = "PT10S"  # 10-second delay (ISO 8601 format)
$wslPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive
Register-ScheduledTask -Action $wslAction -Trigger $wslTrigger -Principal $wslPrincipal -TaskName "FinishUbuntuSetup" -Force

# --- Admin Bootstrap Task ---
$adminAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$adminLoader`""
$adminTrigger = New-ScheduledTaskTrigger -AtLogOn
$adminPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -Action $adminAction -Trigger $adminTrigger -Principal $adminPrincipal -TaskName "RunAfterReboot" -Force

Write-Host "`nTasks registered. They will run on next login."
