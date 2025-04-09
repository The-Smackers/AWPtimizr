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

echo Starting TerminalTanks Revert...

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

rem Process revert files
set "TOTAL_FILES=0"
echo Scanning revert subfolders...

rem Non-CPU/Input folders with Revert subfolder
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" (
        if exist "%%D\Revert\" (
            for %%F in ("%%D\Revert\*.reg" "%%D\Revert\*.cmd") do (
                set "FILE_NAME=%%~nxF"
                set /a TOTAL_FILES+=1
                echo Found: %%F
            )
        )
    )
)

rem CPU folder with Revert subfolder
set "CPU_PATH=%~dp01_CPU\!CPU_TYPE!"
if exist "!CPU_PATH!\Revert\" (
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set /a TOTAL_FILES+=1
        echo Found: %%F
    )
)

rem Input folder (Mouse and Keyboard) with Revert subfolder
for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\Revert\" (
        for %%F in ("!INPUT_PATH!\Revert\*.reg" "!INPUT_PATH!\Revert\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set /a TOTAL_FILES+=1
            echo Found: %%F
        )
    )
)

if !TOTAL_FILES! equ 0 (
    echo No revert files found in subfolders. Exiting...
    pause
    exit /b 1
)

echo Total revert files found: !TOTAL_FILES!
echo Applying revert tweaks...

rem Apply revert tweaks (no prompts)
set "PROCESSED_FILES=0"
for /d %%D in ("%~dp0*") do (
    if /i NOT "%%~nxD"=="1_CPU" if /i NOT "%%~nxD"=="4_Input" (
        if exist "%%D\Revert\" (
            echo Entering folder: %%D\Revert
            for %%F in ("%%D\Revert\*.reg" "%%D\Revert\*.cmd") do (
                set "FILE_NAME=%%~nxF"
                set /a PROCESSED_FILES+=1
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME!
                if /i "%%~xF"==".reg" (
                    reg import "%%F" >nul 2>&1
                    if !errorlevel! equ 0 (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
                    ) else (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                    )
                ) else (
                    call "%%F"
                    if !errorlevel! equ 0 (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
                    ) else (
                        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                    )
                )
            )
        )
    )
)

if exist "!CPU_PATH!\Revert\" (
    echo Entering folder: 1_CPU\!CPU_TYPE!\Revert
    for %%F in ("!CPU_PATH!\Revert\*.reg" "!CPU_PATH!\Revert\*.cmd") do (
        set "FILE_NAME=%%~nxF"
        set /a PROCESSED_FILES+=1
        echo [!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME!
        if /i "%%~xF"==".reg" (
            reg import "%%F" >nul 2>&1
            if !errorlevel! equ 0 (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
            ) else (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
            )
        ) else (
            call "%%F"
            if !errorlevel! equ 0 (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
            ) else (
                echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
            )
        )
    )
)

for %%S in ("Mouse" "Keyboard") do (
    set "INPUT_PATH=%~dp04_Input\%%S"
    if exist "!INPUT_PATH!\Revert\" (
        echo Entering folder: 4_Input\%%S\Revert
        for %%F in ("!INPUT_PATH!\Revert\*.reg" "!INPUT_PATH!\Revert\*.cmd") do (
            set "FILE_NAME=%%~nxF"
            set /a PROCESSED_FILES+=1
            echo [!PROCESSED_FILES!/!TOTAL_FILES!] Applying: !FILE_NAME!
            if /i "%%~xF"==".reg" (
                reg import "%%F" >nul 2>&1
                if !errorlevel! equ 0 (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
                ) else (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                )
            ) else (
                call "%%F"
                if !errorlevel! equ 0 (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Success: !FILE_NAME!
                ) else (
                    echo [!PROCESSED_FILES!/!TOTAL_FILES!] Failed: !FILE_NAME! - Check admin rights or file.
                )
            )
        )
    )
)

echo Revert complete! Reboot recommended.
pause
exit /b