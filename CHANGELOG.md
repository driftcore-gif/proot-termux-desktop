# Changelog

All notable changes to Proot-termux-desktop are documented here.

---

## [v0.40] — 2026-05-27

### Added
- Blue background UI on all setup menus (like termux-change-repo style)
- Void Linux distro support (xbps package manager)
- NVIDIA GPU support (Tegra / Shield / Android x86)
- Intel IGP support (Android x86 / BlissOS / PrimeOS)
- Rockchip GPU support (TS6 / TS7 car players / RK3566/68/88)
- Separate setup file per distro (debian/ubuntu/archlinux/fedora/void)
- DE selection moved inside proot setup (no Termux sync issues)
- App selection (Wine/Media/Photo/Games) inside proot setup
- Architecture detection (ARMhf vs ARM64 vs x86_64)
- 3D Linux games support (architecture-aware)
- Steam + Proton support (x86_64 only)
- VNC connection type support
- TX11 / VNC selection in install.sh

### Changed
- install.sh is now minimal — only installs Termux deps + proot
- Distro and DE selection moved from install.sh to per-distro setup files
- Games list filtered by architecture (xonotic/openarena x86_64 only)
- tx11start now reads DE from ~/.proot-de file (no variable sync)

### Fixed
- Variable sync bug between Termux and proot
- sh vs bash shebang issue on some devices
- Junk folder created by old mkdir brace expansion

---

## [v0.30] — 2026-05

### Added
- Multi-distro support (Debian, Ubuntu, Arch Linux, Fedora)
- Multiple DE support (XFCE, KDE, GNOME, MATE, LXQt, Openbox, i3wm, Cinnamon)
- VLC + MPV media players
- GIMP + Darktable photo editors
- Wine + Winetricks support (experimental)
- Steam + Proton (experimental)
- SuperTuxKart, Xonotic, OpenArena, Freedoom, Neverball game support
- Interactive installer (install.sh)
- Auto GPU detection (Adreno / Mali / Generic)
- VirGL GPU acceleration
- PulseAudio + mic support (module-sles-source fallback)
- Phantom process fix documentation

### Changed
- Repo renamed to debian-termux-desktop

---

## [v0.20] — 2026-04

### Added
- Universal tx11start launcher
- Auto GPU detection (Adreno/Mali)
- VirGL (virpipe) + ANGLE support
- PulseAudio bridging from Termux
- dbus system bus fix before XFCE session
- xfwm4 compositor disabled for VirGL compatibility
- Whiskermenu start menu
- Greybird GTK theme
- GitHub repo structure

### Fixed
- xfwm4 compositing causing black screen with VirGL
- dbus session not starting inside proot
- module-android-source-compat failure (switched to sles-source)

---

## [v0.10] — 2026-03

### Added
- Initial Debian proot + XFCE4 setup
- Termux:X11 display server support
- Basic VirGL setup for Adreno 610 (Snapdragon 680)
- tx11start basic launcher script
- glxgears confirmed ~150 FPS on Adreno 610
