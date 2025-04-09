@echo off
setlocal EnableDelayedExpansion
echo is on

rem UAC elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/k cd /d %~dp0 && %~nx0' -Verb RunAs"
    exit /b
)

echo Starting TerminalTanks Tweaks...

rem CPU type detection
set "CPU_FILE=%~dp0CPUType.txt"
set "CPU_TYPE="
if exist "!CPU_FILE!" (
    set /p CPU_TYPE=<"!CPU_FILE!"
    if /i "!CPU_TYPE!"=="Intel" (
        echo Using saved CPU type: Intel
    ) else if /i "!CPU_TYPE!"=="AMD" (
        echo Using saved CPU type: AMD
    ) else (
        set "CPU_TYPE="
        echo Invalid CPU type in CPUType.txt, detecting...
    )
)

if not defined CPU_TYPE (
    echo Detecting CPU...
    for /f "tokens=2 delims==" %%A in ('wmic cpu get manufacturer /value ^| find "Manufacturer="') do set "CPU_MFR=%%A"
    if /i "!CPU_MFR:~0,5!"=="Intel" (
        set "CPU_TYPE=Intel"
        echo Detected Intel CPU.
    ) else if /i "!CPU_MFR:~0,3!"=="AMD" (
        set "CPU_TYPE=AMD"
        echo Detected AMD CPU.
    ) else (
        echo Unknown CPU manufacturer: !CPU_MFR!. Defaulting to AMD.
        set "CPU_TYPE=AMD"
    )
    echo !CPU_TYPE!>"!CPU_FILE!"
)

rem Count total files to process (excluding keyboard choice)
set "TOTAL_FILES=0"
set "PROCESSED_FILES=0"
echo Scanning subfolders...

rem Non-CPU/Input folders
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" (
        for %%F in ("%%D\*.reg" "%%D\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set "SKIP=0"
            if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
            if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
            if "!SKIP!"=="0" (
                set /a TOTAL_FILES+=1
                <nul set /p "=[32mFound: %%F[0m" & echo.
            )
        )
    )
)

rem CPU folder
set "CPU_PATH=%~dp01_CPU\!CPU_TYPE!"
if exist "!CPU_PATH!\" (
    for %%F in ("!CPU_PATH!\*.reg" "!CPU_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a TOTAL_FILES+=1
            <nul set /p "=[32mFound: %%F[0m" & echo.
        )
    )
)

rem Input folder (Mouse only, Keyboard handled separately)
set "MOUSE_PATH=%~dp04_Input\Mouse"
if exist "!MOUSE_PATH!\" (
    for %%F in ("!MOUSE_PATH!\*.reg" "!MOUSE_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a TOTAL_FILES+=1
            <nul set /p "=[32mFound: %%F[0m" & echo.
        )
    )
)

rem Add 1 for the keyboard choice
set /a TOTAL_FILES+=1

if !TOTAL_FILES! equ 0 (
    echo No tweak files found in subfolders. Exiting...
    pause
    exit /b 1
)

rem Process files with user prompts
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" (
        echo Entering folder: %%~nxD
        for %%F in ("%%D\*.reg" "%%D\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set "SKIP=0"
            if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
            if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
            if "!SKIP!"=="0" (
                set /a PROCESSED_FILES+=1
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME![0m" & echo.
                :prompt_user
                set "CHOICE="
                <nul set /p "=Execute [32m(e)[0m or Skip [31m(s)[0m? "
                set /p "CHOICE="
                if /i "!CHOICE!"=="e" (
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                    if /i "%%~xF"==".reg" (
                        reg import "%%F" >nul 2>&1
                    ) else (
                        call "%%F"
                    )
                    if !errorlevel! equ 0 (
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    ) else (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                    )
                ) else if /i "!CHOICE!"=="s" (
                    <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                ) else (
                    echo Invalid choice. Enter e or s.
                    goto :prompt_user
                )
            )
        )
    )
)

