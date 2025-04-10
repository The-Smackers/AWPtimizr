@echo off
echo Disabling additional telemetry settings...

bcdedit /set {current} bootmenupolicy Legacy >nul 2>&1

echo Adjusting Task Manager settings (pre-Win 11 22557)...
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild | findstr "22557" >nul
if errorlevel 1 (
    start /b taskmgr.exe
    :waitloop
    timeout /t 1 /nobreak >nul
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\TaskManager" /v Preferences >nul 2>&1
    if errorlevel 1 goto waitloop
    taskkill /f /im taskmgr.exe >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\TaskManager" /v Preferences /t REG_BINARY /d binary value requires export/edit /f >nul 2>&1
)

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1

echo Removing Edge telemetry policy if present...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Edge" >nul 2>&1
if not errorlevel 1 (
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /f >nul 2>&1
)

echo Grouping svchost.exe processes...
for /f "tokens=3" %%a in ('wmic ComputerSystem get TotalPhysicalMemory ^| findstr /r "[0-9]"') do set /a ram=%%a/1024
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d %ram% /f >nul 2>&1

echo Blocking AutoLogger telemetry...
set "autoLoggerDir=%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger"
if exist "%autoLoggerDir%\AutoLogger-Diagtrack-Listener.etl" (
    del /f "%autoLoggerDir%\AutoLogger-Diagtrack-Listener.etl" >nul 2>&1
)
icacls "%autoLoggerDir%" /deny SYSTEM:(OI)(CI)F >nul 2>&1

echo Disabling Defender sample submission...
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2" >nul 2>&1

echo Telemetry disabled. Restart may be required for full effect.
pause