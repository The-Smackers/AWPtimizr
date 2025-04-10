@echo off
setlocal EnableDelayedExpansion
echo is on

rem Define summary directory for logs and CPU type storage, unique to this machine
set "SUMMARY_DIR=%~dp0Summary_%COMPUTERNAME%"
mkdir "!SUMMARY_DIR!" 2>nul

rem UAC elevation—revert needs admin rights for registry changes
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d %~dp0 && %~nx0' -Verb RunAs"
    exit /b
)

rem Announce startup—keeps user in the loop
echo Starting TerminalTanks Revert...

rem Set up logging—append to same log as Run_All.cmd for consistency
set "LOG_FILE=!SUMMARY_DIR!\Optimization_Log.txt"
echo [%DATE% %TIME%] Starting revert application... >> "!LOG_FILE!"

rem Main menu loop—choose to revert or exit
:menu
cls
echo TerminalTanks Revert
echo Current Date: %DATE%
echo.
echo 1. Run revert CS2 tweaks
echo 2. Exit
echo.
set "MENU_CHOICE="
set /p MENU_CHOICE="Enter choice (1-2): "
if "!MENU_CHOICE!"=="1" goto revert
if "!MENU_CHOICE!"=="2" exit
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

rem Core revert logic—CPU detection, mode selection, and file processing
:revert
rem CPU type detection—reuses Run_All’s CPUType.txt for consistency
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
    rem Pull CPU manufacturer via WMIC—reliable way to ID Intel/AMD
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

rem Execution mode selection—mirrors Run_All.cmd for familiarity
echo Choose execution mode:
echo 1: Prompt for each file (default)
echo 2: Execute all automatically
echo 3: Skip all automatically
echo 4: Simulate all (no changes applied)
set /p "MODE=Enter choice (1-4): "
rem Set defaults: mode 4 enables simulation, others set execute/skip or prompt
if "!MODE!"=="2" (set "DEFAULT_CHOICE=e") else if "!MODE!"=="3" (set "DEFAULT_CHOICE=s") else if "!MODE!"=="4" (set "SIMULATE=1" & set "DEFAULT_CHOICE=e") else (set "DEFAULT_CHOICE=" & set "SIMULATE=0")

rem Count total revert files—sets up progress tracking
set "TOTAL_FILES=0"
set "PROCESSED_FILES=0"
echo Scanning revert subfolders...
echo [%DATE% %TIME%] Scanning revert subfolders... >> "!LOG_FILE!"

rem Non-CPU/Input folders with Revert subfolder (e.g., 2_Game\Revert)
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

rem CPU folder with Revert subfolder (e.g., 1_CPU\AMD\Revert)
set "CPU_PATH=%~dp01_CPU\!CPU_TYPE!"
if exist "!CPU_PATH!\Revert\" (
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set /a TOTAL_FILES+=1
        <nul set /p "=[32mFound: %%F[0m" & echo.
        echo [%DATE% %TIME%] Found: %%F >> "!LOG_FILE!"
    )
)

rem Input folder (Mouse and Keyboard) with Revert subfolder
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

rem Bail if no revert files found—avoids pointless processing
if !TOTAL_FILES! equ 0 (
    echo No revert files found in subfolders. Returning to menu...
    echo [%DATE% %TIME%] No revert files found in subfolders. >> "!LOG_FILE!"
    timeout /t 2 >nul
    goto menu
)

rem Process revert files with user prompts or auto-choices
echo Total revert files found: !TOTAL_FILES!
echo [%DATE% %TIME%] Total revert files found: !TOTAL_FILES! >> "!LOG_FILE!"

