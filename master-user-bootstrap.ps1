# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$userLoader = "$dotfilesPath\master-user-bootstrap.ps1"
$adminLoader = "$dotfilesPath\master-admin-bootstrap.ps1"
$schedulerScript = "$dotfilesPath\Scripts\schedule-reboot-tasks.ps1"

Write-Host "`n=== Master Bootstrap: User Stage (Non-Admin) ===`n"

# --- Install base app ---
Write-Host "Installing Spotify..."
winget install --id=Spotify.Spotify --exact --accept-source-agreements
Write-Host "Spotify installed.`n"

# --- Install Git if missing ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing..."
    winget install Git.Git -e
    Write-Host "Git installed.`n"

    # Refresh PATH in session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

# --- Clone dotfiles ---
if (-not (Test-Path $dotfilesPath)) {
    Write-Host "Cloning dotfiles repo..."
    git clone https://github.com/eirikio/dotfiles.git $dotfilesPath
    Write-Host "Dotfiles cloned to $dotfilesPath.`n"
}

# --- Install WSL + Ubuntu ---
Write-Host "Installing WSL + Ubuntu (WSL1)..."
wsl --set-default-version 1
wsl --install -d Ubuntu
wsl --list --verbose
Write-Host "WSL installation command issued.`n"
Pause

# --- Run post-reboot task scheduler ---
if (Test-Path $schedulerScript) {
    Write-Host "`nScheduling admin and WSL tasks to run after reboot..."
    powershell.exe -ExecutionPolicy Bypass -File $schedulerScript
} else {
    Write-Host "ERROR: Scheduler script not found at $schedulerScript" -ForegroundColor Red
}

# --- Kick off reboot and bootstrap ---
Pause
Restart-Computer -Force
