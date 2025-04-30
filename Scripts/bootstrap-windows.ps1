Write-Host "`n=== Running Windows Bootstrap Script ===`n"

# --- Ensure Git is installed before anything else ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing Git for Windows..."
    winget install Git.Git -e
    Write-Host "Git installed."

    # Refresh PATH so Git is immediately available
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git is still not available. Please restart PowerShell and rerun this script."
        exit 1
    }
}

# --- Define dotfiles path ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"

# --- Clone dotfiles repo if not already present ---
if (-not (Test-Path $dotfilesPath)) {
    Write-Host "Cloning dotfiles repo..."
    git clone https://github.com/eirikio/dotfiles.git $dotfilesPath

    if (-not (Test-Path $dotfilesPath)) {
        Write-Host "Failed to clone dotfiles repo. Check your internet connection or the repo URL."
        exit 1
    }
    Write-Host "dotfiles cloned to $dotfilesPath"
}

# --- Install Applications via Winget ---
$apps = @(
    "Microsoft.PowerToys",
    "Brave.Brave",
    "Git.Git",
    "Microsoft.WindowsTerminal",
    "Discord.Discord",
    "Delugia.Nerd.Font"
)

# Skip Spotify if running elevated
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    $apps += "Spotify.Spotify"
} else {
    Write-Host "Skipping Spotify install (can't run in Administrator context)."
}

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id=$app -e
}

# --- Tweak Windows Settings ---
Write-Host "Tuning Windows settings..."
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWord -Force
powercfg /hibernate off

# --- Set PowerShell Profile from Dotfiles ---
$sourceProfile = "$dotfilesPath\powershell\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE

if (Test-Path $sourceProfile) {
    Copy-Item $sourceProfile $targetProfile -Force
    Write-Host "PowerShell profile copied from dotfiles"
} else {
    Write-Host "PowerShell profile not found in dotfiles"
}

# --- Apply Windows Terminal settings.json ---
#$terminalJsonSource = "$dotfilesPath\terminal\settings.json"
#$terminalJsonDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

#if (Test-Path $terminalJsonDest) {
#    Copy-Item $terminalJsonDest "$terminalJsonDest.bak" -Force
#    Write-Host "Backed up existing Windows Terminal settings"
#}

#if (Test-Path $terminalJsonSource) {
#    (Get-Content $terminalJsonSource) -replace '__USERNAME__', $env:USERNAME | Set-Content $terminalJsonDest
#    Write-Host "Applied Windows Terminal settings from dotfiles"
#} else {
#    Write-Host "Terminal settings.json not found in dotfiles"
#}

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

# --- Optionally remove the dotfiles repo ---
try {
    Remove-Item -Recurse -Force $dotfilesPath
    Write-Host "Removed dotfiles repo after setup"
} catch {
    Write-Host "Failed to remove dotfiles repo: $_"
}

Write-Host "`n=== Windows Bootstrap Completed ===`n"
