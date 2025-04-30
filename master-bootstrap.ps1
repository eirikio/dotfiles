# master-bootstrap.ps1
# Run this script from a **non-admin PowerShell window**

Write-Host "`n=== Starting Master Bootstrap ===`n"

# --- Check if WSL is already installed ---
$wslList = wsl --list --quiet 2>$null
if ($wslList -notmatch "Ubuntu") {
    Write-Host "Installing WSL + Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "WSL installation triggered. Rebooting..."

    # Schedule bootstrap-windows.ps1 to run after reboot (as admin)
    $bootstrapWin = "$env:USERPROFILE\dotfiles\Scripts\bootstrap-windows.ps1"
    schtasks /Create /TN "BootstrapWindows" /TR "powershell.exe -ExecutionPolicy Bypass -File `"$bootstrapWin`"" /SC ONLOGON /RL HIGHEST /F

    Restart-Computer
    exit
} else {
    Write-Host "Ubuntu is already installed. Skipping WSL install."

    # Schedule bootstrap-windows.ps1 to run (if not already)
    $bootstrapWin = "$env:USERPROFILE\dotfiles\Scripts\bootstrap-windows.ps1"
    schtasks /Create /TN "BootstrapWindows" /TR "powershell.exe -ExecutionPolicy Bypass -File `"$bootstrapWin`"" /SC ONLOGON /RL HIGHEST /F

    Restart-Computer
    exit
}
