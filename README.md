# Windows Optimizations
Welcome to my Windows tweaks repo—straight from the TerminalTanks lab (Ryzen 7 7800X3D, RTX 4080 Super, Win11 23H2). These registry and system tweaks juice up gaming (CS2 ~600 FPS), video workflows (Topaz 16.7 FPS), and terminal snap. Built for my Wooting full-size (1000Hz) and eyeing 80HE dreams (8000Hz)—now yours to fork and frag.

## What’s Inside
Tweaks are split into subfolders—numbered for order, packed with `.reg` files and a `.cmd`:

- **`1 Mouse Optimization`**  
  - `MouseTweaks.reg`: Sensitivity and curves—CS2 aim precision.  
  - `RevertMouse.reg`: Back to stock mouse settings.

- **`2 CS2 Optimization`**  
  - `CS2 PerfOptions Priority.reg`: High CPU priority for CS2 (~290 > 300 FPS).  
  - `Games Priority AMD.reg`: AMD-optimized gaming priority.  
  - `Games Priority Intel.reg`: Intel-tuned gaming boost.  
  - `PriorityControl.reg`: Foreground boost (`Win32PrioritySeparation=22`).  
  - `ThreadPriority.reg`: USB/NVIDIA drivers at Above Normal (15).

- **`3 Keyboard Optimization`**  
  - `LowEndKeyboard.reg`: Budget keys—stable, stock-like (100 queue).  
  - `MidTierGamingKeyboard.reg`: Mid-tier gaming (80 queue)—Razer, Corsair, Logitech.  
  - `WootingFullSizeOptimized.reg`: My Wooting (1000Hz)—tight 50 queue.  
  - `Wooting80HE.reg`: New Wooting (8000Hz)—40 queue for rapid trigger.  
  - `8000HzKeyboards.reg`: Generic 8000Hz boards—48 queue, broad fit.

- **`4 Services Optimization`**  
  - `DisableServices.reg`: Cuts `wuauserv` (updates), `SysMain` (prefetch), `DiagTrack` (telemetry)—lean CPU.

- **`5 Revert Optimization`**  
  - `CS2 Revert.reg`: Resets CS2 priority.  
  - `Games Priority Revert.reg`: Stock gaming settings.  
  - `Keyboard Revert.reg`: Keyboard to 100 queue.  
  - `Mouse Revert.reg`: Stock mouse.  
  - `PriorityControl Revert.reg`: `Win32PrioritySeparation=38`.  
  - `Services Revert.reg`: Restores services.  
  - `ThreadPriority Revert.reg`: USB/NVIDIA to default.  
  - `full_reset.cmd`: Runs all reverts silently.

- **`5 Latency Tweaks`**  
  - `Latency_Tweaks.cmd`: Disables dynamic tick, HPET—lowers input lag (UAC-enabled).

- **`6 Firewall Optimization`**  
  - `CS2 Firewall Rules.cmd`: Allows inbound/outbound for `cs2.exe`—auto-detects path, skips if rules exist, saves to `CS2Path.txt`.
  - `Revert CS2 Firewall Rules.cmd`: Removes CS2 firewall rules.

## Usage
1. **Tweaks**: Double-click `.reg` files or `Latency_Tweaks.cmd`—UAC will prompt for admin rights.  
2. **Revert**: Pick specific reverts or use `full_reset.cmd` for a full rollback.  
3. **Reboot**: Most tweaks need a restart—CS2 feels it, Topaz doesn’t care.  
4. **Backup**: Export your registry first—safety’s clutch (`reg export HKLM\backup.reg`).

## Results
- **CS2**: ~590 > 700 FPS, aim, tighter input (Wooting + latency tweaks).  
- **Topaz**: Stable 16.7 FPS—services cut helps CPU breathe.  
- **System**: Leaner, snappier—7800X3D/4080 Super approved.

## Why?
Tweaks based on this video: [Make Your CS2 RUN BETTER - (packet loss, latency, clean)](https://www.youtube.com/watch?v=qG7C4W-EQl4) by [youtube.com/@KEROVSKI_](https://www.youtube.com/@KEROVSKI_).
Need for this repo grew from my TerminalTanks setup; gaming, coding, plants, and planted tanks. Pair Win 11 with Powertoys running FancyZones for window snaps and Workspaces for one-click launches (MPC-HC auto-play baked in). For CS2 enjoyers, voyeurs, fish nerds and frame chasers.

## Contribute
Bugs? PRs welcome—fork it, tweak it, share it.  
**License**: GNU  
**More**: Catch TerminalTanks on YouTube—[youtube.com/@TerminalTanks](https://www.youtube.com/@TerminalTanks).
