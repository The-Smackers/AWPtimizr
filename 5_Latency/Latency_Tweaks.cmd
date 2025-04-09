@echo off

ECHO Disable Dynamic Tick
bcdedit /set disabledynamictick yes >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo Failed to disable dynamic tick.)

ECHO Disable High Precision Event Timer (HPET)
bcdedit /deletevalue useplatformclock >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo HPET not found or already disabled.)

ECHO Disable Synthetic Timers
bcdedit /set useplatformtick yes >nul 2>&1
if %errorlevel% equ 0 (echo The operation completed successfully.) else (echo Failed to set synthetic timers.)

ECHO Done Reboot required.
pause