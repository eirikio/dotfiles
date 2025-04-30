1. Open Terminal as normal
```
wsl --install -d Ubuntu
```

2. Reboot PC

3. Open Terminal as admin
```
$ Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
powershell.exe -ExecutionPolicy Bypass -File .$env:USERPROFILE\Desktop\master-bootstrap.ps1
```
