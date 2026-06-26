#!/bin/bash
# archlinux-setup.sh — Run inside proot
# proot-distro login archlinux --shared-tmp
# bash ~/desktop/setup/archlinux-setup.sh

pacman -S --noconfirm dialog 2>/dev/null
TMP=$(mktemp)
TMP2=$(mktemp)

LOG_STEP=0
log_step() { LOG_STEP=$((LOG_STEP+1)); echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "  Step $LOG_STEP: $1"; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }
log_ok()   { echo "  ✅ $1"; }
log_warn() { echo "  ⚠️  $1"; }
log_info() { echo "  ℹ️  $1"; }
log_pkg()  { echo "  📦 Installing: $1..."; }
log_skip() { echo "  ⏭️  Skipping: $1"; }

dialog --title "Proot-termux-desktop v0.40" \
  --msgbox "\nArch Linux Proot Setup\n\nAll output shown on screen." 8 48

dialog --title "Select Desktop" \
  --menu "\nChoose desktop environment:" 18 58 8 \
  "xfce" "🟢 XFCE — Lightweight (recommended)" \
  "kde" "🔴 KDE — Feature rich (6GB+ RAM)" \
  "gnome" "🔴 GNOME — Modern UI (6GB+ RAM)" \
  "mate" "🟡 MATE — Classic desktop" \
  "lxqt" "🟢 LXQt — Lightweight Qt" \
  "openbox" "🟢 Openbox — Minimal WM" \
  "i3wm" "🟢 i3wm — Tiling WM" \
  "cinnamon" "🟡 Cinnamon — Windows-like" \
  2>"$TMP"

DE=$(cat "$TMP")
[[ -z "$DE" ]] && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

dialog --title "Optional Apps" \
  --checklist "\nSelect apps:" 18 58 5 \
  "media"  "VLC + MPV"                          ON  \
  "photo"  "GIMP + Darktable"                   ON  \
  "games"  "3D Linux games (arch-aware)"        ON  \
  "wine"   "Wine (experimental)"                OFF \
  "qemu"   "QEMU Manager (aarch64, manual deb)" OFF \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")
ARCH=$(uname -m)

dialog --title "Confirm" \
  --yesno "\nDE : $DE | Arch : $ARCH\nApps : $SELECTED\n\nProceed?" 10 48
[[ $? -ne 0 ]] && rm -f "$TMP" "$TMP2" && exit 0
clear

echo "  Distro : Arch Linux  |  DE : $DE  |  Arch : $ARCH"
echo "  Date   : $(date)"

log_step "Updating Arch packages"
pacman -Syu --noconfirm
log_ok "System updated"

log_step "Installing base tools"
log_pkg "dbus git wget curl nano mesa vulkan-loader"
pacman -S --noconfirm dbus git wget curl nano mesa vulkan-loader lib32-mesa
log_ok "Base tools installed"

log_step "Installing desktop: $DE"
case "$DE" in
  "xfce")     log_pkg "xfce4 xfce4-goodies xfce4-terminal thunar"; pacman -S --noconfirm xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      log_warn "KDE heavy"; pacman -S --noconfirm plasma konsole dolphin 2>/dev/null || log_warn "KDE install failed" ;;
  "gnome")    log_warn "GNOME heavy"; pacman -S --noconfirm gnome gnome-terminal 2>/dev/null || log_warn "GNOME install failed" ;;
  "mate")     pacman -S --noconfirm mate mate-terminal 2>/dev/null ;;
  "lxqt")     pacman -S --noconfirm lxqt lxterminal 2>/dev/null ;;
  "openbox")  pacman -S --noconfirm openbox tint2 lxterminal 2>/dev/null ;;
  "i3wm")     pacman -S --noconfirm i3 dmenu 2>/dev/null ;;
  "cinnamon") pacman -S --noconfirm cinnamon gnome-terminal 2>/dev/null || log_warn "Cinnamon install failed" ;;
esac
log_ok "$DE installed"

if echo "$SELECTED" | grep -q "media"; then
  log_step "Installing media players"
  log_pkg "vlc mpv"; pacman -S --noconfirm vlc mpv && log_ok "Media installed" || log_warn "Some unavailable"
else log_skip "Media players"; fi

if echo "$SELECTED" | grep -q "photo"; then
  log_step "Installing photo editors"
  log_pkg "gimp darktable"; pacman -S --noconfirm gimp darktable && log_ok "Photo installed" || log_warn "Some unavailable"
else log_skip "Photo editors"; fi

if echo "$SELECTED" | grep -q "games"; then
  log_step "Installing 3D games ($ARCH)"
  pacman -S --noconfirm supertuxkart neverball freedoom 2>/dev/null
  [[ "$ARCH" == "x86_64" ]] && pacman -S --noconfirm xonotic openarena 2>/dev/null && log_info "x86_64 games included"
  log_ok "Games installed"
else log_skip "3D games"; fi

if echo "$SELECTED" | grep -q "wine"; then
  log_step "Installing Wine (experimental)"
  log_pkg "wine wine-mono lib32-glibc"
  pacman -S --noconfirm wine wine-mono lib32-glibc 2>/dev/null && log_ok "Wine installed" || log_warn "Wine failed"
else log_skip "Wine"; fi

if echo "$SELECTED" | grep -q "qemu"; then
  log_step "Installing QEMU Manager"
  if [[ "$ARCH" == "aarch64" ]]; then
    log_info "Downloading qemu-manager_aarch64.deb..."
    log_warn "Arch Linux uses pacman — installing .deb via manual extraction"
    wget -q --show-progress -O /tmp/qemu-manager.deb \
      "https://github.com/driftcore-gif/qemu-manager/releases/download/v1.0.0/qemu-manager_aarch64.deb"
    if [[ $? -eq 0 ]]; then
      mkdir -p /tmp/qemu-mgr-extract
      cd /tmp/qemu-mgr-extract
      ar x /tmp/qemu-manager.deb 2>/dev/null
      tar -xf data.tar* -C / 2>/dev/null
      cd ~ && rm -rf /tmp/qemu-mgr-extract /tmp/qemu-manager.deb
      log_ok "QEMU Manager extracted to system"
    else
      log_warn "Download failed — check internet connection"
    fi
  else
    log_warn "QEMU Manager .deb is aarch64 only — skipping on $ARCH"
  fi
else log_skip "QEMU Manager"; fi

log_step "Writing ~/.bashrc"
cat >> ~/.bashrc << 'EOF'

export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export mesa_glthread=true
export MESA_NO_ERROR=1
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
fi
echo "🎮 Proot env loaded"
EOF
log_ok "~/.bashrc updated"

eval $(dbus-launch --sh-syntax) 2>/dev/null
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"

echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Arch Linux setup complete!"
echo "  DE : $DE  |  Arch : $ARCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  👉 exit  →  tx11start"
