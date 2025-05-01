# master-bootstrap.ps1
# Run this script from a **non-admin PowerShell window**

Write-Host "`n=== Starting Master Bootstrap ===`n"

Write-Host "Installing Spotify..."
winget install Spotify.Spotify -e
Write-Host "Spotify installed"

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

# --- Check if WSL is already installed ---
$wslList = wsl --list --quiet 2>$null
if ($wslList -notmatch "Ubuntu") {
    Write-Host "Installing WSL + Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "WSL installation triggered. Rebooting..."

    # Schedule bootstrap-windows.ps1 to run after reboot (as admin)
    $bootstrapWin = "$env:USERPROFILE\dotfiles\Scripts\bootstrap-windows.ps1"
    $escapedBootstrap = $bootstrapWin.Replace('\', '\\')  # escape backslashes for CMD

    schtasks /Create `
      /TN "BootstrapWindows" `
      /TR "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$escapedBootstrap`"" `
      /SC ONLOGON `
      /RL HIGHEST `
      /RU "$env:USERNAME" `
      /F

    Restart-Computer
    exit
} else {
    Write-Host "Ubuntu is already installed. Skipping WSL install."

    # Schedule bootstrap-windows.ps1 to run (if not already)
    $bootstrapWin = "$env:USERPROFILE\dotfiles\Scripts\bootstrap-windows.ps1"
    $escapedBootstrap = $bootstrapWin.Replace('\', '\\')  # escape backslashes for CMD

    schtasks /Create `
      /TN "BootstrapWindows" `
      /TR "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$escapedBootstrap`"" `
      /SC ONLOGON `
      /RL HIGHEST `
      /RU "$env:USERNAME" `
      /F

    Restart-Computer
    exit
}
