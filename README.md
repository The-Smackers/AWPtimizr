# The AWPtimizr
**A**dvanced  
**W**indows  
**P**erformance  
**T**uning Toolkit  
**I**nput Layer Consistency  
**M**odular Functionality  
**I**ntel/AMD Optimization  
**Z**ero Jitter  
**R**ollback Protection


A command-line tool to apply and revert Windows and CS2 performance tweaks via registry and script files.

## Features
- **CPU Tweaks**: AMD/Intel-specific optimizations.
- **Game Tweaks**: High priority and thread settings for CS2.
- **Services**: Disable unnecessary Windows services (Bluetooth, Xbox, etc. see Note #1).
- **Latency**: Dynamic tick, HPET, and synthetic timer adjustments. (AMD CPU only)
- **Network**: Firewall rules for CS2.
- **Graphics**: High-performance settings for CS2.
- **Input**: Mouse precision fixes and keyboard polling rate tweaks.
- **Debloat Windows**: See Note #1.
- **Clear DirectX Shader Cache**: And verifies CS2 files.
- **Revert Options**: Undo all or some changes.
- **Simulation Mode**: Test tweaks without applying.

## Usage
1. **Clone/Download**: Grab the repo or download latest release and unzip if needed.
2. **Run in terminal or click file**: (Prompts for Admin privileges)
   - `AWPtimizr.cmd`: Apply or Undo all changes/tweaks with prompts.
4. **Reboot**: Required after applying tuning tweaks or reverting tuning tweaks.

## Folder Structure
- `1_CPU\AMD\`: AMD-specific tweaks (e.g., `AMD_CPU_Priority.reg/Latency_Tweaks.cmd`).
- `2_Game\`: CS2 priority tweaks (e.g., `CS2_High_Priority.reg`).
- `3_Input\Mouse\`: Mouse tweaks (e.g., `Disable_Pointer_Precision_Globally_and_Fix_Delay.reg`).
- `3_Input\Keyboard\`: Keyboard tweaks (e.g., `5_Wooting_Latest_Keyboard.reg`).
- `4_Network\`: Network tweaks (e.g., `CS2_Firewall_Rules.cmd`).
- `5_Graphics\`: Graphics tweaks (e.g., `CS2_High_Performance.cmd`).
- `6_Features\`: Windows 11 tweaks (`Enable Taskbar End Task/Classic Right Click Menu`).
- `7_Debloat\`: Debloat Windows (e.g., `See Note #1`).
- `*/Revert\`: Revert scripts (e.g., `Revert_Latency_Tweaks.cmd`).

## Prerequisites
- Windows 11, admin rights.
- Backup your registry (optional but recommended), this program will backup your registry if selected to do so.

#### Registry Tweaks for Windows Optimization
This repository includes a collection of `.reg` files to disable various Windows features and services, along with corresponding revert files to restore default settings. All tweaks are designed for Windows 11 (tested against 23H2 defaults as of July 2025) unless noted otherwise. Revert files have been updated to align with true Windows defaults (e.g., removing policy keys rather than setting them to enabling values).

**Notes:**
- HomeGroup and WiFi Sense tweaks are legacy; they’re no-ops in Windows 11 but included for older systems.

## Note #1 Debloat description
Disable ActivityHistory  
Disable BackgroundApps  
Disable ConsumerFeatures  
Disable FullscreenOptimizations  
Disable Gamedvr  
Disable Hibernation  
Disable Homegroup  
Disable IntelLMS_Manual  
Disable MicrosoftCopilot  
Disable NotificationTrayCalendar  
Disable PowerShellTelemetry  
Disable StorageSense  
Disable Telemetry  
Disable Bluetooth  
Disable Download_Maps_Manager  
Disable Printer  
Disable Xbox  
Sets lots of Services To Manual  
Disable Windows Unnecessary Services  
which does the following:  
Disable Windows Biometric Service  
Disable Graphics performance monitor service  
Disable Windows Image Acquisition (WIA)  
Disable Windows Error Reporting Service  
Disable Program Compatibility Assistant Service  
Disable Windows Event Collector  

To test, select simulation mode:
1. Run `AWPtimizr.cmd`.
2. Select `1` (Run revert tweaks), then `4` (simulate all).
3. Check the log for "Simulated success" entries—no system changes applied.

For real reverts, use modes 1-3. Logs distinguish between "Success" (real) and "Simulated success" (dry run), with a reboot recommended after real runs.

Run the script with admin privileges to apply tweaks. Ensure all referenced `.reg` and `.cmd` files exist in their respective subfolders for full functionality.

### Usage Notes
- Run scripts with administrative privileges (UAC prompt will appear if needed).
- Check `Optimization_Log.txt` after execution for a detailed run history.
- Backups are timestamped (e.g., `HKLM_SYSTEM_20250408.reg`) and stored in the `Backup` subfolder.

### Example
```cmd
Choose execution mode:
1: Prompt for each file (default)
2: Execute all automatically
3: Skip all automatically (exit)
4: Simulate all (no changes applied)
Enter choice (1-4):

[1/10] [10%] Found: Disable_Telemetry.reg
Preview (p), Execute (e), or Skip (s)? e
[1/10] Applying: Disable_Telemetry.reg
[1/10] Success: Disable_Telemetry.reg
```

## Notes
- Tested on Ryzen 7 7800X3D, RTX 4080 SUPER.
- Report issues on GitHub: `https://github.com/The-Smackers/Windows_Optimizations`.

## Why?
Inspiration from [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil).  
Some tweaks based on this video: [Make Your CS2 RUN BETTER - (packet loss, latency, clean)](https://www.youtube.com/watch?v=qG7C4W-EQl4) by [youtube.com/@KEROVSKI_](https://www.youtube.com/@KEROVSKI_).

## Contribute
- **Bugs** Fork it, tweak it, share it.  
- **License**: GNU  
- **More**: Catch TerminalTanks on YouTube—[youtube.com/@TerminalTanks](https://www.youtube.com/@TerminalTanks).
- **Who**: TerminalTanks(idk) is a member of The Smackers.

## 💖 Support
If you find this project helpful, consider [donating via PayPal](https://www.paypal.com/ncp/payment/8UEVM2WHXGL88).
