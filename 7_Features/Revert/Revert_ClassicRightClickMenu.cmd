@echo off
echo Reverting to default right-click menu...

reg delete "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1

echo Restarting explorer.exe...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo Default right-click menu restored.
pause