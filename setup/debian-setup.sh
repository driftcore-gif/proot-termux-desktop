#!/bin/bash
# debian-setup.sh — Run inside proot
# proot-distro login debian --shared-tmp
# bash ~/desktop/setup/debian-setup.sh

apt install -y dialog 2>/dev/null
TMP=$(mktemp)
TMP2=$(mktemp)

# ─────────────────────────────────────────────
# Logging helpers
# ─────────────────────────────────────────────
LOG_STEP=0
log_step() {
  LOG_STEP=$((LOG_STEP + 1))
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Step $LOG_STEP: $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}
log_ok()   { echo "  ✅ $1"; }
log_warn() { echo "  ⚠️  $1"; }
log_info() { echo "  ℹ️  $1"; }
log_pkg()  { echo "  📦 Installing: $1..."; }
log_skip() { echo "  ⏭️  Skipping: $1"; }

# ─────────────────────────────────────────────
# Welcome
# ─────────────────────────────────────────────
dialog --title "Proot-termux-desktop v0.40" \
  --msgbox "\nDebian Proot Setup\n\nAll output is shown on screen." 8 45

# ─────────────────────────────────────────────
# Select DE
# ─────────────────────────────────────────────
dialog --title "Select Desktop Environment" \
  --menu "\nChoose your desktop environment:" 18 58 8 \
  "xfce"     "🟢 XFCE      — Lightweight (recommended)" \
  "kde"      "🔴 KDE       — Feature rich (6GB+ RAM)"   \
  "gnome"    "🔴 GNOME     — Modern UI (6GB+ RAM)"      \
  "mate"     "🟡 MATE      — Classic desktop"            \
  "lxqt"     "🟢 LXQt      — Lightweight Qt"             \
  "openbox"  "🟢 Openbox   — Minimal WM"                 \
  "i3wm"     "🟢 i3wm      — Tiling WM"                  \
  "cinnamon" "🟡 Cinnamon  — Windows-like"               \
  2>"$TMP"

DE=$(cat "$TMP")
[[ -z "$DE" ]] && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

# ─────────────────────────────────────────────
# Select optional apps
# ─────────────────────────────────────────────
dialog --title "Optional Apps" \
  --checklist "\nSelect apps to install:\n(Space to select)" 18 58 6 \
  "media"   "VLC + MPV media players"              ON  \
  "photo"   "GIMP + Darktable photo editors"       ON  \
  "games"   "3D Linux games (arch-aware)"          ON  \
  "wine"    "Wine + Winetricks (experimental)"     OFF \
  "steam"   "Steam + Proton (x86_64 only)"         OFF \
  "qemu"    "QEMU Manager (aarch64)"               OFF \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")
ARCH=$(dpkg --print-architecture)

dialog --title "Confirm" \
  --yesno "\nDE     : $DE\nArch   : $ARCH\nApps   : $SELECTED\n\nProceed?" 12 48
[[ $? -ne 0 ]] && rm -f "$TMP" "$TMP2" && exit 0
clear

# ─────────────────────────────────────────────
echo "  Distro : Debian  |  DE : $DE  |  Arch : $ARCH"
echo "  Date   : $(date)"
echo ""

# ─────────────────────────────────────────────
log_step "Updating Debian packages"
apt update -y
apt upgrade -y
log_ok "System updated"

# ─────────────────────────────────────────────
log_step "Installing base tools"
log_pkg "dbus dbus-x11 wget curl git nano"
apt install -y dbus dbus-x11 wget curl git nano
log_pkg "mesa-utils libgl1-mesa-dri libvulkan1"
apt install -y mesa-utils libgl1-mesa-dri libvulkan1
log_pkg "gtk2-engines-murrine greybird-gtk-theme"
apt install -y gtk2-engines-murrine gtk2-engines-pixbuf greybird-gtk-theme
log_ok "Base tools installed"

# ─────────────────────────────────────────────
log_step "Installing desktop environment: $DE"
case "$DE" in
  "xfce")
    log_pkg "xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar"
    apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar
    ;;
  "kde")
    log_warn "KDE is heavy — needs 6GB+ RAM"
    log_pkg "kde-plasma-desktop konsole dolphin"
    apt install -y kde-plasma-desktop konsole dolphin 2>/dev/null || log_warn "KDE may be unavailable for $ARCH"
    ;;
  "gnome")
    log_warn "GNOME is heavy — needs 6GB+ RAM"
    log_pkg "gnome-shell gnome-terminal nautilus gnome-tweaks"
    apt install -y gnome-shell gnome-terminal nautilus gnome-tweaks 2>/dev/null || log_warn "GNOME may be unavailable for $ARCH"
    ;;
  "mate")
    log_pkg "mate-desktop-environment mate-terminal caja"
    apt install -y mate-desktop-environment mate-terminal caja
    ;;
  "lxqt")
    log_pkg "lxqt lxterminal pcmanfm-qt"
    apt install -y lxqt lxterminal pcmanfm-qt
    ;;
  "openbox")
    log_pkg "openbox obconf tint2 lxterminal pcmanfm"
    apt install -y openbox obconf tint2 lxterminal pcmanfm
    ;;
  "i3wm")
    log_pkg "i3 i3status dmenu lxterminal"
    apt install -y i3 i3status dmenu lxterminal
    ;;
  "cinnamon")
    log_pkg "cinnamon cinnamon-core gnome-terminal nemo"
    apt install -y cinnamon cinnamon-core gnome-terminal nemo 2>/dev/null || log_warn "Cinnamon may be unavailable for $ARCH"
    ;;
