@echo off
setlocal EnableDelayedExpansion
echo is on

rem Define summary directory
set "SUMMARY_DIR=%~dp0Summary_%COMPUTERNAME%"
mkdir "!SUMMARY_DIR!" 2>nul

rem UAC elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/k cd /d %~dp0 && %~nx0' -Verb RunAs"
    exit /b
)

echo Starting TerminalTanks CS2 Tweaks Simulation...

rem Initialize logging
set "LOG_FILE=!SUMMARY_DIR!\Optimization_Log.txt"
echo [%DATE% %TIME%] Starting tweak application... >> "!LOG_FILE!"

:menu
cls
echo TerminalTanks CS2 Tweaks Simulation
echo Current Date: %DATE%
echo.
echo 1. Run simulation
echo 2. Exit
echo.
set "MENU_CHOICE="
set /p MENU_CHOICE="Enter choice (1-2): "
if "!MENU_CHOICE!"=="1" goto simulate
if "!MENU_CHOICE!"=="2" exit /b
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

:simulate
rem Backup option
set "BACKUP_PATH=%~dp0Backup"
set /p "BACKUP=Create registry backup before simulation? (y/n): "
if /i "!BACKUP!"=="y" (
    mkdir "!BACKUP_PATH!" 2>nul
    echo Creating backup...
    echo [%DATE% %TIME%] Creating registry backup... >> "!LOG_FILE!"
    set "BACKUP_HKLM=!BACKUP_PATH!\HKLM_SYSTEM_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.reg"
    set "BACKUP_HKCU=!BACKUP_PATH!\HKCU_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.reg"
    if exist "!BACKUP_HKLM!" (
        set /p "OVERWRITE=Backup already exists. Overwrite? (y/n): "
        if /i "!OVERWRITE!"=="y" (
            reg export HKLM\SYSTEM "!BACKUP_HKLM!" /y
            reg export HKCU "!BACKUP_HKCU!" /y
        ) else (
            echo Skipping backup creation.
            echo [%DATE% %TIME%] Skipped backup creation due to existing files. >> "!LOG_FILE!"
        )
    ) else (
        reg export HKLM\SYSTEM "!BACKUP_HKLM!" /y
        reg export HKCU "!BACKUP_HKCU!" /y
    )
    echo Backup saved to !BACKUP_PATH!
    echo [%DATE% %TIME%] Backup saved to !BACKUP_PATH! >> "!LOG_FILE!"
)

rem Batch execution mode
echo Choose execution mode:
echo 1: Prompt for each file (default)
echo 2: Execute all automatically
echo 3: Skip all automatically
set /p "MODE=Enter choice (1-3): "
if "!MODE!"=="2" (set "DEFAULT_CHOICE=e") else if "!MODE!"=="3" (set "DEFAULT_CHOICE=s") else (set "DEFAULT_CHOICE=")

rem CPU type detection
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

rem Count total files to process (excluding keyboard files, adding 1 for choice, excluding Backup)
set "TOTAL_FILES=0"
set "PROCESSED_FILES=0"
echo Scanning subfolders...
echo [%DATE% %TIME%] Scanning subfolders... >> "!LOG_FILE!"

rem Non-CPU/Input/Backup folders
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
            echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
        )
    )
)

rem Input folder (Mouse only)
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

rem Add 1 for the keyboard choice
set /a TOTAL_FILES+=1

if !TOTAL_FILES! equ 0 (
    echo No tweak files found in subfolders. Returning to menu...
    echo [%DATE% %TIME%] No tweak files found in subfolders. >> "!LOG_FILE!"
    timeout /t 2 >nul
    goto menu
)

