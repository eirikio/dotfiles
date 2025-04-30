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

Write-Host "=== Windows Bootstrap Completed ==="
