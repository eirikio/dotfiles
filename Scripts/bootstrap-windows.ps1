Write-Host "`n=== Running Windows Bootstrap Script ===`n"

# --- Define dotfiles path ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"

# --- Install Applications via Winget ---
$apps = @(
    "Microsoft.PowerToys",
    "Brave.Brave",
    "Microsoft.WindowsTerminal",
    "Discord.Discord",
    "RARLab.WinRAR",
    "SteelSeries.GG",
    "OBSProject.OBSStudio",
    "Docker.DockerDesktop",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudioCode"
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id=$app -e
}

Install-Module -Name "oh-my-posh" -Force -AllowClobber
Install-Module -Name "posh-git" -Force -AllowClobber
Install-Module -Name "Terminal-Icons" -Force -AllowClobber
Install-Module -Name "PSWebSearch" -Force -AllowClobber
Install-Module -Name "PSReadLine" -Force -AllowClobber

$modules = @("oh-my-posh", "posh-git", "Terminal-Icons", "PSWebSearch", "PSReadLine")

foreach ($mod in $modules) {
    if (Get-Module -ListAvailable -Name $mod) {
        Write-Host "$mod installed successfully."
    } else {
        Write-Host "Warning: $mod did not install correctly!" -ForegroundColor Red
    }
}

# --- Tweak Windows Settings ---
Write-Host "Tuning Windows settings..."
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWord -Force
powercfg /hibernate off

# Enable showing file extensions
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Set Explorer to open 'This PC' by default
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1

# Classic context menu (right click)
$classicContextKey = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
if (-not (Test-Path $classicContextKey)) {
    New-Item -Path $classicContextKey | Out-Null
}
New-Item -Path "$classicContextKey\InprocServer32" -Force | Out-Null

# Remove recently opened items from JumpList
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

# Power plan tweaks
powercfg -change "disk-timeout-ac" 0
powercfg -change "disk-timeout-dc" 0
powercfg -change "hibernate-timeout-ac" 0
powercfg -change "hibernate-timeout-dc" 0
powercfg -change "standby-timeout-ac" 0
powercfg -change "standby-timeout-dc" 0
powercfg -change "monitor-timeout-ac" 10
powercfg -change "monitor-timeout-dc" 10
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 30
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 30
powercfg /SETACTIVE SCHEME_CURRENT

# Regional format tweaks
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iFirstDayOfWeek" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortDate" -Value "yyyy-MM-dd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sLongDate" -Value "dddd, d MMMM, yyyy"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss"

# Disable unused Windows Features
Disable-WindowsOptionalFeature -FeatureName "WindowsMediaPlayer" -Online -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -FeatureName "Internet-Explorer-Optional-amd64" -Online -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -FeatureName "Printing-XPSServices-Features" -Online -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -FeatureName "WorkFolders-Client" -Online -NoRestart -ErrorAction SilentlyContinue

# Enable Windows Sandbox
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart -ErrorAction SilentlyContinue

$ohMyPoshThemeSource = "$dotfilesPath\style-settings\terminal\.oh-my-posh-custom-theme.omp.json"
$ohMyPoshThemeDest = "$env:USERPROFILE\.oh-my-posh-custom-theme.omp.json"

if (Test-Path $ohMyPoshThemeSource) {
    Copy-Item $ohMyPoshThemeSource $ohMyPoshThemeDest -Force
    Write-Host "Oh My Posh theme copied to $ohMyPoshThemeDest"
}

# --- Set PowerShell Profile from Dotfiles ---
$sourceProfile = "$dotfilesPath\powershell\Microsoft.PowerShell_profile.ps1"
$targetProfile = "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $sourceProfile) {
    Copy-Item $sourceProfile $targetProfile -Force
    Write-Host "PowerShell profile copied from dotfiles"
} else {
    Write-Host "PowerShell profile not found in dotfiles"
}

# --- Apply Windows Terminal settings.json ---
$terminalJsonSource = "$dotfilesPath\style-settings\terminal\settings.json"
$terminalJsonDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $terminalJsonDest) {
    Copy-Item $terminalJsonDest "$terminalJsonDest.bak" -Force
    Write-Host "Backed up existing Windows Terminal settings"
}

if (Test-Path $terminalJsonSource) {
    (Get-Content $terminalJsonSource) -replace '__USERNAME__', $env:USERNAME | Set-Content $terminalJsonDest
    Write-Host "Applied Windows Terminal settings from dotfiles"
} else {
    Write-Host "Terminal settings.json not found in dotfiles"
}

# --- Copy CheatSheet to home directory ---
$cheatSheetSource = "$dotfilesPath\CheatSheet"
$cheatSheetTarget = "$env:USERPROFILE\CheatSheet"

if (Test-Path $cheatSheetSource) {
    Copy-Item -Recurse -Force $cheatSheetSource $cheatSheetTarget
    Write-Host "CheatSheet copied to $cheatSheetTarget"
} else {
    Write-Host "CheatSheet folder not found in dotfiles"
}

# --- Move Windows 11 Start Menu to the left (like classic Windows)
Write-Host "Positioning Start button to the left..."
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                 -Name "TaskbarAl" -Value 0 -PropertyType DWord -Force

Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "`n=== Windows Bootstrap Completed ===`n"

$newPCName = Read-Host "Enter PC name"

if ($newPCName -and ($env:COMPUTERNAME -ne $newPCName)) {
    Write-Host "Renaming PC to $newPCName..."
    Rename-Computer -NewName $newPCName -Force
    Write-Host "PC renamed. A reboot is required to apply changes."
} elseif (-not $newPCName) {
    Write-Host "No PC name entered; skipping rename."
}

# --- Schedule bootstrap-wsl.sh to run from WSL after reboot ---
$wslBootstrap = "wsl.exe bash -c '~/dotfiles/Scripts/bootstrap-wsl.sh'"
schtasks /Create /TN "BootstrapWSL" /TR $wslBootstrap /SC ONLOGON /RL LIMITED /DELAY 0000:30 /F

if (Get-ScheduledTask -TaskName "BootstrapWindows" -ErrorAction SilentlyContinue) {
    schtasks /Delete /TN "BootstrapWindows" /F
    Write-Host "BootstrapWindows task deleted."
} else {
    Write-Host "BootstrapWindows task was not found; skipping delete."
}
Restart-Computer
