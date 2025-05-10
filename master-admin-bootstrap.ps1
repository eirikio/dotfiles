# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$bootstrapWin = "$dotfilesPath\Scripts\bootstrap-windows.ps1"
#$escapedBootstrap = $bootstrapWin.Replace('\', '\\')

function Elevate-Script {
    param ($scriptPath)
    $argList = @(
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", $scriptPath,
        "-Stage", "Admin"
    )

    try {
        Write-Host "`nLaunching elevated script..."
          Start-Process "cmd.exe" -Verb RunAs -ArgumentList "/c start powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`" -Stage Admin"
    } catch {
        Write-Host "Elevation failed: $_"
        Pause
    }

     exit
}

Elevate-Script -scriptPath $bootstrapWin