rem Non-CPU/Input revert folders
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" if /i NOT "%%~nxD"=="Backup" (
        if exist "%%D\Revert\" (
            echo Entering folder: %%~nxD\Revert
            echo [%DATE% %TIME%] Entering folder: %%~nxD\Revert >> "!LOG_FILE!"
            for %%F in ("%%D\Revert\*.reg" "%%D\Revert\*.cmd") do (
                set "FILE_NAME=%%~nxF"
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
                        rem Check registry keys—helps debug applicability
                        echo Checking registry applicability...
                        for /f "delims=" %%K in ('type "%%F" ^| findstr /i "HKEY"') do (
                            set "KEY_PATH=%%K"
                            set "KEY_PATH=!KEY_PATH:[=!"
                            set "KEY_PATH=!KEY_PATH:]=!"
                            echo Debug: Querying !KEY_PATH! >> "!LOG_FILE!"
                            reg query "!KEY_PATH!" >nul 2>&1
                            if !errorlevel! equ 0 (
                                echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            ) else (
                                echo Key does not exist: !KEY_PATH!
                                echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                            )
                        )
                        rem Toggle between simulation and real import
                        if "!SIMULATE!"=="1" (
                            echo reg-simulated-import "%%F"
                            echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            reg import "%%F" /reg:64 >nul 2>&1
                            if !errorlevel! equ 0 (
                                echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                            ) else (
                                echo [%DATE% %TIME%] Failed to import !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                                echo Failed to import !FILE_NAME!
                            )
                        )
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                    ) else (
                        rem Handle .cmd files—simulate or execute
                        if "!SIMULATE!"=="1" (
                            echo call-simulated "%%F"
                            echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            call "%%F"
                            if !errorlevel! equ 0 (
                                echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                            ) else (
                                echo [%DATE% %TIME%] Failed: !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                                echo Failed: !FILE_NAME!
                            )
                        )
                        <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
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

rem CPU revert folder
if exist "!CPU_PATH!\Revert\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!\Revert
    echo [%DATE% %TIME%] Entering folder: 1_CPU\!CPU_TYPE!\Revert >> "!LOG_FILE!"
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        set "FILE_NAME=%%~nxF"
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
                        echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo Key does not exist: !KEY_PATH!
                        echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                    )
                )
                if "!SIMULATE!"=="1" (
                    echo reg-simulated-import "%%F"
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    reg import "%%F" /reg:64 >nul 2>&1
                    if !errorlevel! equ 0 (
                        echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo [%DATE% %TIME%] Failed to import !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                        echo Failed to import !FILE_NAME!
                    )
                )
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
            ) else (
                if "!SIMULATE!"=="1" (
                    echo call-simulated "%%F"
                    echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                ) else (
                    call "%%F"
                    if !errorlevel! equ 0 (
                        echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        echo [%DATE% %TIME%] Failed: !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                        echo Failed: !FILE_NAME!
                    )
                )
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
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

rem Input revert folders (Mouse and Keyboard)
for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\Revert\" (
        echo Entering folder: 4_Input\%%S\Revert
        echo [%DATE% %TIME%] Entering folder: 4_Input\%%S\Revert >> "!LOG_FILE!"
        for %%F in ("!INPUT_PATH!\Revert\*.reg" "!INPUT_PATH!\Revert\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set /a PROCESSED_FILES+=1
            set /a "PERCENT=PROCESSED_FILES*100/TOTAL_FILES"
            <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] [!PERCENT!%%] Found: !FILE_NAME![0m" & echo.
            echo [%DATE% %TIME%] [!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME! >> "!LOG_FILE!"
            :prompt_user_input
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
                goto :prompt_user_input
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
                            echo [%DATE% %TIME%] Key exists: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            echo Key does not exist: !KEY_PATH!
                            echo [%DATE% %TIME%] Key does not exist: !KEY_PATH! for !FILE_NAME! >> "!LOG_FILE!"
                        )
                    )
                    if "!SIMULATE!"=="1" (
                        echo reg-simulated-import "%%F"
                        echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        reg import "%%F" /reg:64 >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            echo [%DATE% %TIME%] Failed to import !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                            echo Failed to import !FILE_NAME!
                        )
                    )
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                ) else (
                    if "!SIMULATE!"=="1" (
                        echo call-simulated "%%F"
                        echo [%DATE% %TIME%] Simulated success for !FILE_NAME! >> "!LOG_FILE!"
                    ) else (
                        call "%%F"
                        if !errorlevel! equ 0 (
                            echo [%DATE% %TIME%] Success for !FILE_NAME! >> "!LOG_FILE!"
                        ) else (
                            echo [%DATE% %TIME%] Failed: !FILE_NAME! - Check admin rights or file >> "!LOG_FILE!"
                            echo Failed: !FILE_NAME!
                        )
                    )
                    <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME![0m" & echo.
                )
            ) else if /i "!CHOICE!"=="s" (
                <nul set /p "=[31m[!PROCESSED_FILES!/!TOTAL_FILES!] Skipped: !FILE_NAME![0m" & echo.
                echo [%DATE% %TIME%] Skipped: !FILE_NAME! >> "!LOG_FILE!"
            ) else (
                echo Invalid choice. Enter p, e, or s.
                goto :prompt_user_input
            )
        )
    )
)

rem Wrap up—message depends on simulation or real run
if "!SIMULATE!"=="1" (
    echo Simulation of revert CS2 tweaks complete! No changes applied to registry.
    echo [%DATE% %TIME%] Simulation complete! >> "!LOG_FILE!"
) else (
    echo Revert CS2 tweaks application complete! Reboot recommended.
    echo [%DATE% %TIME%] Revert CS2 tweaks application complete! Reboot recommended. >> "!LOG_FILE!"
)
timeout /t 2 >nul
pause
goto menu