Import-Module "oh-my-posh"
Import-Module "posh-git"
Import-Module "Terminal-Icons"
Import-Module "PSReadLine"

Set-PoshPrompt -Theme "$env:USERPROFILE\.oh-my-posh-custom-theme.omp.json"

Set-PSReadlineOption -BellStyle "None"
Set-PSReadLineOption -PredictionSource "History"
Set-PSReadLineKeyHandler -Chord "Tab" -Function "MenuComplete"

Set-PSReadLineOption -Colors @{
    "InlinePrediction" = [ConsoleColor]::DarkGray
}

Write-Host ""
$timenow = get-date
$timecomparisonMorning = Get-Date -Hour 12 -Minute 0
$timecomparisonEvening = Get-Date -Hour 20 -Minute 0

if ($timenow.TimeOfDay -lt $timecomparisonMorning.TimeOfDay)
{
	Write-Host "GM, $env:USERNAME!" -ForegroundColor Green
}
elseif ($timenow.TimeOfDay -gt $timecomparisonEvening.TimeOfDay)
{
	Write-Host "Good evening, $env:USERNAME!" -ForegroundColor Green
}
else
{
	Write-Host "Greetings, $env:USERNAME!" -ForegroundColor Green
}
Write-Host "Today is: $(Get-Date)" -ForegroundColor White
Write-Host ""
Write-Host "PowerShell = I'm managing my Windows computer." -ForegroundColor Blue
Write-Host "wsl = I'm in Linux, doing my dev work." -ForegroundColor Blue
Write-Host ""
Write-Host "$ commands - Command line cheatsheet" -ForegroundColor Cyan
Write-Host "$ aliases - View list of aliases" -ForegroundColor Cyan
Write-Host "$ wsl - Oh My Zsh" -ForegroundColor Cyan
Write-Host ""

# Aliases & Functions
#function commands {
#    Start-Process "$env:USERPROFILE\CheatSheet\index.html"
#}
#function codecommands {
#    code $env:USERPROFILE\CheatSheet\index.html
#}

function wslhome { wsl.exe ~ }
