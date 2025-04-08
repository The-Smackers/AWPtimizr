@echo off
setlocal EnableDelayedExpansion

rem Default CS2 path
set "DEFAULT_PATH=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
set "CONFIG_FILE=%~dp0..\CS2Path.txt"
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
        echo CS2 not found at default location—revert will use default path.
        set "CS2_PATH=!DEFAULT_PATH!"
    )
)

rem UAC elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

rem Revert CS2 graphics setting
echo Reverting CS2 graphics preference...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "!CS2_PATH!" /f
if !errorlevel! equ 0 (
    echo Done! CS2 graphics preference removed.
) else (
    echo No custom preference found—already default.
)
pause
exit /b