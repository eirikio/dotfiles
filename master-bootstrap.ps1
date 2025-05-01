param (
    [string]$Stage = "User"
)

function Elevate-Script {
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -Stage Admin"
    exit
}

# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$bootstrapWin = "$dotfilesPath\Scripts\bootstrap-windows.ps1"
$escapedBootstrap = $bootstrapWin.Replace('\', '\\')

# --- STAGE 1: NON-ADMIN ---
if ($Stage -eq "User") {
    Write-Host "`n=== Master Bootstrap: User Stage (Non-Admin) ===`n"

    # Spotify (fails in admin mode)
    Write-Host "Installing Spotify..."
    winget install Spotify.Spotify -e
    Write-Host "Spotify installed`n"

    # Git (if missing)
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git not found. Installing Git..."
        winget install Git.Git -e
        Write-Host "Git installed`n"
    }

    # Clone dotfiles repo
    if (-not (Test-Path $dotfilesPath)) {
        Write-Host "Cloning dotfiles repo..."
        git clone https://github.com/eirikio/dotfiles.git $dotfilesPath
        Write-Host "dotfiles cloned to $dotfilesPath`n"
    }

    # WSL (Ubuntu)
    $wslList = wsl --list --quiet 2>$null
    if ($wslList -notmatch "Ubuntu") {
        Write-Host "Installing WSL + Ubuntu..."
        wsl --install -d Ubuntu
        Write-Host "WSL installation started (may require reboot)"
    } else {
        Write-Host "Ubuntu already installed in WSL"
    }

    # Elevate for task scheduling
    Write-Host "`nElevating to admin to schedule Windows bootstrap..."
    Pause
    Elevate-Script
}

# --- STAGE 2: ADMIN ---
elseif ($Stage -eq "Admin") {
    Write-Host "`n=== Master Bootstrap: Admin Stage (Elevated) ===`n"

    # Create Windows bootstrap task
    schtasks /Create `
        /TN "BootstrapWindows" `
        /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$escapedBootstrap`"" `
        /SC ONLOGON `
        /F

    Write-Host "Scheduled 'bootstrap-windows.ps1' to run on next login."
    Write-Host "`nPress Enter to reboot or Ctrl+C to cancel..."
    Pause
    Restart-Computer
}