if exist "!CPU_PATH!\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!
    for %%F in ("!CPU_PATH!\*.reg" "!CPU_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a PROCESSED_FILES+=1
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME![0m" & echo.
            :prompt_user_cpu
            set "CHOICE="
            <nul set /p "=Execute [32m(e)[0m or Skip [31m(s)[0m? "
            set /p "CHOICE="
            if /i "!CHOICE!"=="e" (
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                if /i "%%~xF"==".reg" (
                    reg import "%%F" >nul 2>&1
                ) else (
                    call "%%F"
                )
                if !errorlevel! equ 0 (
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                )
            ) else if /i "!CHOICE!"=="s" (
                <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
            ) else (
                echo Invalid choice. Enter e or s.
                goto :prompt_user_cpu
            )
        )
    )
)

if exist "!MOUSE_PATH!\" (
    echo Entering folder: 4_Input\Mouse
    for %%F in ("!MOUSE_PATH!\*.reg" "!MOUSE_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a PROCESSED_FILES+=1
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME![0m" & echo.
            :prompt_user_mouse
            set "CHOICE="
            <nul set /p "=Execute [32m(e)[0m or Skip [31m(s)[0m? "
            set /p "CHOICE="
            if /i "!CHOICE!"=="e" (
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                if /i "%%~xF"==".reg" (
                    reg import "%%F" >nul 2>&1
                ) else (
                    call "%%F"
                )
                if !errorlevel! equ 0 (
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                )
            ) else if /i "!CHOICE!"=="s" (
                <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
            ) else (
                echo Invalid choice. Enter e or s.
                goto :prompt_user_mouse
            )
        )
    )
)

rem Keyboard selection
set "KEYBOARD_PATH=%~dp04_Input\Keyboard"
if exist "!KEYBOARD_PATH!\" (
    echo Entering folder: 4_Input\Keyboard
    set /a PROCESSED_FILES+=1
    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Selecting keyboard tweak...
    echo What kind of Keyboard do you have?
    echo 1: Low End
    echo 2: Mid Tier
    echo 3: High End
    echo 4: Wooting 1000hz
    echo 5: Wooting 8000hz
    echo 6: Other 8000hz
    set "KB_CHOICE="
    set /p "KB_CHOICE=Enter choice (1-6): "
    if "!KB_CHOICE!"=="1" (
        set "KB_FILE=!KEYBOARD_PATH!\1_Low_End_Keyboard.reg"
        set "FILE_NAME=1_Low_End_Keyboard.reg"
    ) else if "!KB_CHOICE!"=="2" (
        set "KB_FILE=!KEYBOARD_PATH!\2_Mid_Tier_Keyboard.reg"
        set "FILE_NAME=2_Mid_Tier_Keyboard.reg"
    ) else if "!KB_CHOICE!"=="3" (
        set "KB_FILE=!KEYBOARD_PATH!\3_High_End_Keyboard.reg"
        set "FILE_NAME=3_High_End_Keyboard.reg"
    ) else if "!KB_CHOICE!"=="4" (
        set "KB_FILE=!KEYBOARD_PATH!\4_Wooting_Fullsized_Keyboard.reg"
        set "FILE_NAME=4_Wooting_Fullsized_Keyboard.reg"
    ) else if "!KB_CHOICE!"=="5" (
        set "KB_FILE=!KEYBOARD_PATH!\5_Wooting_Latest_Keyboard.reg"
        set "FILE_NAME=5_Wooting_Latest_Keyboard.reg"
    ) else if "!KB_CHOICE!"=="6" (
        set "KB_FILE=!KEYBOARD_PATH!\6_8000hz_Keyboards.reg"
        set "FILE_NAME=6_8000hz_Keyboards.reg"
    ) else (
        echo Invalid choice. Skipping keyboard tweak.
        set "KB_FILE="
    )
    if defined KB_FILE (
        if exist "!KB_FILE!" (
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
            reg import "!KB_FILE!" >nul 2>&1
            if !errorlevel! equ 0 (
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
            ) else (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
            )
        ) else (
            echo [!PROCESSED_FILES!/!TOTAL_FILES!] File not found: !FILE_NAME!
        )
    )
)

echo All tweaks processed! Reboot recommended.
pause
exit /b