esac
log_ok "$DE installed"

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "media"; then
  log_step "Installing media players (VLC + MPV)"
  log_pkg "vlc mpv"
  apt install -y vlc mpv && log_ok "Media players installed" || log_warn "Some media packages unavailable for $ARCH"
else
  log_skip "Media players"
fi

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "photo"; then
  log_step "Installing photo editors (GIMP + Darktable)"
  log_pkg "gimp darktable"
  apt install -y gimp darktable && log_ok "Photo editors installed" || log_warn "Some photo packages unavailable for $ARCH"
else
  log_skip "Photo editors"
fi

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "games"; then
  log_step "Installing 3D Linux games ($ARCH)"
  log_pkg "supertuxkart neverball extremetuxracer freedoom pingus"
  apt install -y supertuxkart neverball extremetuxracer freedoom pingus 2>/dev/null
  if [[ "$ARCH" == "amd64" ]]; then
    log_pkg "openarena xonotic (x86_64 only)"
    apt install -y openarena xonotic 2>/dev/null
    log_ok "Games installed (including x86_64 titles)"
  else
    log_info "Skipping xonotic/openarena — $ARCH not supported"
    log_ok "Games installed (ARM-compatible titles)"
  fi
else
  log_skip "3D games"
fi

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "wine"; then
  log_step "Installing Wine (experimental)"
  log_pkg "wine wine64 wine32 winetricks (i386)"
  dpkg --add-architecture i386
  apt update -y
  apt install -y wine wine64 wine32 winetricks 2>/dev/null \
    && log_ok "Wine installed" \
    || log_warn "Wine unavailable for $ARCH"
else
  log_skip "Wine"
fi

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "steam"; then
  log_step "Installing Steam + Proton (x86_64 only)"
  if [[ "$ARCH" != "amd64" ]]; then
    log_warn "Steam is x86_64 only — skipping on $ARCH"
  else
    log_pkg "Steam dependencies (i386)"
    dpkg --add-architecture i386 && apt update -y
    apt install -y libgl1-mesa-dri:i386 libgl1:i386 libc6:i386 \
      libstdc++6:i386 libsdl2-2.0-0 zenity 2>/dev/null
    log_pkg "Steam .deb"
    wget -q --show-progress -O /tmp/steam.deb \
      "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
    dpkg -i /tmp/steam.deb 2>/dev/null || apt --fix-broken install -y
    rm -f /tmp/steam.deb
    log_ok "Steam installed — run: steam"
    log_info "Enable Proton: Steam → Settings → Compatibility → Enable Steam Play"
  fi
else
  log_skip "Steam"
fi

# ─────────────────────────────────────────────
if echo "$SELECTED" | grep -q "qemu"; then
  log_step "Installing QEMU Manager"
  if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    log_pkg "qemu-manager aarch64"
    log_info "Downloading from GitHub releases..."
    wget -q --show-progress -O /tmp/qemu-manager.deb \
      "https://github.com/driftcore-gif/qemu-manager/releases/download/v1.0.0/qemu-manager_aarch64.deb"
    if [[ $? -eq 0 ]]; then
      dpkg -i /tmp/qemu-manager.deb 2>/dev/null || apt --fix-broken install -y
      rm -f /tmp/qemu-manager.deb
      log_ok "QEMU Manager installed"
      log_info "Launch with: qemu-manager"
    else
      log_warn "Download failed — check your internet connection"
    fi
  else
    log_warn "QEMU Manager .deb is aarch64 only — skipping on $ARCH"
  fi
else
  log_skip "QEMU Manager"
fi

# ─────────────────────────────────────────────
log_step "Writing environment to ~/.bashrc"
cat >> ~/.bashrc << 'EOF'

# === Proot Desktop ENV ===
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export WINEDEBUG=-all
export WINEPREFIX=~/.wine
export mesa_glthread=true
export MESA_NO_ERROR=1
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
fi
echo "🎮 Proot env loaded"
EOF
log_ok "~/.bashrc updated"

source ~/.bashrc 2>/dev/null
eval $(dbus-launch --sh-syntax) 2>/dev/null

# ─────────────────────────────────────────────
if [[ "$DE" == "xfce" ]]; then
  log_step "Applying XFCE theme"
  xfconf-query -c xsettings  -p /Net/ThemeName     -s "Greybird"     2>/dev/null && log_info "GTK theme: Greybird"
  xfconf-query -c xfwm4      -p /general/theme      -s "Greybird"     2>/dev/null && log_info "WM theme: Greybird"
  xfconf-query -c xfwm4      -p /general/use_compositing -s false     2>/dev/null && log_info "Compositor: disabled"
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" \
    -n -t string -s "xfce4-popup-whiskermenu" 2>/dev/null && log_info "Super key: Whiskermenu"
  log_ok "XFCE theme applied"
fi

rm -f "$TMP" "$TMP2"

# ─────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Debian setup complete!"
echo "  DE     : $DE"
echo "  Arch   : $ARCH"
echo "  Apps   : $SELECTED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  👉 Exit proot: exit"
echo "  👉 Launch:     tx11start"
echo ""
