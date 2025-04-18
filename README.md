# TerminalTanks Windows CS2 Tweaks (The AWPtimizr)
A command-line tool to apply and revert CS2 performance tweaks via registry and script files.

## Features
- **CPU Tweaks**: AMD/Intel-specific optimizations.
- **Game Tweaks**: High priority and thread settings for CS2.
- **Services**: Disable unnecessary Windows services (Bluetooth, Xbox, etc.).
- **Latency**: Dynamic tick, HPET, and synthetic timer adjustments.
- **Network**: Firewall rules for CS2.
- **Graphics**: High-performance settings for CS2.
- **Input**: Mouse precision fixes and keyboard polling rate tweaks (Low End to 8000hz).
- **Revert Options**: Undo all or some changes.
- **Simulation Mode**: Test tweaks without applying.

## Usage
1. **Clone/Download**: Grab the repo or download latest release and unzip if needed.
2. **Run**: (Prompts for Admin privileges)
   - `AWPtimizr.cmd`: Apply or Undo all changes/tweaks with prompts.
3. **Keyboard Selection**: Choose your keyboard type (1-6) in `AWPtimizr`:
   - 1: Low End e.g., Dell KB216, HP K150, Logitech K120, Microsoft Wired 200
   - 2: Mid Tier e.g., Logitech K400 Plus, Corsair K55, Razer Cynosa Lite, SteelSeries Apex 3
   - 3: High End e.g., Corsair K95 RGB, Razer BlackWidow Elite, Logitech G915, SteelSeries Apex Pro, Ducky Ones
   - 4: Wooting 1000hz e.g., Wooting One, Wooting Two, Wooting 60HE
   - 5: Wooting 8000hz e.g., Wooting 60HE+, Wooting Two HE+
   - 6: Other 8000hz e.g., Razer Huntsman V2, SteelSeries Apex Pro TKL HyperMagnetic, Corsair K100 RGB
4. **Reboot**: Required after applying tweaks or reverting.

