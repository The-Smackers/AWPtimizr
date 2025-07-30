@echo off

ECHO Enable Dynamic Tick
bcdedit /set disabledynamictick no >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo Failed to enable dynamic tick.)

ECHO Enable High Precision Event Timer (HPET)
bcdedit /set useplatformclock yes >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo Failed to enable HPET.)

ECHO Enable Synthetic Timers
bcdedit /deletevalue useplatformtick >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo Synthetic timers not found or already enabled.)

ECHO Revert Done Reboot required.
pause