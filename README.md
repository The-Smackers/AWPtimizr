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

![AWPtimizr Logo](./logo.png)

A command-line tool to apply and revert common Windows and CS2 performance tweaks via registry and script files. VAC, VACnet and FACEIT Anti-Cheat safe.

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
1. **Clone/Download**: Grab the repo or [download latest release](https://github.com/The-Smackers/AWPtimizr/releases) and unzip if needed.
2. **Run in terminal or click file**: (Prompts for Admin privileges)
   - `AWPtimizr.cmd`: Apply or Revert all changes/tweaks with prompts.
4. **Reboot**: Required after applying tuning tweaks or reverting tuning tweaks.

### Usage Notes
- Check `Summary_*/Optimization_Log.txt` after execution for a detailed run history.
- Backups are stored in the `Summary_*/Backup` subfolder.

### Usage Example
```cmd
Choose execution mode:
1: Prompt for each file (advanced)
2: Execute all automatically (default)
3: Skip all automatically (exit)
4: Simulate all (no changes applied)
5: Delete DirectX Shader Cache (fix for FPS loss)
Enter choice (1-5):

[1/10] [10%] Found: Disable_Telemetry.reg
Preview (p), Execute (e), or Skip (s)? e
[1/10] Applying: Disable_Telemetry.reg
[1/10] Success: Disable_Telemetry.reg
```

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

## Registry Tweaks
This repository includes a collection of `.reg` and `.cmd` files to disable various Windows features and services, along with corresponding revert files to restore default settings. All tweaks are designed for Windows 11 (tested against 23H2 defaults as of July 2025). Revert files have been updated to align with true Windows defaults (e.g., removing policy keys rather than setting them to enabling values).

**Notes:**
- HomeGroup and WiFi Sense tweaks are legacy; they’re no-ops in Windows 11 but included for older systems.

## Debloat description (Note #1)
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

## Why does this program exist?
Inspired from [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil).  
Some tweaks based on this video: [Make Your CS2 RUN BETTER - (packet loss, latency, clean)](https://www.youtube.com/watch?v=qG7C4W-EQl4).

## About
- **License**: GPL v3  
- **Links**: [youtube.com/@TerminalTanks](https://www.youtube.com/@TerminalTanks).
- **Who**: idk/Pb is a member of The Smackers.

## 💖 Support
If you find this project or its developer helpful, consider [donating](https://www.paypal.com/ncp/payment/8UEVM2WHXGL88).
