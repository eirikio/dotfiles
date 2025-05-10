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

$wslList = wsl --list 2>$null
if ($wslList -notmatch "Ubuntu") {
    Write-Host "Installing WSL + Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "WSL installation started"
} else {
    Write-Host "Ubuntu already installed in WSL"
}

#Enable WSL
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -WarningAction SilentlyContinue


$wslAction = New-ScheduledTaskAction -Execute "wsl.exe -d Ubuntu"
$wslTrigger = New-ScheduledTaskTrigger -AtLogOn
$wslPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME

Register-ScheduledTask -Action $wslAction -Trigger $wslTrigger -Principal $wslPrincipal -TaskName "FinishUbuntuSetup" -Force


$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$adminLoader`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "RunAfterReboot" -Force

schtasks /Run /TN "FinishUbuntuSetup"
schtasks /Run /TN "RunAfterReboot"

Pause
Restart-Computer -Force
