@echo off
echo Enabling hibernation...

:: Enable hibernation via powercfg
powercfg.exe /hibernate on

:: Modify registry to enable hibernation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HibernateEnabled" /t REG_DWORD /d 1 /f

:: Show hibernate option in power menu
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowHibernateOption" /t REG_DWORD /d 1 /f

echo Hibernation has been enabled and restored to the power menu.
pause