@echo off
echo Disabling hibernation...

:: Disable hibernation via powercfg
powercfg.exe /hibernate off

:: Modify registry to disable hibernation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HibernateEnabled" /t REG_DWORD /d 0 /f

:: Hide hibernate option from power menu
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowHibernateOption" /t REG_DWORD /d 0 /f

echo Hibernation has been disabled and removed from the power menu.
pause