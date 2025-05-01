param (
    [string]$Stage = "User"
)

function Elevate-Script {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $logFile = "$env:USERPROFILE\bootstrap-admin.log"
    
    $argList = @(
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", "`"$scriptPath`"",
        "-Stage", "Admin"
    )
    
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $argList -WindowStyle Hidden
    } catch {
        Write-Host "Elevation failed: $_"
        Pause
    }

    exit
}


# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$bootstrapWin = "$dotfilesPath\Scripts\bootstrap-windows.ps1"
$escapedBootstrap = $bootstrapWin.Replace('\', '\\')

if ($Stage -eq "User") {
    Write-Host "`n=== Master Bootstrap: User Stage (Non-Admin) ===`n"

    Write-Host "Installing Spotify..."
    winget install Spotify.Spotify -e
    Write-Host "Spotify installed`n"

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "🔧 Git not found. Installing Git..."
        winget install Git.Git -e
        Write-Host "Git installed`n"
    }

    if (-not (Test-Path $dotfilesPath)) {
        Write-Host "Cloning dotfiles repo..."
        git clone https://github.com/eirikio/dotfiles.git $dotfilesPath
        Write-Host "dotfiles cloned to $dotfilesPath`n"
    }

    $wslList = wsl --list --quiet 2>$null
    if ($wslList -notmatch "Ubuntu") {
        Write-Host "Installing WSL + Ubuntu..."
        wsl --install -d Ubuntu
        Write-Host "WSL installation started"
    } else {
        Write-Host "Ubuntu already installed in WSL"
    }

    Write-Host "`nElevating to admin to schedule Windows bootstrap..."
    Pause
    Elevate-Script
}

elseif ($Stage -eq "Admin") {
    Start-Transcript -Path "$env:USERPROFILE\bootstrap-admin-stage.log" -Append

    Write-Host "`n=== Master Bootstrap: Admin Stage (Elevated) ===`n"

    if (-Not (Test-Path $bootstrapWin)) {
        Write-Host "bootstrap-windows.ps1 not found at $bootstrapWin"
        Pause
        Stop-Transcript
        exit 1
    }

    $result = schtasks /Create `
        /TN "BootstrapWindows" `
        /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$escapedBootstrap`"" `
        /SC ONLOGON `
        /F

    Write-Host "`nScheduled task result:"
    Write-Host $result

    Write-Host "Task created. Press Enter to reboot or Ctrl+C to cancel..."
    Pause
    Stop-Transcript
    Restart-Computer
}
