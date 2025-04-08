@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)
  
echo Enable Dynamic Tick
echo Enable High Precision Event Timer (HPET)
echo Enable Synthetic Timers
@echo 
bcdedit /deletevalue disabledynamictick
bcdedit /set useplatformclock yes
bcdedit /deletevalue useplatformtick
echo Done! Reboot required.
pause