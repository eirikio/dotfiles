### Installation

1. Open Powershell and run
```
curl -L -o "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" https://github.com/eirikio/dotfiles/archive/refs/heads/main.zip

```
```
Expand-Archive -Force "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" "C:\Users\$env:USERNAME"
```
```
Rename-Item -Path "C:\Users\$env:USERNAME\dotfiles-main" -NewName "dotfiles"
```
3. Execute the script
```
powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\master-user-bootstrap.ps1
```
# What you get
### Software
* Brave
* Microsoft Powertoys
* Discord
* WinRAR
* SteelSeries.GG
* OBS
* PowerShell 7
* VS Code / Cursor

### Modules
* Oh-My-Posh
* Terminal Icons
* PSWebSearch
* PSReadLine

### Windows Settings Tweaks
* Long Paths
* Show file extensions
* Set Explorer to open 'This PC' by default
* Classic context menu (right click menu)
* Power plan tweaks
* Enables Windows Sandbox
* Disables:
  * Windows Media Player
  * XPS Document Writer
  * Workfolders
* Creates C:\Workspace
* Moves Windows Home button to the left like older Windows versions

### Style Settings
* Oh-My-Posh Space Theme
* Dracula Terminal Theme
* Inconsolata Nerd Font

* Imports PowerShell profile
* Imports Windows Terminal Settings
  * WSL Ubunu as default CLI
