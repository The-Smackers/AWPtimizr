@echo off
setlocal EnableDelayedExpansion

rem Default CS2 path
set "DEFAULT_PATH=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
set "CONFIG_FILE=!SUMMARY_DIR!\CS2Path.txt"
set "CS2_PATH="

rem Check if saved path exists
if exist "!CONFIG_FILE!" (
    set /p CS2_PATH=<"!CONFIG_FILE!"
    if exist "!CS2_PATH!" (
        echo Using saved CS2 path: !CS2_PATH!
    ) else (
        set "CS2_PATH="
        echo Saved path not found, checking default...
    )
)

rem Check default path if no saved path
if not defined CS2_PATH (
    if exist "!DEFAULT_PATH!" (
        set "CS2_PATH=!DEFAULT_PATH!"
        echo Using default CS2 path: !CS2_PATH!
    ) else (
        echo CS2 not found at default location.
        call :GetCS2Path
    )
)

rem Exit if no path set
if not defined CS2_PATH (
    echo Failed to locate cs2.exe. Exiting...
    pause
    exit /b 1
)

rem Save path to config file in root
echo !CS2_PATH!>"!CONFIG_FILE!"

rem UAC elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

rem Check if rules already exist
set "INBOUND_EXISTS="
set "OUTBOUND_EXISTS="
for /f "tokens=1,2" %%A in ('netsh advfirewall firewall show rule name^="CS2 - Inbound"') do (
    if "%%A %%B"=="Rule Name:" set "INBOUND_EXISTS=1"
)
for /f "tokens=1,2" %%A in ('netsh advfirewall firewall show rule name^="CS2 - Outbound"') do (
    if "%%A %%B"=="Rule Name:" set "OUTBOUND_EXISTS=1"
)

if defined INBOUND_EXISTS if defined OUTBOUND_EXISTS (
    echo CS2 firewall rules already exist. Skipping...
    if defined DEFAULT_CHOICE if /i "!DEFAULT_CHOICE!"=="" (
        pause
    )
    exit /b 0
)

rem Add firewall rules
echo Adding CS2 firewall rules...
netsh advfirewall firewall add rule name="CS2 - Inbound" dir=in action=allow program="!CS2_PATH!" enable=yes
netsh advfirewall firewall add rule name="CS2 - Outbound" dir=out action=allow program="!CS2_PATH!" enable=yes
echo Done! Rules applied for cs2.exe at !CS2_PATH!.
if defined DEFAULT_CHOICE if /i "!DEFAULT_CHOICE!"=="" (
    pause
)
exit /b

:GetCS2Path
echo Please locate 'Counter-Strike Global Offensive\game\bin\win64\cs2.exe'...
for /f "delims=" %%I in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dlg = New-Object System.Windows.Forms.OpenFileDialog; $dlg.Filter = 'CS2 Executable (cs2.exe)|cs2.exe'; $dlg.InitialDirectory = 'C:\Program Files (x86)\Steam\steamapps\common'; $dlg.Title = 'Select cs2.exe'; if ($dlg.ShowDialog() -eq 'OK') { $dlg.FileName } else { '' }"') do set "CS2_PATH=%%I"
if not defined CS2_PATH (
    echo No file selected.
) else if not "!CS2_PATH:cs2.exe=!"=="!CS2_PATH!" (
    echo Found: !CS2_PATH!
) else (
    echo Selected file is not cs2.exe. Try again.
    set "CS2_PATH="
    call :GetCS2Path
)
goto :eof