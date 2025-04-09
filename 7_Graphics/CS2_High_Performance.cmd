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

rem Set CS2 to High performance
echo Setting CS2 to High performance...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "!CS2_PATH!" /t REG_SZ /d "GpuPreference=2;" /f
if !errorlevel! equ 0 (
    echo Done! CS2 set to High performance at !CS2_PATH!.
     if defined DEFAULT_CHOICE if /i "!DEFAULT_CHOICE!"=="" (
        pause
    )
) else (
    echo Failed to set graphics preference. Check admin rights.
    pause
    exit /b 1
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