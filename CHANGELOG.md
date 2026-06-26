# Changelog

## [v0.40] — 2026-05-27
### Added
- dialog TUI on all setup menus (like termux-change-repo)
- On-screen logging for all distro setup scripts (log_step/log_ok/log_warn)
- QEMU Manager support (aarch64 .deb from GitHub releases)
- Void Linux distro support (xbps)
- NVIDIA, Intel IGP, Rockchip GPU support
- Separate setup file per distro (correct package manager per distro)
- DE selection inside proot (no Termux sync issues)
- Architecture detection (armhf/arm64/amd64 aware)
- Steam + Proton (x86_64 only)
- x11-repo + root-repo auto-enabled in install.sh

### Changed
- install.sh minimal — Termux deps + proot only
- DE/app selection moved to DISTRO-setup.sh inside proot
- Games filtered by arch (xonotic/openarena x86_64 only)

### Fixed
- Package skipping bug (x11-repo must be installed before virglrenderer)
- sh vs bash shebang issues
- Variable sync between Termux and proot

## [v0.30] — 2026-05
### Added
- Multi-distro (Debian, Ubuntu, Arch, Fedora)
- Multi-DE (XFCE, KDE, GNOME, MATE, LXQt, Openbox, i3wm, Cinnamon)
- VLC + MPV, GIMP + Darktable, Wine, Steam, 3D games
- Auto GPU detection (Adreno/Mali)

## [v0.20] — 2026-04
### Added
- Universal tx11start, VirGL, PulseAudio, dbus fix, Greybird theme

## [v0.10] — 2026-03
### Added
- Initial Debian proot + XFCE4, Termux:X11, basic VirGL
