@echo off
echo Reverting additional telemetry settings...

bcdedit /set {current} bootmenupolicy Standard >nul 2>&1

echo Restoring Task Manager settings not fully reverted via reg (manual check recommended)...

echo Restoring Edge telemetry policy not fully reverted via reg (manual check recommended)...

echo Ungrouping svchost.exe processes...
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d 0 /f >nul 2>&1

echo Restoring AutoLogger telemetry...
set "autoLoggerDir=%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger"
icacls "%autoLoggerDir%" /remove:d SYSTEM >nul 2>&1

echo Enabling Defender sample submission...
powershell -Command "Set-MpPreference -SubmitSamplesConsent 1" >nul 2>&1

echo Telemetry settings reverted. Restart may be required for full effect.
pause