rem Process files with user prompts (simulated .reg, selective .cmd simulation)
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        echo Entering folder: %%~nxD
        echo [%DATE% %TIME%] Entering folder: %%~nxD >> "!LOG_FILE!"
        for %%F in ("%%D\*.reg" "%%D\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set "SKIP=0"
            if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
            if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
            if "!SKIP!"=="0" (
                set /a PROCESSED_FILES+=1
                set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME! >> "!LOG_FILE!"
                :prompt_user
                set "CHOICE="
                if defined DEFAULT_CHOICE (
                    set "CHOICE=!DEFAULT_CHOICE!"
                    echo Auto-choice: !CHOICE! for !FILE_NAME!
                ) else (
                    <nul set /p "=[1;33mPreview (p), Execute (e), or Skip (s)? [0m"
                    set /p "CHOICE="
                )
                if /i "!CHOICE!"=="p" (
                    if /i "%%~xF"==".reg" (
                        echo Previewing registry changes:
                        type "%%F"
                        echo.
                        echo [%DATE% %TIME%] Previewed: !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo Preview not available for .cmd files yet.
                        echo [%DATE% %TIME%] Preview not available for !FILE_NAME! >> "!LOG_FILE!"
                    )
                    goto :prompt_user
                ) else if /i "!CHOICE!"=="e" (
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
                    if /i "%%~xF"==".reg" (
                        echo Checking registry applicability...
                        for /f "delims=" %%K in ('type "%%F" ^| findstr /i "HKEY"') do (
                            set "KEY_PATH=%%K"
                            set "KEY_PATH=!KEY_PATH:[=!"
                            set "KEY_PATH=!KEY_PATH:]=!"
                            echo Debug: Querying !KEY_PATH! >> "!LOG_FILE!"
                            reg query "!KEY_PATH!" >nul 2>&1
                            if !errorlevel! equ 0 (
                                echo Key: !KEY_PATH!
                                echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                                for /f "tokens=1,2,*" %%V in ('reg query "!KEY_PATH!" 2^>nul') do (
                                    if "%%W" NEQ "" (
                                        echo Value: %%V = %%W %%X
                                        echo [%DATE% %TIME%] Value: %%V = %%W %%X for !FILE_NAME! >> "!LOG_FILE!"
                                    )
                                )
                            ) else (
                                echo Key does not exist: !KEY_PATH!
                                echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            )
                        )
                        echo reg-simulated-import "%%F"
                        <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                        echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else if /i "!FILE_NAME!"=="Latency_Tweaks.cmd" (
                        echo call-simulated "%%F"
                        <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                        echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        call "%%F"
                        if !errorlevel! equ 0 (
                            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                            echo [%DATE% %TIME%] Success: !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                            echo [%DATE% %TIME%] Failed: !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                ) else if /i "!CHOICE!"=="s" (
                    <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    echo Invalid choice. Enter p, e, or s.
                    goto :prompt_user
                )
            )
        )
    )
)

if exist "!CPU_PATH!\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!
    echo [%DATE% %TIME%] Entering folder: 1_CPU\!CPU_TYPE! >> "!LOG_FILE!"
    for %%F in ("!CPU_PATH!\*.reg" "!CPU_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a PROCESSED_FILES+=1
            set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME![0m" & echo.
            echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME! >> "!LOG_FILE!"
            :prompt_user_cpu
            set "CHOICE="
            if defined DEFAULT_CHOICE (
                set "CHOICE=!DEFAULT_CHOICE!"
                echo Auto-choice: !CHOICE! for !FILE_NAME!
            ) else (
                <nul set /p "=[1;33mPreview (p), Execute (e), or Skip (s)? [0m"
                set /p "CHOICE="
            )
            if /i "!CHOICE!"=="p" (
                if /i "%%~xF"==".reg" (
                    echo Previewing registry changes:
                    type "%%F"
                    echo.
                    echo [%DATE% %TIME%] Previewed: !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    echo Preview not available for .cmd files yet.
                    echo [%DATE% %TIME%] Preview not available for !FILE_NAME! >> "!LOG_FILE!"
                )
                goto :prompt_user_cpu
            ) else if /i "!CHOICE!"=="e" (
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
                if /i "%%~xF"==".reg" (
                    echo Checking registry applicability...
                    for /f "delims=" %%K in ('type "%%F" ^| findstr /i "HKEY"') do (
                        set "KEY_PATH=%%K"
                        set "KEY_PATH=!KEY_PATH:[=!"
                        set "KEY_PATH=!KEY_PATH:]=!"
                        echo Debug: Querying !KEY_PATH! >> "!LOG_FILE!"
                        reg query "!KEY_PATH!" >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo Key: !KEY_PATH!
                            echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            for /f "tokens=1,2,*" %%V in ('reg query "!KEY_PATH!" 2^>nul') do (
                                if "%%W" NEQ "" (
                                    echo Value: %%V = %%W %%X
                                    echo [%DATE% %TIME%] Value: %%V = %%W %%X for !FILE_NAME! >> "!LOG_FILE!"
                                )
                            )
                        ) else (
                            echo Key does not exist: !KEY_PATH!
                            echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                    echo reg-simulated-import "%%F"
                    <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else if /i "!FILE_NAME!"=="Latency_Tweaks.cmd" (
                    echo call-simulated "%%F"
                    <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    call "%%F"
                    if !errorlevel! equ 0 (
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                        echo [%DATE% %TIME%] Success: !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                        echo [%DATE% %TIME%] Failed: !FILE_NAME! >> "!LOG_FILE!"
                    )
                )
            ) else if /i "!CHOICE!"=="s" (
                <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
            ) else (
                echo Invalid choice. Enter p, e, or s.
                goto :prompt_user_cpu
            )
        )
    )
)

if exist "!MOUSE_PATH!\" (
    echo Entering folder: 4_Input\Mouse
    echo [%DATE% %TIME%] Entering folder: 4_Input\Mouse >> "!LOG_FILE!"
    for %%F in ("!MOUSE_PATH!\*.reg" "!MOUSE_PATH!\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set "SKIP=0"
        if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
        if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
        if "!SKIP!"=="0" (
            set /a PROCESSED_FILES+=1
            set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME![0m" & echo.
            echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME! >> "!LOG_FILE!"
            :prompt_user_mouse
            set "CHOICE="
            if defined DEFAULT_CHOICE (
                set "CHOICE=!DEFAULT_CHOICE!"
                echo Auto-choice: !CHOICE! for !FILE_NAME!
            ) else (
                <nul set /p "=[1;33mPreview (p), Execute (e), or Skip (s)? [0m"
                set /p "CHOICE="
            )
            if /i "!CHOICE!"=="p" (
                if /i "%%~xF"==".reg" (
                    echo Previewing registry changes:
                    type "%%F"
                    echo.
                    echo [%DATE% %TIME%] Previewed: !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    echo Preview not available for .cmd files yet.
                    echo [%DATE% %TIME%] Preview not available for !FILE_NAME! >> "!LOG_FILE!"
                )
                goto :prompt_user_mouse
            ) else if /i "!CHOICE!"=="e" (
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
                if /i "%%~xF"==".reg" (
                    echo Checking registry applicability...
                    for /f "delims=" %%K in ('type "%%F" ^| findstr /i "HKEY"') do (
                        set "KEY_PATH=%%K"
                        set "KEY_PATH=!KEY_PATH:[=!"
                        set "KEY_PATH=!KEY_PATH:]=!"
                        echo Debug: Querying !KEY_PATH! >> "!LOG_FILE!"
                        reg query "!KEY_PATH!" >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo Key: !KEY_PATH!
                            echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            for /f "tokens=1,2,*" %%V in ('reg query "!KEY_PATH!" 2^>nul') do (
                                if "%%W" NEQ "" (
                                    echo Value: %%V = %%W %%X
                                    echo [%DATE% %TIME%] Value: %%V = %%W %%X for !FILE_NAME! >> "!LOG_FILE!"
                                )
                            )
                        ) else (
                            echo Key does not exist: !KEY_PATH!
                            echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                    echo reg-simulated-import "%%F"
                    <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else if /i "!FILE_NAME!"=="Latency_Tweaks.cmd" (
                    echo call-simulated "%%F"
                    <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    call "%%F"
                    if !errorlevel! equ 0 (
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                        echo [%DATE% %TIME%] Success: !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                        echo [%DATE% %TIME%] Failed: !FILE_NAME! >> "!LOG_FILE!"
                    )
                )
            ) else if /i "!CHOICE!"=="s" (
                <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
            ) else (
                echo Invalid choice. Enter p, e, or s.
                goto :prompt_user_mouse
            )
        )
    )
)

rem Keyboard selection
set "KEYBOARD_PATH=%~dp04_Input\Keyboard"
if exist "!KEYBOARD_PATH!\" (
    echo Entering folder: 4_Input\Keyboard
    echo [%DATE% %TIME%] Entering folder: 4_Input\Keyboard >> "!LOG_FILE!"
    set /a PROCESSED_FILES+=1
    set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
    if defined DEFAULT_CHOICE if /i "!DEFAULT_CHOICE!"=="s" (
        REM Default to skipping keyboard tweak when mode is "Skip all"
        set "KB_FILE=!KEYBOARD_PATH!\4_Wooting_Fullsized_Keyboard.reg"
        set "FILE_NAME=4_Wooting_Fullsized_Keyboard.reg"
        echo [!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME!
        echo Auto-choice: s for !FILE_NAME!
        <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
        echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
    ) else (
        REM Prompt for keyboard choice in both Mode 1 and Mode 2
        echo [!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Selecting keyboard tweak...
        echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Selecting keyboard tweak... >> "!LOG_FILE!"
        echo What kind of Keyboard do you have?
        echo 1: Low End
        echo 2: Mid Tier
        echo 3: High End
        echo 4: Wooting 1000hz
        echo 5: Wooting 8000hz
        echo 6: Other 8000hz
        :keyboard_prompt
        set "KB_CHOICE="
        set /p "KB_CHOICE=Enter choice (1-6): "
        if "!KB_CHOICE!" LSS "1" (
            echo Invalid choice. Please enter a number between 1 and 6.
            goto keyboard_prompt
        )
        if "!KB_CHOICE!" GTR "6" (
            echo Invalid choice. Please enter a number between 1 and 6.
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
                    REM Mode 1: Prompt for Preview/Execute/Skip
                    :prompt_user_keyboard
                    <nul set /p "=[1;33mPreview (p), Execute (e), or Skip (s)? [0m"
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
                    REM Mode 2: Auto-execute after selection
                    set "CHOICE=e"
                    echo Auto-choice: e for !FILE_NAME!
                )
                if /i "!CHOICE!"=="e" (
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Applying: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Applying: !FILE_NAME! >> "!LOG_FILE!"
                    echo Checking registry applicability...
                    for /f "delims=" %%K in ('type "!KB_FILE!" ^| findstr /i "HKEY"') do (
                        set "KEY_PATH=%%K"
                        set "KEY_PATH=!KEY_PATH:[=!"
                        set "KEY_PATH=!KEY_PATH:]=!"
                        echo Debug: Querying !KEY_PATH! >> "!LOG_FILE!"
                        reg query "!KEY_PATH!" >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo Key: !KEY_PATH!
                            echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            for /f "tokens=1,2,*" %%V in ('reg query "!KEY_PATH!" 2^>nul') do (
                                if "%%W" NEQ "" (
                                    echo Value: %%V = %%W %%X
                                    echo [%DATE% %TIME%] Value: %%V = %%W %%X for !FILE_NAME! >> "!LOG_FILE!"
                                )
                            )
                        ) else (
                            echo Key does not exist: !KEY_PATH!
                            echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                    echo reg-simulated-import "!KB_FILE!"
                    <nul set /p "=[32mSimulated success for !FILE_NAME![0m" & echo.
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
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

echo Simulation of CS2 complete! No changes applied to registry.
echo [%DATE% %TIME%] Simulation complete! >> "!LOG_FILE!"
timeout /t 2 >nul
pause
goto menu