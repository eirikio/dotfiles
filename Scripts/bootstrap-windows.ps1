# bootstrap-windows.ps1
Write-Host "=== Running Windows Bootstrap Script ==="

# Install PowerToys
winget install Microsoft.PowerToys -e --id Microsoft.PowerToys

# Install Brave Browser
winget install Brave.Brave -e

# Optional: Uninstall Microsoft Edge (Edge is deeply integrated; uninstall is discouraged)
# winget uninstall Microsoft.Edge -e

# Install Git for Windows (optional if you just use WSL Git)
winget install Git.Git -e

# Install Notepad++ (optional)
# winget install Notepad++.Notepad++ -e

# Install Windows Terminal (usually preinstalled)
winget install Microsoft.WindowsTerminal -e

# Install Discord
winget install Discord.Discord -e

# Install Spotify
winget install Spotify.Spotify -e

# Install Steam
winget install Valve.Steam -e

# Install Battle.net
winget install Blizzard.BattleNet -e

# Tweak Windows settings (examples)
# Enable long paths
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWord -Force

# Turn off fast startup
powercfg /hibernate off

# Set up Windows Terminal profiles (example using JSON patching)

# Path to settings file
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Backup existing settings
Copy-Item $settingsPath "$settingsPath.bak"

# Load current settings
$json = Get-Content $settingsPath | ConvertFrom-Json

# Define custom WSL profile
$wslProfile = @{
    name = "WSL Ubuntu"
    commandline = "wsl.exe"
    startingDirectory = "//wsl$/Ubuntu/home/$env:USERNAME"
    fontFace = "FiraCode Nerd Font"
    hidden = $false
    colorScheme = "Campbell"
}

# Add WSL profile if not already present
$existing = $json.profiles.list | Where-Object { $_.name -eq "WSL Ubuntu" }
if (-not $existing) {
    $json.profiles.list += $wslProfile
}

# Save back to file
$json | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath -Force

Write-Host "✅ Windows Terminal WSL profile configured"

# === Apply Windows Terminal settings.json ===

# Set your dotfiles path (adjust if different)
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$terminalJsonSource = "$dotfilesPath\terminal\settings.json"
$terminalJsonDest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Backup existing settings
if (Test-Path $terminalJsonDest) {
    Copy-Item $terminalJsonDest "$terminalJsonDest.bak" -Force
    Write-Host "📝 Backed up existing Windows Terminal settings."
}

# Copy new settings
if (Test-Path $terminalJsonSource) {
    Copy-Item $terminalJsonSource $terminalJsonDest -Force
    Write-Host "✅ Applied new Windows Terminal settings from dotfiles."
} else {
    Write-Host "⚠️ settings.json not found at $terminalJsonSource. Skipping..."
}

Write-Host "=== Windows Bootstrap Completed ==="
