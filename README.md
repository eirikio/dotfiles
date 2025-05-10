1. Save master-bootstrap.ps1 to Desktop

2. Open Terminal and paste this to move the master script to C:\Users\<username>\
```
Move-Item "C:\Users\$env:USERNAME\Desktop\master-bootstrap.ps1" "C:\Users\$env:USERNAME\"
```

3. Run the script with this
```
powershell.exe -ExecutionPolicy Bypass -File .\master-bootstrap.ps1
```

Move-Item "C:\Users\$env:USERNAME\Downloads\dotfiles\" "C:\Users\$env:USERNAME\"
powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\master-user-bootstrap.ps1
