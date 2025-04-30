Write-Host "=== Running Windows Bootstrap Script ==="

# --- Define dotfiles path ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"

# --- Ensure dotfiles repo is cloned ---
if (-not (Test-Path $dotfilesPath)) {
    Write-Host "⚠️ dotfiles repo not found at $dotfilesPath"
    Write-Host "📦 Cloning from GitHub..."
    git clone https://github.com/eirikio/dotfiles.git $dotfilesPath

    if (-not (Test-Path $dotfilesPath)) {
        Write-Host "❌ Failed to clone dotfiles repo. Exiting..."
        exit 1
    }
}

# --- Install Applications via Winget ---
winget install Microsoft.PowerToys -e --id Microsoft.PowerToys
winget install Brave.Brave -e
winget install Git.Git -e
winget install Microsoft.WindowsTerminal -e
winget install Discord.Discord -e
winget install Spotify.Spotify -e
winget install Valve.Steam -e
winget install Blizzard.BattleNet -e
winget install Delugia.Nerd.Font -e
# winget install Notepad++.Notepad++ -e  # Optional

# --- Tweak Windows Settings ---
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWord -Force
powercfg /hibernate off

# --- Set PowerShell Profile from Dotfiles ---
$sourceProfile = "$dotfilesPath\powershell\Microsoft.PowerShell_profile.ps1"
$targetProfile = $PROFILE

if (Test-Path $sourceProfile) {
    Copy-Item $sourceProfile $targetProfile -Force
    Write-Host "✅ PowerShell profile copied from dotfiles"
} else {
    Write-Host "⚠️ PowerShell profile not found in dotfiles"
}

# --- Apply Windows Terminal settings.json ---
$terminalJsonSource = "$dotfilesPath\terminal\settings.json"
$terminalJsonDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $terminalJsonDest) {
    Copy-Item $terminalJsonDest "$terminalJsonDest.bak" -Force
    Write-Host "📝 Backed up existing Windows Terminal settings"
}

if (Test-Path $terminalJsonSource) {
    (Get-Content $terminalJsonSource) -replace '__USERNAME__', $env:USERNAME | Set-Content $terminalJsonDest
    Write-Host "✅ Applied Windows Terminal settings from dotfiles"
} else {
    Write-Host "⚠️ Terminal settings.json not found in dotfiles"
}

# --- Copy CheatSheet to Windows home directory ---
$cheatSheetSource = "$dotfilesPath\CheatSheet"
$cheatSheetTarget = "$env:USERPROFILE\CheatSheet"

if (Test-Path $cheatSheetSource) {
    Copy-Item -Recurse -Force $cheatSheetSource $cheatSheetTarget
    Write-Host "✅ Copied CheatSheet to $cheatSheetTarget"
}

# --- Optional: delete dotfiles repo ---
try {
    Remove-Item -Recurse -Force $dotfilesPath
    Write-Host "🧹 Removed dotfiles repo after setup"
} catch {
    Write-Host "⚠️ Failed to remove dotfiles repo: $_"
}

Write-Host "=== ✅ Windows Bootstrap Completed ==="
