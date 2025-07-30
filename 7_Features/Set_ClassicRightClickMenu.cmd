@echo off
echo Setting classic right-click menu...

reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1

echo Restarting explorer.exe...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo Classic right-click menu enabled.
pause