# TerminalTanks Windows Optimizations

Boost your Windows 11 gaming rig with TerminalTanks—a collection of `.reg` and `.cmd` scripts to tweak CPU, game priorities, services, latency, network, graphics, and input settings for max performance. Built for CS2 (~300 FPS) and Topaz Video AI (16.7/15.7 FPS) on a Ryzen 7 7800X3D, ZOTAC RTX 4080 SUPER, 32GB RAM setup (driver 572.70, MSI MPG A1000G 1000W PSU).

## Features
- **CPU Tweaks**: AMD/Intel-specific optimizations.
- **Game Tweaks**: High priority and thread settings for CS2.
- **Services**: Disable unnecessary Windows services (Bluetooth, Xbox, etc.).
- **Latency**: Dynamic tick, HPET, and synthetic timer adjustments.
- **Network**: Firewall rules for CS2.
- **Graphics**: High-performance settings for CS2.
- **Input**: Mouse precision fixes and keyboard polling rate tweaks (Low End to 8000hz).
- **Revert Options**: Undo all changes with `Revert_All.cmd`.
- **Simulation Mode**: Test tweaks without applying (`Simulate_Run_All.cmd`).

## Usage
1. **Clone/Download**: Grab the repo to `D:\Videos\apps\Windows_Optimizations\`.
2. **Run as Admin**:
   - `Run_All.cmd`: Apply tweaks with prompts (keyboard menu for `4_Input\Keyboard`).
   - `Simulate_Run_All.cmd`: Preview tweaks (simulates `.reg`, mocks `Latency_Tweaks.cmd`).
   - `Revert_All.cmd`: Undo all changes (auto-runs `Revert/` files).
   - `Simulate_Revert_All.cmd`: Preview revert process.
3. **Keyboard Selection**: Choose your keyboard type (1-6) in `Run_All`/`Simulate_Run_All`:
   - 1: Low End
   - 2: Mid Tier
   - 3: High End
   - 4: Wooting 1000hz
   - 5: Wooting 8000hz
   - 6: Other 8000hz
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

## Registry Key Echo
- `Run_All.cmd`: Shows "Prior" and "After" values for all `.reg` keys affected—check before/after states.
- `Simulate_Run_All.cmd`: Simulates `.reg` changes, echoes "Prior" values only.

## Prerequisites
- Windows 11, admin rights.
- Backup your registry (optional but recommended).

## Commit History
- Latest: "Fixed keyboard menu, added registry key echo in Run_All/Simulate_Run_All" - April 08, 2025.

## New Features (April 2025 Update)

The `Simulated_Run_All.cmd` and `Run_All.cmd` scripts have been enhanced with the following features:

- **Logging**: All actions (found files, execution, skips, failures) are logged to `Optimization_Log.txt` with timestamps.
- **Backup Option**: Optionally create a registry backup (HKLM\SYSTEM and HKCU) before applying tweaks, saved to a `Backup` folder.
- **Preview Mode**: View the contents of `.reg` files before deciding to execute or skip (type `p` at the prompt).
- **Batch Execution**: Choose at the start to prompt for each file (default), execute all automatically, or skip all.
- **Post-Execution Validation**: Checks if registry keys in `.reg` files exist before applying, with warnings logged if not found.
- **Visual Feedback**: Displays a progress percentage (e.g., `[5/10] [50%]`) alongside file processing status.

### Updates to Run_All.cmd (April 2025)

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
- **Registry Feedback**: Enhanced `.reg` processing to always check and report registry key status ("Key exists" with values or "Key does not exist") before applying tweaks, consistent across `Run_All.cmd` and `Simulated_Run_All.cmd`.
- **Simulated_Run_All.cmd**: Updated to match `Run_All.cmd` registry feedback, always checking and reporting key status ("Key exists" with values or "Key does not exist") before simulating tweaks with `reg-simulated-import`. Retains selective `.cmd` simulation for `Latency_Tweaks.cmd`.

Run the script from `D:\Videos\apps\Windows_Optimizations` with admin privileges to apply tweaks. Ensure all referenced `.reg` and `.cmd` files exist in their respective subfolders for full functionality.

### Usage Notes
- Run scripts with administrative privileges (UAC prompt will appear if needed).
- The user prompt (`Preview (p), Execute (e), or Skip (s)?`) is now in bold yellow for better visibility.
- Check `Optimization_Log.txt` after execution for a detailed run history.
- Backups are timestamped (e.g., `HKLM_SYSTEM_20250408.reg`) and stored in the `Backup` subfolder.

### Example
```cmd
Choose execution mode:
1: Prompt for each file (default)
2: Execute all automatically
3: Skip all automatically
Enter choice (1-3): 1

[1/10] [10%] Found: Disable_Telemetry.reg
Preview (p), Execute (e), or Skip (s)? e
[1/10] Applying: Disable_Telemetry.reg
[1/10] Success: Disable_Telemetry.reg
```

## Notes
- Tested on Ryzen 7 7800X3D, RTX 4080 SUPER.
- Create `CPUType.txt` if missing—script auto-detects AMD/Intel.
- Report issues on GitHub: `https://github.com/The-Smackers/Windows_Optimizations`.

## Why?
Tweaks based on this video: [Make Your CS2 RUN BETTER - (packet loss, latency, clean)](https://www.youtube.com/watch?v=qG7C4W-EQl4) by [youtube.com/@KEROVSKI_](https://www.youtube.com/@KEROVSKI_).
Need for this repo grew from my TerminalTanks setup; gaming, coding, plants, and planted tanks. Pair Win 11 with Powertoys running FancyZones for window snaps and Workspaces for one-click launches (MPC-HC auto-play baked in). For CS2 enjoyers, voyeurs, fish nerds and frame chasers.

## Contribute
Bugs? PRs welcome—fork it, tweak it, share it.  
**License**: GNU  
**More**: Catch TerminalTanks on YouTube—[youtube.com/@TerminalTanks](https://www.youtube.com/@TerminalTanks).
