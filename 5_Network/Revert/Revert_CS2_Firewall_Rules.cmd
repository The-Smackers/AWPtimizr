@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

echo Removing CS2 firewall rules...
netsh advfirewall firewall delete rule name="CS2 - Inbound"
netsh advfirewall firewall delete rule name="CS2 - Outbound"
echo Done! Rules removed.
pause