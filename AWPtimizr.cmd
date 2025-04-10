@echo off
setlocal EnableDelayedExpansion
echo is on

rem Define summary directory for logs and CPU type storage, unique to this machine
set "SUMMARY_DIR=%~dp0Summary_%COMPUTERNAME%"
mkdir "!SUMMARY_DIR!" 2>nul

rem UAC elevation—both apply and revert need admin rights
echo Checking for admin rights...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d %~dp0 && %~nx0' -Verb RunAs" 2>nul
    if !errorlevel! neq 0 (
        echo Error: Failed to elevate privileges. Run as admin manually.
        pause
        exit /b 1
    )
    echo Elevation requested - This window will close. Check for a new admin window.
    timeout /t 2 >nul
    exit /b
)

rem Announce startup
echo Starting TerminalTanks CS2 Tweaks Combined Tool...

rem Set up logging—single log for consistency
set "LOG_FILE=!SUMMARY_DIR!\Optimization_Log.txt"
echo [%DATE% %TIME%] Starting combined tweak/revert tool... >> "!LOG_FILE!"

rem Main menu loop—combined options with light purple color
:menu
cls
echo [95mTerminalTanks CS2 Tweaks Combined Tool[0m
echo [95mCurrent Date: %DATE%[0m
echo.
echo [95m1. Execute TerminalTanks CS2 Tweaks Menu[0m
echo [95m2. Revert TerminalTanks CS2 Tweaks Menu[0m
echo [95m3. Exit[0m
echo.
set "MENU_CHOICE="
<nul set /p "=[95mEnter choice (1-3): [0m"
set /p MENU_CHOICE=""
if "!MENU_CHOICE!"=="1" goto tweaks
if "!MENU_CHOICE!"=="2" goto revert
if "!MENU_CHOICE!"=="3" exit
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

rem CPU detection—shared logic for both tweak and revert
:detect_cpu
set "CPU_FILE=!SUMMARY_DIR!\CPUType.txt"
set "CPU_TYPE="
if exist "!CPU_FILE!" (
    set /p CPU_TYPE=<"!CPU_FILE!"
    if "!CPU_TYPE!"=="" (
        set "CPU_TYPE="
        echo CPUType.txt is empty, detecting...
        echo [%DATE% %TIME%] CPUType.txt is empty, detecting... >> "!LOG_FILE!"
    ) else if /i "!CPU_TYPE!"=="Intel" (
        echo Using saved CPU type: Intel
        echo [%DATE% %TIME%] Using saved CPU type: Intel >> "!LOG_FILE!"
    ) else if /i "!CPU_TYPE!"=="AMD" (
        echo Using saved CPU type: AMD
        echo [%DATE% %TIME%] Using saved CPU type: AMD >> "!LOG_FILE!"
    ) else (
        set "CPU_TYPE="
        echo Invalid CPU type in CPUType.txt, detecting...
        echo [%DATE% %TIME%] Invalid CPU type in CPUType.txt, detecting... >> "!LOG_FILE!"
    )
)
if not defined CPU_TYPE (
    echo Detecting CPU...
    echo [%DATE% %TIME%] Detecting CPU... >> "!LOG_FILE!"
    for /f "tokens=2 delims==" %%A in ('wmic cpu get manufacturer /value ^| find "Manufacturer="') do set "CPU_MFR=%%A"
    if /i "!CPU_MFR:~0,5!"=="Intel" (
        set "CPU_TYPE=Intel"
        echo Detected Intel CPU.
        echo [%DATE% %TIME%] Detected Intel CPU. >> "!LOG_FILE!"
    ) else if /i "!CPU_MFR:~0,3!"=="AMD" (
        set "CPU_TYPE=AMD"
        echo Detected AMD CPU.
        echo [%DATE% %TIME%] Detected AMD CPU. >> "!LOG_FILE!"
    ) else (
        echo Unknown CPU manufacturer: !CPU_MFR!. Defaulting to AMD.
        echo [%DATE% %TIME%] Unknown CPU manufacturer: !CPU_MFR!. Defaulting to AMD. >> "!LOG_FILE!"
        set "CPU_TYPE=AMD"
    )
    echo !CPU_TYPE!>"!CPU_FILE!"
)
goto :eof

rem Registry backup subroutine
:backup_registry
set "ACTION=%1"
set "BACKUP_PATH=%~dp0Backup"
set /p "BACKUP=Create registry backup before !ACTION! tweaks? (y/n): "
if /i "!BACKUP!"=="y" (
    mkdir "!BACKUP_PATH!" 2>nul
    echo Creating backup...
    echo [%DATE% %TIME%] Creating registry backup... >> "!LOG_FILE!"
    set "BACKUP_HKLM=!BACKUP_PATH!\HKLM_SYSTEM_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.reg"
    set "BACKUP_HKCU=!BACKUP_PATH!\HKCU_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.reg"
    if exist "!BACKUP_HKLM!" (
        set /p "OVERWRITE=Backup already exists. Overwrite? (y/n): "
        if /i "!OVERWRITE!"=="y" (
            reg export HKLM\SYSTEM "!BACKUP_HKLM!" /y >nul 2>&1
            reg export HKCU "!BACKUP_HKCU!" /y >nul 2>&1
        ) else (
            echo Skipping backup creation.
            echo [%DATE% %TIME%] Skipped backup creation due to existing files. >> "!LOG_FILE!"
        )
    ) else (
        reg export HKLM\SYSTEM "!BACKUP_HKLM!" /y >nul 2>&1
        reg export HKCU "!BACKUP_HKCU!" /y >nul 2>&1
    )
    echo Backup saved to !BACKUP_PATH!
    echo [%DATE% %TIME%] Backup saved to !BACKUP_PATH! >> "!LOG_FILE!"
)
goto :eof

rem Tweaks application logic
:tweaks
echo Starting tweak application...
echo [%DATE% %TIME%] Starting tweak application... >> "!LOG_FILE!"

call :backup_registry "applying"

rem Execution mode selection with light purple
echo [95mChoose execution mode:[0m
echo [95m1: Prompt for each file (default)[0m
echo [95m2: Execute all automatically[0m
echo [95m3: Skip all automatically[0m
echo [95m4: Simulate all (no changes applied)[0m
<nul set /p "=[95mEnter choice (1-4): [0m"
set /p "MODE="
if "!MODE!"=="2" (set "DEFAULT_CHOICE=e") else if "!MODE!"=="3" (set "DEFAULT_CHOICE=s") else if "!MODE!"=="4" (set "SIMULATE=1" & set "DEFAULT_CHOICE=e") else (set "DEFAULT_CHOICE=" & set "SIMULATE=0")

call :detect_cpu

rem Count tweak files
set "TOTAL_FILES=0"
set "PROCESSED_FILES=0"
set "EXECUTED_FILES=0"
echo Scanning subfolders for tweaks...
echo [%DATE% %TIME%] Scanning subfolders for tweaks... >> "!LOG_FILE!"

for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        for %%F in ("%%D\*.reg" "%%D\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set "SKIP=0"
            if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
            if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
            if "!SKIP!"=="0" (
                set /a TOTAL_FILES+=1
                <nul set /p "=[32mFound: %%F[0m" & echo.
                echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
            )
        )
    )
)

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
            echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
        )
    )
)

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
            echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
        )
    )
)

set /a TOTAL_FILES+=1  rem Keyboard choice

if !TOTAL_FILES! equ 0 (
    echo No tweak files found. Returning to menu...
    echo [%DATE% %TIME%] No tweak files found. >> "!LOG_FILE!"
    timeout /t 2 >nul
    goto menu
)

rem Process tweak files
echo Total tweak files found: !TOTAL_FILES!
echo [%DATE% %TIME%] Total tweak files found: !TOTAL_FILES! >> "!LOG_FILE!"

for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        echo Entering folder: %%~nxD
        echo [%DATE% %TIME%] Entering folder: %%~nxD >> "!LOG_FILE!"
        for %%F in ("%%D\*.reg" "%%D\*.cmd") do (
            call :process_file "%%F" tweak
        )
    )
)

if exist "!CPU_PATH!\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!
    echo [%DATE% %TIME%] Entering folder: 1_CPU\!CPU_TYPE! >> "!LOG_FILE!"
    for %%F in ("!CPU_PATH!\*.reg" "!CPU_PATH!\*.cmd") do (
        call :process_file "%%F" tweak
    )
)

if exist "!MOUSE_PATH!\" (
    echo Entering folder: 4_Input\Mouse
    echo [%DATE% %TIME%] Entering folder: 4_Input\Mouse >> "!LOG_FILE!"
    for %%F in ("!MOUSE_PATH!\*.reg" "!MOUSE_PATH!\*.cmd") do (
        call :process_file "%%F" tweak
    )
)

set "KEYBOARD_PATH=%~dp04_Input\Keyboard"
if exist "!KEYBOARD_PATH!\" (
    call :process_keyboard tweak
)

rem Completion message based on execution
if "!SIMULATE!"=="1" (
    echo Simulation of CS2 Tweaks complete! No changes applied.
    echo [%DATE% %TIME%] Simulation complete! >> "!LOG_FILE!"
) else if !EXECUTED_FILES! gtr 0 (
    echo CS2 Tweaks application complete! Restart recommended.
    echo [%DATE% %TIME%] CS2 Tweaks application complete! Restart recommended. >> "!LOG_FILE!"
) else (
    echo All tweak files skipped. No changes applied.
    echo [%DATE% %TIME%] All tweak files skipped. No changes applied. >> "!LOG_FILE!"
)
timeout /t 2 >nul
pause
goto menu

rem Revert logic
:revert
echo Starting revert application...
echo [%DATE% %TIME%] Starting revert application... >> "!LOG_FILE!"

call :backup_registry "reverting"

call :detect_cpu

rem Execution mode selection with light purple
echo [95mChoose execution mode:[0m
echo [95m1: Prompt for each file (default)[0m
echo [95m2: Execute all automatically[0m
echo [95m3: Skip all automatically[0m
echo [95m4: Simulate all (no changes applied)[0m
<nul set /p "=[95mEnter choice (1-4): [0m"
set /p "MODE="
if "!MODE!"=="2" (set "DEFAULT_CHOICE=e") else if "!MODE!"=="3" (set "DEFAULT_CHOICE=s") else if "!MODE!"=="4" (set "SIMULATE=1" & set "DEFAULT_CHOICE=e") else (set "DEFAULT_CHOICE=" & set "SIMULATE=0")

rem Count revert files
set "TOTAL_FILES=0"
set "PROCESSED_FILES=0"
set "EXECUTED_FILES=0"
echo Scanning revert subfolders...
echo [%DATE% %TIME%] Scanning revert subfolders... >> "!LOG_FILE!"

for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        if exist "%%D\Revert\" (
            for %%F in ("%%D\Revert\*.reg" "%%D\Revert\*.cmd") do (
                set "FILE_NAME=%%~nxF"
                set /a TOTAL_FILES+=1
                <nul set /p "=[32mFound: %%F[0m" & echo.
                echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
            )
        )
    )
)

set "CPU_PATH=%~dp01_CPU\!CPU_TYPE!"
if exist "!CPU_PATH!\Revert\" (
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set /a TOTAL_FILES+=1
        <nul set /p "=[32mFound: %%F[0m" & echo.
        echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
    )
)

for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\Revert\" (
        for %%F in ("!INPUT_PATH!\Revert\*.reg" "!INPUT_PATH!\Revert\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set /a TOTAL_FILES+=1
            <nul set /p "=[32mFound: %%F[0m" & echo.
            echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
        )
    )
)

if !TOTAL_FILES! equ 0 (
    echo No revert files found. Returning to menu...
    echo [%DATE% %TIME%] No revert files found. >> "!LOG_FILE!"
    timeout /t 2 >nul
    goto menu
)

rem Process revert files
echo Total revert files found: !TOTAL_FILES!
echo [%DATE% %TIME%] Total revert files found: !TOTAL_FILES! >> "!LOG_FILE!"

for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        if exist "%%D\Revert\" (
            echo Entering folder: %%~nxD\Revert
            echo [%DATE% %TIME%] Entering folder: %%~nxD\Revert >> "!LOG_FILE!"
            for %%F in ("%%D\Revert\*.reg" "%%D\Revert\*.cmd") do (
                call :process_file "%%F" revert
            )
        )
    )
)

if exist "!CPU_PATH!\Revert\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!\Revert
    echo [%DATE% %TIME%] Entering folder: 1_CPU\!CPU_TYPE!\Revert >> "!LOG_FILE!"
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        call :process_file "%%F" revert
    )
)

for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\Revert\" (
        echo Entering folder: 4_Input\%%S\Revert
        echo [%DATE% %TIME%] Entering folder: 4_Input\%%S\Revert >> "!LOG_FILE!"
        for %%F in ("!INPUT_PATH!\Revert\*.reg" "!INPUT_PATH!\Revert\*.cmd") do (
            call :process_file "%%F" revert
        )
    )
)

rem Completion message based on execution
if "!SIMULATE!"=="1" (
    echo Simulation of revert CS2 tweaks complete! No changes applied.
    echo [%DATE% %TIME%] Simulation complete! >> "!LOG_FILE!"
) else if !EXECUTED_FILES! gtr 0 (
    echo Revert CS2 tweaks application complete! Reboot recommended.
    echo [%DATE% %TIME%] Revert CS2 tweaks application complete! Reboot recommended. >> "!LOG_FILE!"
) else (
    echo All revert files skipped. No changes applied.
    echo [%DATE% %TIME%] All revert files skipped. No changes applied. >> "!LOG_FILE!"
)
timeout /t 2 >nul
pause
goto menu

rem Shared file processing subroutine
:process_file
set "FILE_PATH=%1"
set "MODE_TYPE=%2"
set "FILE_NAME=%~nx1"
set "SKIP=0"
if /i "!MODE_TYPE!"=="tweak" (
    if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
    if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
)
if "!SKIP!"=="0" (
    set /a PROCESSED_FILES+=1
    set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME![0m" & echo.
    echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME! >> "!LOG_FILE!"
    :prompt_user
    if not exist "!FILE_PATH!" (
        echo [%DATE% %TIME%] File missing: !FILE_NAME! >> "!LOG_FILE!"
        <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Missing: !FILE_NAME![0m" & echo.
        goto :eof
    )
    set "CHOICE="
    if defined DEFAULT_CHOICE (
        set "CHOICE=!DEFAULT_CHOICE!"
        echo Auto-choice: !CHOICE! for !FILE_NAME!
    ) else (
        <nul set /p "=[95mPreview (p), Execute (e), or Skip (s)? [0m"
        set /p "CHOICE="
    )
    if /i "!CHOICE!"=="p" (
        if /i "%~x1"==".reg" (
            echo Previewing registry changes:
            type "!FILE_PATH!"
            echo.
            echo [%DATE% %TIME%] Previewed: !FILE_NAME! >> "!LOG_FILE!"
        ) else (
            echo Preview not available for .cmd files yet.
            echo [%DATE% %TIME%] Preview not available for !FILE_NAME! >> "!LOG_FILE!"
        )
        goto :prompt_user
    ) else if /i "!CHOICE!"=="e" (
        set /a EXECUTED_FILES+=1
        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
        echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
        if /i "%~x1"==".reg" (
            if "!SIMULATE!"=="1" (
                echo reg-simulated-import "!FILE_PATH!"
                echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Simulated Success: !FILE_NAME![0m" & echo.
            ) else (
                reg import "!FILE_PATH!" /reg:64 >nul 2>&1
                if !errorlevel! equ 0 (
                    echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else (
                    echo [%DATE% %TIME%] Failed to import !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                    <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME![0m" & echo.
                )
            )
        ) else if /i "%~x1"==".cmd" (
            if "!SIMULATE!"=="1" (
                echo call-simulated "!FILE_PATH!"
                echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Simulated Success: !FILE_NAME![0m" & echo.
            ) else (
                call "!FILE_PATH!"
                if !errorlevel! equ 0 (
                    echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else (
                    echo [%DATE% %TIME%] Failed: !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                    <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME![0m" & echo.
                )
            )
        ) else (
            echo [%DATE% %TIME%] Skipping unsupported file type: !FILE_NAME! >> "!LOG_FILE!"
            <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped unsupported file: !FILE_NAME![0m" & echo.
        )
    ) else if /i "!CHOICE!"=="s" (
        <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
        echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
    ) else (
        echo Invalid choice. Enter p, e, or s.
        goto :prompt_user
    )
)
goto :eof

rem Keyboard tweak selection subroutine
:process_keyboard
set "MODE_TYPE=%1"
set "KEYBOARD_PATH=%~dp04_Input\Keyboard"
if exist "!KEYBOARD_PATH!\" (
    echo Entering folder: 4_Input\Keyboard
    echo [%DATE% %TIME%] Entering folder: 4_Input\Keyboard >> "!LOG_FILE!"
    set /a PROCESSED_FILES+=1
    set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
    if defined DEFAULT_CHOICE if /i "!DEFAULT_CHOICE!"=="s" (
        set "KB_FILE=!KEYBOARD_PATH!\4_Wooting_Fullsized_Keyboard.reg"
        set "FILE_NAME=4_Wooting_Fullsized_Keyboard.reg"
        echo [!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME!
        echo Auto-choice: s for !FILE_NAME!
        <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
        echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
    ) else (
        echo [!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Selecting keyboard tweak...
        echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Selecting keyboard tweak... >> "!LOG_FILE!"
        echo What kind of Keyboard do you have?
        echo 1: Low End (e.g., Dell KB216)
        echo 2: Mid Tier (e.g., Logitech K400 Plus)
        echo 3: High End (e.g., Corsair K95 RGB)
        echo 4: Wooting 1000hz (e.g., Wooting Two)
        echo 5: Wooting 8000hz (e.g., Wooting 60HE+)
        echo 6: Other 8000hz (e.g., Razer Huntsman V2)
        :keyboard_prompt
        set "KB_CHOICE="
        <nul set /p "=[95mEnter choice (1-6): [0m"
        set /p "KB_CHOICE="
        if "!KB_CHOICE!" LSS "1" (
            echo Invalid choice. Please enter 1-6.
            goto keyboard_prompt
        )
        if "!KB_CHOICE!" GTR "6" (
            echo Invalid choice. Please enter 1-6.
            goto keyboard_prompt
        )
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
        )
        if defined KB_FILE (
            if exist "!KB_FILE!" (
                if not defined DEFAULT_CHOICE (
                    :prompt_user_keyboard
                    <nul set /p "=[95mPreview (p), Execute (e), or Skip (s)? [0m"
                    set /p "CHOICE="
                    if /i "!CHOICE!"=="p" (
                        echo Previewing registry changes:
                        type "!KB_FILE!"
                        echo.
                        echo [%DATE% %TIME%] Previewed: !FILE_NAME! >> "!LOG_FILE!"
                        goto :prompt_user_keyboard
                    ) else if /i "!CHOICE!"=="e" (
                        set "CHOICE=e"
                    ) else if /i "!CHOICE!"=="s" (
                        set "CHOICE=s"
                    ) else (
                        echo Invalid choice. Enter p, e, or s.
                        goto :prompt_user_keyboard
                    )
                ) else if /i "!DEFAULT_CHOICE!"=="e" (
                    set "CHOICE=e"
                    echo Auto-choice: e for !FILE_NAME!
                )
                if /i "!CHOICE!"=="e" (
                    set /a EXECUTED_FILES+=1
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
                    if "!SIMULATE!"=="1" (
                        echo reg-simulated-import "!KB_FILE!"
                        echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        reg import "!KB_FILE!" /reg:64 >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            echo [%DATE% %TIME%] Failed to import !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else if /i "!CHOICE!"=="s" (
                    <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
                )
            ) else (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] File not found: !FILE_NAME!
                echo [%DATE% %TIME%] File not found: !FILE_NAME! >> "!LOG_FILE!"
            )
        )
    )
)
goto :eof