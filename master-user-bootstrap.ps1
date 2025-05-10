param (
    [string]$Stage = "User"
)

# --- Shared ---
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$bootstrapWin = "$dotfilesPath\Scripts\bootstrap-windows.ps1"
$escapedBootstrap = $bootstrapWin.Replace('\', '\\')

# function Elevate-Script {
#     param ($scriptPath)
#     $argList = @(
#         "-ExecutionPolicy", "Bypass",
#         "-NoProfile",
#         "-File", $scriptPath,
#         "-Stage", "Admin"
#     )

#     try {
#         Write-Host "`nLaunching elevated script..."
#         Start-Process "cmd.exe" -Verb RunAs -ArgumentList "/c start powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`" -Stage Admin"
#     } catch {
#         Write-Host "Elevation failed: $_"
#         Pause
#     }

#     exit
# }

# --- STAGE 1: NON-ADMIN ---
# if ($Stage -eq "User") {

        param ($scriptPath)
        $argList = @(
            "-ExecutionPolicy", "Bypass",
            "-NoProfile",
            "-File", $scriptPath,
            "-Stage", "Admin"
        )

        Write-Host $scriptPath
    
#     Write-Host "`n=== Master Bootstrap: User Stage (Non-Admin) ===`n"

#     Write-Host "Installing Spotify..."
#     winget install --id=Spotify.Spotify --exact --accept-source-agreements
#     Write-Host "Spotify installed`n"

#     if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
#         Write-Host "Git not found. Installing Git..."
#         winget install Git.Git -e
#         Write-Host "Git installed`n"

#         $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
#                     [System.Environment]::GetEnvironmentVariable("PATH", "User")
#     }



#     if (-not (Test-Path $dotfilesPath)) {
#         Write-Host "Cloning dotfiles repo..."
#         git clone https://github.com/eirikio/dotfiles.git $dotfilesPath
#         Write-Host "dotfiles cloned to $dotfilesPath`n"
#     }

#     $wslList = wsl --list 2>$null
#     if ($wslList -notmatch "Ubuntu") {
#         Write-Host "Installing WSL + Ubuntu..."
#         wsl --install -d Ubuntu
#         Write-Host "WSL installation started"
#     } else {
#         Write-Host "Ubuntu already installed in WSL"
#     }

#     #Enable WSL
#     Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -WarningAction SilentlyContinue

#     Start-Process "cmd.exe" -Verb RunAs -ArgumentList "/c start powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`" -Stage Admin"

#     # Schedule bootstrap-windows.ps1 to run from powershell after reboot
# $   $adminBoot = Start-Process "cmd.exe" -Verb RunAs -ArgumentList "/c start powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`" -Stage Admin"
#     schtasks /Create /TN "BootstrapWindows" /TR $winBootstrap /SC ONLOGON /RL LIMITED /DELAY 0001:30 /F

    # Write-Host "`nElevating to admin to schedule Windows bootstrap..."
    # Pause
    # Elevate-Script -scriptPath $bootstrapWin
# }

# Schedule bootstrap-windows.ps1 to run from powershell after reboot
# $winBootstrap = "powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\Scripts\bootstrap-windows.ps1"
# schtasks /Create /TN "BootstrapWindows" /TR $winBootstrap /SC ONLOGON /RL LIMITED /DELAY 0001:30 /F

# --- STAGE 2: ADMIN ---
# elseif ($Stage -eq "Admin") {
#     Start-Transcript -Path "$env:USERPROFILE\bootstrap-admin-stage.log" -Append
#     Write-Host "`n=== Master Bootstrap: Admin Stage (Elevated) ===`n"

#     if (-Not (Test-Path $bootstrapWin)) {
#         Write-Host "bootstrap-windows.ps1 not found at $bootstrapWin"
#         Pause
#         Stop-Transcript
#         exit 1
#     }

#     Write-Host "Creating scheduled task for bootstrap-windows.ps1..."

#     $result = schtasks /Create `
#         /TN "BootstrapWindows" `
#         /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$escapedBootstrap`"" `
#         /SC ONLOGON `
#         /F

#     # Schedule bootstrap-windows.ps1 to run from powershell after reboot
#     $winBootstrap = "powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\Scripts\bootstrap-windows.ps1"
#     schtasks /Create /TN "BootstrapWindows" /TR $winBootstrap /SC ONLOGON /RL LIMITED /DELAY 0001:30 /F

#     Write-Host "`nScheduled task result:"
#     Write-Host $result

#     Write-Host "`nTask created. Press Enter to reboot or Ctrl+C to cancel..."
#     Pause
#     Stop-Transcript
#     Restart-Computer
# }
