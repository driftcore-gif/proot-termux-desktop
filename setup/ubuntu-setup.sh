#!/bin/bash
# ubuntu-setup.sh — Run inside proot
# proot-distro login ubuntu --shared-tmp
# bash ~/desktop/setup/ubuntu-setup.sh

apt install -y dialog 2>/dev/null
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
  --msgbox "\nUbuntu Proot Setup\n\nAll output shown on screen." 8 45

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
  --checklist "\nSelect apps:" 18 58 6 \
  "media"  "VLC + MPV"                          ON  \
  "photo"  "GIMP + Darktable"                   ON  \
  "games"  "3D Linux games (arch-aware)"        ON  \
  "wine"   "Wine + Winetricks (experimental)"   OFF \
  "steam"  "Steam + Proton (x86_64 only)"       OFF \
  "qemu"   "QEMU Manager (aarch64)"             OFF \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")
ARCH=$(dpkg --print-architecture)

dialog --title "Confirm" \
  --yesno "\nDE : $DE | Arch : $ARCH\nApps : $SELECTED\n\nProceed?" 10 48
[[ $? -ne 0 ]] && rm -f "$TMP" "$TMP2" && exit 0
clear

echo "  Distro : Ubuntu  |  DE : $DE  |  Arch : $ARCH"
echo "  Date   : $(date)"

log_step "Updating Ubuntu packages"
apt update -y && apt upgrade -y
log_ok "System updated"

log_step "Installing base tools"
log_pkg "dbus dbus-x11 wget curl git nano mesa-utils libgl1-mesa-dri"
apt install -y dbus dbus-x11 wget curl git nano mesa-utils libgl1-mesa-dri libvulkan1 \
  gtk2-engines-murrine gtk2-engines-pixbuf
log_ok "Base tools installed"

log_step "Installing desktop: $DE"
case "$DE" in
  "xfce")     log_pkg "xfce4 xfce4-goodies xfce4-terminal thunar"; apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      log_warn "KDE heavy — 6GB+ RAM"; apt install -y kde-plasma-desktop konsole dolphin 2>/dev/null || log_warn "KDE unavailable" ;;
  "gnome")    log_warn "GNOME heavy — 6GB+ RAM"; apt install -y gnome-shell gnome-terminal nautilus 2>/dev/null || log_warn "GNOME unavailable" ;;
  "mate")     log_pkg "mate-desktop-environment"; apt install -y mate-desktop-environment mate-terminal caja ;;
  "lxqt")     log_pkg "lxqt lxterminal"; apt install -y lxqt lxterminal pcmanfm-qt ;;
  "openbox")  log_pkg "openbox tint2 lxterminal"; apt install -y openbox tint2 lxterminal pcmanfm ;;
  "i3wm")     log_pkg "i3 dmenu lxterminal"; apt install -y i3 i3status dmenu lxterminal ;;
  "cinnamon") log_pkg "cinnamon gnome-terminal"; apt install -y cinnamon cinnamon-core gnome-terminal nemo 2>/dev/null || log_warn "Cinnamon unavailable" ;;
esac
log_ok "$DE installed"

if echo "$SELECTED" | grep -q "media"; then
  log_step "Installing media players"
  log_pkg "vlc mpv"; apt install -y vlc mpv && log_ok "Media installed" || log_warn "Some media unavailable"
else log_skip "Media players"; fi

if echo "$SELECTED" | grep -q "photo"; then
  log_step "Installing photo editors"
  log_pkg "gimp darktable"; apt install -y gimp darktable && log_ok "Photo editors installed" || log_warn "Some unavailable"
else log_skip "Photo editors"; fi

if echo "$SELECTED" | grep -q "games"; then
  log_step "Installing 3D games ($ARCH)"
  apt install -y supertuxkart neverball extremetuxracer freedoom pingus 2>/dev/null
  [[ "$ARCH" == "amd64" ]] && apt install -y openarena xonotic 2>/dev/null && log_info "x86_64 games included"
  log_ok "Games installed"
else log_skip "3D games"; fi

if echo "$SELECTED" | grep -q "wine"; then
  log_step "Installing Wine (experimental)"
  dpkg --add-architecture i386 && apt update -y
  log_pkg "wine wine32 wine64 winetricks"
  apt install -y wine wine32 wine64 winetricks 2>/dev/null && log_ok "Wine installed" || log_warn "Wine unavailable for $ARCH"
else log_skip "Wine"; fi

if echo "$SELECTED" | grep -q "steam"; then
  log_step "Installing Steam + Proton (x86_64 only)"
  if [[ "$ARCH" != "amd64" ]]; then
    log_warn "Steam x86_64 only — skipping on $ARCH"
  else
    dpkg --add-architecture i386 && apt update -y
    apt install -y libgl1-mesa-dri:i386 libgl1:i386 libc6:i386 libstdc++6:i386 libsdl2-2.0-0 zenity 2>/dev/null
    wget -q --show-progress -O /tmp/steam.deb "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
    dpkg -i /tmp/steam.deb 2>/dev/null || apt --fix-broken install -y
    rm -f /tmp/steam.deb
    log_ok "Steam installed"
  fi
else log_skip "Steam"; fi

if echo "$SELECTED" | grep -q "qemu"; then
  log_step "Installing QEMU Manager"
  if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    log_pkg "qemu-manager aarch64"
    wget -q --show-progress -O /tmp/qemu-manager.deb \
      "https://github.com/driftcore-gif/qemu-manager/releases/download/v1.0.0/qemu-manager_aarch64.deb"
    if [[ $? -eq 0 ]]; then
      dpkg -i /tmp/qemu-manager.deb 2>/dev/null || apt --fix-broken install -y
      rm -f /tmp/qemu-manager.deb
      log_ok "QEMU Manager installed — run: qemu-manager"
    else
      log_warn "Download failed"
    fi
  else
    log_warn "QEMU Manager aarch64 only — skipping on $ARCH"
  fi
else log_skip "QEMU Manager"; fi

log_step "Writing ~/.bashrc"
cat >> ~/.bashrc << 'EOF'

export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1
export WINEDEBUG=-all
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
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"

echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Ubuntu setup complete!"
echo "  DE : $DE  |  Arch : $ARCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  👉 exit  →  tx11start"