## Folder Structure
- `1_CPU\AMD\`: AMD-specific tweaks (e.g., `AMD_CPU_Priority.reg`).
- `2_Game\`: CS2 priority tweaks (e.g., `CS2_High_Priority.reg`).
- `3_Services\`: Service disables (e.g., `Disable_Xbox_Services.reg`).
- `4_Input\Mouse\`: Mouse tweaks (e.g., `Disable_Pointer_Precision_Globally_and_Fix_Delay.reg`).
- `4_Input\Keyboard\`: Keyboard tweaks (e.g., `5_Wooting_Latest_Keyboard.reg`).
- `5_Latency\`: Latency tweaks (e.g., `Latency_Tweaks.cmd`).
- `6_Network\`: Network tweaks (e.g., `CS2_Firewall_Rules.cmd`).
- `7_Graphics\`: Graphics tweaks (e.g., `CS2_High_Performance.cmd`).
- `*/Revert\`: Revert scripts (e.g., `Revert_Latency_Tweaks.cmd`).

## Prerequisites
- Windows 11, admin rights.
- Backup your registry (optional but recommended), this program will backup your registry if selected to do so.

## New Features (April 2025 Update)

The `AWPtimizr.cmd` script has been enhanced with the following features:

- **Logging**: All actions (found files, execution, skips, failures) are logged to `Optimization_Log.txt` with timestamps.
- **Backup Option**: Optionally create a registry backup (HKLM\SYSTEM and HKCU) before applying tweaks, saved to a `Backup` folder.
- **Preview Mode**: View the contents of `.reg` files before deciding to execute or skip (type `p` at the prompt).
- **Batch Execution**: Choose at the start to prompt for each file (default), execute all automatically, or skip all.
- **Post-Execution Validation**: Checks if registry keys in `.reg` files exist before applying, with warnings logged if not found.
- **Visual Feedback**: Displays a progress percentage (e.g., `[5/10] [50%]`) alongside file processing status.

### Updates to AWPtimizr.cmd (April 2025)

- **Menu System**: Added a main menu with options to "Run application" (1) or "Exit" (2). After tweak application, the script returns to the menu instead of exiting, allowing multiple runs without restarting the script.
- **Execution Modes**: Enhanced execution mode behavior:
  - **Mode 1 (Prompt)**: Prompts for each file with `Preview/Execute/Skip` options, including a keyboard selection prompt followed by `p/e/s`.
  - **Mode 2 (Execute All)**: Automatically executes all files, prompts for keyboard choice, then auto-executes the selected tweak.
  - **Mode 3 (Skip All)**: Skips all files, including keyboard tweaks, with `4_Wooting_Fullsized_Keyboard.reg` as the default skipped file.
- **Keyboard Selection**: Unified keyboard selection logic across modes:
  - Prompts for keyboard type (1-6) in Modes 1 and 2.
  - Mode 1 allows full control with `p/e/s` after selection.
  - Mode 2 auto-executes the chosen keyboard tweak.
  - Mode 3 skips the keyboard tweak entirely.
- **Error Handling**: Improved handling when no tweak files are found, returning to the menu instead of exiting.
- **Logging**: Continues to log all actions to `Optimization_Log.txt` with timestamps.
- **Backup Exclusion**: Files in the `Backup` folder are now ignored during tweak processing to prevent accidental execution of backup `.reg` files.
- **User-Specific Summaries**: Logs (`Optimization_Log.txt`) and configuration files (`CPUType.txt`) are now saved in a `Summary_%COMPUTERNAME%` folder (e.g., `Summary_DESKTOP-ABC123`) in the main directory, making it easier to track tweaks per machine.
- **Registry Feedback**: Enhanced `.reg` processing to always check and report registry key status ("Key exists" with values or "Key does not exist") before applying tweaks, consistent across `AWPtimizr.cmd`.
- **Simulated Run All**: Updated in `AWPtimizr.cmd` registry feedback, always checking and reporting key status ("Key exists" with values or "Key does not exist") before simulating tweaks with `reg-simulated-import`. Retains selective `.cmd` simulation for `Latency_Tweaks.cmd`.

### Combined AWPtimizr.cmd (April 2025 Update)

The `AWPtimizr.cmd` script now combines the functionality of the previous `Simulated_AWPtimizr.cmd` and `AWPtimizr.cmd` into a single, streamlined tool. Key updates include:

- **Simulation Mode**: Added option 4 ("Simulate all") to the execution mode menu. This runs a dry simulation of all tweaks without applying changes to the registry—perfect for testing.
- **Unified Workflow**: One script handles both real tweak application and simulation, toggling behavior with a `SIMULATE` flag. No need to juggle separate files anymore.
- **Enhanced Comments**: Detailed, meaningful comments added throughout the script to explain each section’s purpose (e.g., backup creation, CPU detection, file processing) and highlight specific logic (e.g., why `Latency_Tweaks.cmd` gets special treatment).
- **Error Handling**: Basic `errorlevel` checks for `reg import` ensure failures (like missing admin rights) are logged and reported.

To use simulation mode:
1. Run `AWPtimizr.cmd`.
2. Select `1` (Run tweaks), `n` (skip backup), then `4` (simulate all).
3. Check `Summary_%COMPUTERNAME%\Optimization_Log.txt` for "Simulated success" entries.

For real tweaks, pick modes 1-3 as before. Logs now distinguish between "Success" (real) and "Simulated success" (dry run).

### Enhanced AWPtimizr.cmd (April 2025 Update)

The `AWPtimizr.cmd` script has been overhauled to align with `AWPtimizr.cmd`, adding menus, logging, and a simulation mode for safer testing. Key updates include:

#### Registry Tweaks for Windows Optimization
This repository includes a collection of `.reg` files to disable various Windows features and services, along with corresponding revert files to restore default settings. All tweaks are designed for Windows 11 (tested against 23H2 defaults as of April 2025) unless noted otherwise. Some revert files have been updated to align with true Windows defaults (e.g., removing policy keys rather than setting them to enabling values).

### April 10, 2025
- Refactored registry backup into a reusable subroutine for consistency and maintainability.
- Improved completion messages to accurately reflect whether tweaks/reverts were applied, simulated, or skipped, avoiding misleading "Restart recommended" prompts when all files are skipped.

**Notes:**
- Run `.reg` files with admin rights. The Copilot revert `.cmd` also requires elevation for the `dism` command.
- Revert files now reflect true Windows 11 defaults (e.g., key absence for policies, corrected service states).
- HomeGroup and WiFi Sense tweaks are legacy; they’re no-ops in Windows 11 but included for older systems.

- **Menu System**: New interactive menu with "Run revert tweaks" (1) and "Exit" (2) options.
- **Execution Modes**: Added four modes: 1 (prompt for each file), 2 (execute all), 3 (skip all), and 4 (simulate all). Mode 4 simulates revert actions without modifying the registry.
- **Logging**: All actions (file detection, application, success/failure) are logged to `Summary_%COMPUTERNAME%\Optimization_Log.txt` with timestamps, matching `AWPtimizr.cmd`.
- **Simulation Mode**: Use mode 4 to preview revert tweaks without changes—outputs `reg-simulated-import` or `call-simulated` instead of real commands.
- **Detailed Comments**: Added specific, meaningful comments explaining each section (e.g., CPU detection, file processing) and logic (e.g., registry key checks).

To test simulation mode:
1. Run `AWPtimizr.cmd`.
2. Select `1` (Run revert tweaks), then `4` (simulate all).
3. Check the log for "Simulated success" entries—no system changes applied.

For real reverts, use modes 1-3. Logs distinguish between "Success" (real) and "Simulated success" (dry run), with a reboot recommended after real runs.

Run the script from `D:\Videos\apps\Windows_Optimizations` with admin privileges to apply tweaks. Ensure all referenced `.reg` and `.cmd` files exist in their respective subfolders for full functionality.

### Usage Notes
- Run scripts with administrative privileges (UAC prompt will appear if needed).
- The user prompt (`Preview (p), Execute (e), or Skip (s)?`).
- Check `Optimization_Log.txt` after execution for a detailed run history.
- Backups are timestamped (e.g., `HKLM_SYSTEM_20250408.reg`) and stored in the `Backup` subfolder.

### Example
```cmd
Choose execution mode:
1: Prompt for each file (default)
2: Execute all automatically
3: Skip all automatically
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
Tweaks based on this video: [Make Your CS2 RUN BETTER - (packet loss, latency, clean)](https://www.youtube.com/watch?v=qG7C4W-EQl4) by [youtube.com/@KEROVSKI_](https://www.youtube.com/@KEROVSKI_).
Need for this repo grew from my TerminalTanks setup; gaming and coding. Pair Win 11 with Powertoys running FancyZones for window snaps and Workspaces for one-click launches (MPC-HC auto-play baked in). For CS2 enjoyers, voyeurs, fish nerds and frame chasers.

## Contribute
- **Bugs** PRs welcome—fork it, tweak it, share it.  
- **License**: GNU  
- **More**: Catch TerminalTanks on YouTube—[youtube.com/@TerminalTanks](https://www.youtube.com/@TerminalTanks).
- **Who**: TerminalTanks(Pb/pdq/idk) is a member of The Smackers.
