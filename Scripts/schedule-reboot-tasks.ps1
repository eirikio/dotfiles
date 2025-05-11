# --- Paths ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$adminLoader = "$dotfilesPath\master-admin-bootstrap.ps1"

# --- Enable WSL Feature at next login (admin required) ---
$mwslAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`""
$mwslTrigger = New-ScheduledTaskTrigger -AtLogOn
$mwslPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -Action $mwslAction -Trigger $mwslTrigger -Principal $mwslPrincipal -TaskName "EnableMWSL" -Force

# --- Launch WSL (delay a few seconds) ---
$wslAction = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-d Ubuntu"
$wslTrigger = New-ScheduledTaskTrigger -AtLogOn
$wslTrigger.Delay = "PT10S"
$wslPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME
Register-ScheduledTask -Action $wslAction -Trigger $wslTrigger -Principal $wslPrincipal -TaskName "FinishUbuntuSetup" -Force

# --- Launch elevated admin script ---
$adminAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$adminLoader`""
$adminTrigger = New-ScheduledTaskTrigger -AtLogOn
$adminPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -Action $adminAction -Trigger $adminTrigger -Principal $adminPrincipal -TaskName "RunAfterReboot" -Force

Write-Host "Tasks registered. They will run on next login."
