# --- Define Paths ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$adminLoader = "$dotfilesPath\master-admin-bootstrap.ps1"
$adminLoaderEscaped = $adminLoader.Replace('"', '""') # Escapes any embedded quotes

# --- Sanity Check ---
if (-not (Test-Path $adminLoader)) {
    Write-Host "ERROR: admin bootstrap script not found at: $adminLoader" -ForegroundColor Red
    exit 1
}

# --- Register Admin Task ---
Write-Host "Registering 'RunAfterReboot' scheduled task..."
schtasks /Create `
    /TN "RunAfterReboot" `
    /TR "powershell.exe -ExecutionPolicy Bypass -File `"$adminLoaderEscaped`"" `
    /SC ONLOGON `
    /DELAY 0000:05 `
    /RL HIGHEST `
    /F

# --- Register WSL Launch Task ---
Write-Host "Registering 'FinishUbuntuSetup' scheduled task..."
schtasks /Create `
    /TN "FinishUbuntuSetup" `
    /TR "wsl.exe -d Ubuntu" `
    /SC ONLOGON `
    /DELAY 0000:10 `
    /RL LIMITED `
    /F

# --- Optional: Run Admin Bootstrap Immediately ---
Write-Host "Launching 'RunAfterReboot' task now..."
schtasks /Run /TN "RunAfterReboot"

# --- Final Prompt ---
Pause
Restart-Computer -Force
