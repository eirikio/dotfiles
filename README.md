1. Download the repo to your Downloads folder

3. Run these commands in PowerShell
```
Expand-Archive -Force "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" "C:\Users\$env:USERNAME"
```
```
Rename-Item -Path "C:\Users\$env:USERNAME\dotfiles-main" -NewName "dotfiles"
```
3. Execute the script
```
powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\master-user-bootstrap.ps1
```

