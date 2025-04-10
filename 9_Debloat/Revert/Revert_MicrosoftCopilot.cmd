@echo off
echo Reverting Microsoft Copilot settings...

:: Delete policy keys to restore default state (Copilot enabled, no policy set)
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f
reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 1 /f

:: Attempt to reinstall Copilot package (requires admin rights)
echo Attempting to reinstall Copilot...
dism /online /add-package /package-name:Microsoft.Windows.Copilot

echo Done. Please restart your system if necessary.
pause