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

# --- Tweak Windows Settings ---
Write-Host "Tuning Windows settings..."
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWord -Force
powercfg /hibernate off

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

# --- Install WSL + Ubuntu (non-admin only) ---
#if (-not $isAdmin) {
#    Write-Host "Checking for WSL..."
#    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
#        Write-Host "WSL command not found. Your system might not support it."
#        exit 1
#    }

#    $wslList = wsl --list --quiet 2>$null
#    if ($wslList -notmatch "Ubuntu") {
#        Write-Host "Installing WSL + Ubuntu..."
#        wsl --install -d Ubuntu
#        Write-Host "Ubuntu installation started. Reboot when prompted."
#        Pause
#        exit 0
#    } else {
#        Write-Host "Ubuntu already installed in WSL"
#    }
#} else {
#    Write-Host "Skipping WSL installation (requires non-admin context)."
#}

Write-Host "`n=== Windows Bootstrap Completed ===`n"

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
