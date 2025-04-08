@echo off  
echo Enable Dynamic Tick
echo Enable High Precision Event Timer (HPET)
echo Enable Synthetic Timers
@echo 
bcdedit /deletevalue disabledynamictick
bcdedit /set useplatformclock yes
bcdedit /deletevalue useplatformtick
pause