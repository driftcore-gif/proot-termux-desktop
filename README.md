# 🐧 Proot-termux-desktop.    v0.30

A universal Linux desktop environment running inside Termux proot with automatic GPU detection, multiple DE support, VNC/TX11 switching, Wine, media players, photo editors, 3D games and Steam/Proton support.

---

## 📱 Minimum Requirements

| Info | Minimum |
|---|---|
| RAM | 4GB |
| Storage | 64GB |
| Android | 8.0+ |
| Chipset | Any (Snapdragon / Dimensity / Exynos / Helio) |

---

## ✨ Features

- 🔍 **Auto GPU detection** — Adreno / Mali / Generic / No HWA
- ⚡ **VirGL acceleration** — Hardware accelerated rendering
- 🖥️ **Multiple DEs** — XFCE, KDE, GNOME, MATE, LXQt, Openbox, i3wm, Cinnamon
- 📺 **TX11 or VNC** — Choose your connection type
- 🐧 **Multiple distros** — Debian, Ubuntu, Arch, Fedora , Void
- 🎬 **Media players** — VLC + MPV
- 🖼️ **Photo editors** — GIMP + Darktable
- 🎙️ **Mic support** — Auto mic module fallback
- 🔊 **Audio** — PulseAudio bridged from Termux to proot

---

## 🔍 Supported GPUs

| GPU | Chipset Examples | Driver |
|---|---|---|
| Adreno | Snapdragon 4xx/6xx/7xx/8xx | VirGL + ANGLE |
| Mali | Exynos / Dimensity / Helio | VirGL + ANGLE |
| Others | Unknown / Generic | VirGL fallback |
| No HWA | Any | llvmpipe (slow) |

---

## 🖥️ Supported Desktop Environments

| DE | RAM Usage | Best For |
|---|---|---|
| XFCE | 🟢 Low | Gaming, daily use |
| Openbox | 🟢 Very low | Minimal, fast |
| i3wm | 🟢 Very low | Keyboard-driven |
| LXQt | 🟢 Low | Lightweight |
| MATE | 🟡 Medium | Classic desktop |
| Cinnamon | 🟡 Medium | Windows-like |
| GNOME | 🔴 High | Modern UI |
| KDE | 🔴 High | Feature-rich |

---

## 📺 Connection Types

| Type | App Needed | Best For |
|---|---|---|
| Termux:X11 | Termux:X11 app | Low latency, local |
| VNC | Any VNC viewer | Remote, flexible |

---

## 🐧 Supported Distros

| Distro | Notes |
|---|---|
| Debian | ✅ Most stable, recommended |
| Ubuntu | ✅ Good compatibility |
| Arch Linux | ⚡ Cutting edge |
| Fedora | ⚠️ Heavier |
| Void.  | 🚫 Not Tested 

---

## 🎬 Apps Included

| Category | Apps |
|---|---|
| Media Player | VLC, MPV |
| Photo Editor | GIMP, Darktable |
| Terminal | XFCE Terminal / Konsole |
| File manager | Thunar / Dolphin / Nemo |

---

## 📂 Repo Structure

```
Debian-termux-desktop/
├── tx11start                        ← universal launcher
├── install.sh                       ← automated installer
├── Proot-setup.sh                  ← manual setup reference
├── README.md
├── LICENSE
├── .gitignore
│
├── setup/
│   └── Proot-setup.sh              ← one-time proot setup
│
├── configuration/
│   ├── adreno/adreno.conf
│   ├── mali/mali.conf
│   ├── others/others.conf
│   └── nohwa/nohwa.conf
│
├── docs/
│   ├── gpu-acceleration.md
│   ├── desktop-environments.md
│   ├── connection-types.md
│   └── phantom-process-fix.md
│
└── other/
    ├── bashrc-additions
    └── termux.properties
```

---

## 🚀 Quick Start

### 1.install git
```bash
pkg install git


### 2.Clone repo
```bash
git clone https://github.com/driftcore-gif/Debian-termux-desktop.git ~/desktop
cd ~/desktop
chmod +x install.sh
```

### 2. Run installer (interactive)
```bash
bash install.sh
```

Installer will ask you to choose:
- 🐧 Distro — Debian / Ubuntu / Arch / Fedora / Void
- 🖥️ DE — XFCE / KDE / GNOME / MATE / LXQt / Openbox / i3wm / Cinnamon
- 📺 Connection — TX11 / VNC
- 🎬 Media, 🖼️ Photo,

### 3. Run proot setup (once)
```bash
bash /data/data/com.termux/files/home/desktop/setup/Proot-setup.sh
```

### 4. Launch anytime
```bash
tx11start
```

---

## 📊 Performance

| GPU | glxgears | Light DE | Heavy DE |
|---|---|---|---|
| Adreno 6xx | 100–200 FPS | ✅ Good | ⚠️ Slow |
| Adreno 7xx/8xx | 200+ FPS | ✅ Good | ✅ OK |
| Mali | 80–150 FPS | ✅ Good | ⚠️ Slow |
| Generic | 30–80 FPS | ⚠️ OK | ❌ Slow |

---

## 📖 Docs

- [GPU Acceleration](docs/gpu-acceleration.md)
- [Desktop Environments](docs/desktop-environments.md)
- [Connection Types](docs/connection-types.md)
- [Apps — Media, Photo ](docs/apps.md)
- [Phantom Process Fix](docs/phantom-process-fix.md)

---

## ⚠️ Known Limitations

- No real GPU passthrough — VirGL is a translation layer
- Android 12+ may kill background processes — see phantom process fix
- Systemd unavailable in proot — some warnings are normal
- KDE and GNOME need 6GB+ RAM

---

## 🔧 Phantom Process Fix (Android 12+)

```bash
pkg install android-tools -y
# Enable Wireless Debugging in Developer Options
adb pair IP:PORT
adb connect IP:PORT
adb shell "device_config set_sync_disabled_for_tests persistent"
adb shell "device_config put activity_manager max_phantom_processes 2147483647"
```

---

## 📦 Credits

- [Termux](https://termux.dev)
- [proot-distro](https://github.com/termux/proot-distro)
- [Termux:X11](https://github.com/termux/termux-x11)
- [VirGL Android](https://github.com/termux/termux-packages)

---

## 📜 License
MIT
