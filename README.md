1. Download the dotfiles repo to your Downloads folder (default path for downloaded files).

3. Run these commands in PowerShell
```
Expand-Archive -Force "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" "C:\Users\$env:USERNAME\dotfiles"
```

3. Execute the script
```
powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\master-user-bootstrap.ps1
```
