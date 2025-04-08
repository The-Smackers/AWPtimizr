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

rem Count total files to process
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

rem Input folder (Mouse and Keyboard)
for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\" (
        for %%F in ("!INPUT_PATH!\*.reg" "!INPUT_PATH!\*.cmd") do (
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

for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\" (
        echo Entering folder: 4_Input\%%S
        for %%F in ("!INPUT_PATH!\*.reg" "!INPUT_PATH!\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set "SKIP=0"
            if /i "!FILE_NAME:revert=!" NEQ "!FILE_NAME!" set "SKIP=1"
            if /i "!FILE_NAME!"=="full_reset.cmd" set "SKIP=1"
            if "!SKIP!"=="0" (
                set /a PROCESSED_FILES+=1
                <nul set /p "=[32m[!PROCESSED_FILES!/!TOTAL_FILES!] Found: !FILE_NAME![0m" & echo.
                :prompt_user_input
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
                    goto :prompt_user_input
                )
            )
        )
    )
)

echo All tweaks processed! Reboot recommended.
pause
exit /b