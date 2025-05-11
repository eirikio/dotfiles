# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$userLoader = "$dotfilesPath\master-user-bootstrap.ps1"
$adminLoader = "$dotfilesPath\master-admin-bootstrap.ps1"
$bootstrapWin = "$dotfilesPath\Scripts\bootstrap-windows.ps1"

$escapedBootstrap = $bootstrapWin.Replace('\', '\\')
    
Write-Host "`n=== Master Bootstrap: User Stage (Non-Admin) ===`n"

Write-Host "Installing Spotify..."
winget install --id=Spotify.Spotify --exact --accept-source-agreements
Write-Host "Spotify installed`n"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing Git..."
    winget install Git.Git -e
    Write-Host "Git installed`n"

    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

if (-not (Test-Path $dotfilesPath)) {
    Write-Host "Cloning dotfiles repo..."
    git clone https://github.com/eirikio/dotfiles.git $dotfilesPath
    Write-Host "dotfiles cloned to $dotfilesPath`n"
}

#$wslList = wsl --list 2>$null
#if ($wslList -notmatch "Ubuntu") {
    Write-Host "Installing WSL + Ubuntu..."
    wsl --install --no distribution
    wsl --set-default-version 1
    wsl --install -d Ubuntu
    wsl --list --verbose

    Pause
#    Write-Host "WSL installation started"
#} else {
#    Write-Host "Ubuntu already installed in WSL"
#}

# Deactivate if running on VM
# $wslList = wsl --list 2>$null
# if ($wslList -notmatch "Ubuntu") {
#     Write-Host "Installing WSL + Ubuntu..."
#     wsl --install -d Ubuntu
#     Write-Host "WSL installation started"
# } else {
#     Write-Host "Ubuntu already installed in WSL"
# }

#Enable WSL
#Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -WarningAction SilentlyContinue

# Enable WSL at next logon
$mwslAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`""
$mwslTrigger = New-ScheduledTaskTrigger -AtLogOn
$mwslPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -Action $mwslAction -Trigger $mwslTrigger -Principal $mwslPrincipal -TaskName "EnableMWSL" -Force

# Launch WSL
$wslAction = New-ScheduledTaskAction -Execute "wsl.exe -d Ubuntu"
$wslTrigger = New-ScheduledTaskTrigger -AtLogOn -Delay "00:00:5"
$wslPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME
Register-ScheduledTask -Action $wslAction -Trigger $wslTrigger -Principal $wslPrincipal -TaskName "FinishUbuntuSetup" -Force

# Launch admin bootstrap
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$adminLoader`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "RunAfterReboot" -Force

# Kick off
schtasks /Run /TN "RunAfterReboot"
Pause
Restart-Computer -Force
