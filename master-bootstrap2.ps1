# Schedule bootstrap-windows.ps1 to run from powershell after reboot
$winBootstrap = "powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\Scripts\bootstrap-windows.ps1"
schtasks /Create /TN "BootstrapWindows" /TR $winBootstrap /SC ONLOGON /RL LIMITED /DELAY 0001:30 /F
