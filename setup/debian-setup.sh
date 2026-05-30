#!/bin/bash
# Debian setup — Run inside proot
# proot-distro login debian --shared-tmp
# bash ~/desktop/setup/debian-setup.sh

apt install -y dialog 2>/dev/null
TMP=$(mktemp)
TMP2=$(mktemp)

dialog --title "Proot-termux-desktop v0.40" \
  --msgbox "\nDebian Proot Setup\n\nThis will install your desktop\nenvironment and selected apps." 10 45

# ─────────────────────────────────────────────
# Select DE
# ─────────────────────────────────────────────
dialog --title "Select Desktop Environment" \
  --menu "\nChoose your desktop environment:" 18 58 8 \
  "xfce"     "🟢 XFCE      — Lightweight (recommended)" \
  "kde"      "🔴 KDE       — Feature rich (6GB+ RAM)" \
  "gnome"    "🔴 GNOME     — Modern UI (6GB+ RAM)" \
  "mate"     "🟡 MATE      — Classic desktop" \
  "lxqt"     "🟢 LXQt      — Lightweight Qt" \
  "openbox"  "🟢 Openbox   — Minimal WM" \
  "i3wm"     "🟢 i3wm      — Tiling WM" \
  "cinnamon" "🟡 Cinnamon  — Windows-like" \
  2>"$TMP"

DE=$(cat "$TMP")
[[ -z "$DE" ]] && dialog --msgbox "Cancelled." 5 20 && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

# ─────────────────────────────────────────────
# Select optional apps
# ─────────────────────────────────────────────
dialog --title "Optional Apps" \
  --checklist "\nSelect apps to install:\n(Space to select, Enter to confirm)" 16 58 5 \
  "media"  "VLC + MPV media players"          ON \
  "photo"  "GIMP + Darktable photo editors"   ON \
  "games"  "3D Linux games (arch-aware)"       ON \
  "wine"   "Wine + Winetricks (experimental)"  OFF \
  "steam"  "Steam + Proton (x86_64 only)"      OFF \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")

# ─────────────────────────────────────────────
# Confirm
# ─────────────────────────────────────────────
dialog --title "Confirm" \
  --yesno "\nConfiguration:\n\n  DE    : $DE\n  Apps  : $SELECTED\n\nProceed with installation?" 12 50

[[ $? -ne 0 ]] && dialog --msgbox "Aborted." 5 20 && rm -f "$TMP" "$TMP2" && exit 0

ARCH=$(dpkg --print-architecture)

# ─────────────────────────────────────────────
# Install
# ─────────────────────────────────────────────
dialog --title "Installing" --infobox "\nUpdating system...\nArch: $ARCH" 7 40
apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1

dialog --title "Installing" --infobox "\nInstalling base tools..." 6 40
apt install -y dbus dbus-x11 wget curl git nano mesa-utils libgl1-mesa-dri libvulkan1 \
  gtk2-engines-murrine gtk2-engines-pixbuf greybird-gtk-theme > /dev/null 2>&1

dialog --title "Installing" --infobox "\nInstalling $DE desktop..." 6 40
case "$DE" in
  "xfce")     apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      apt install -y kde-plasma-desktop konsole dolphin ;;
  "gnome")    apt install -y gnome-shell gnome-terminal nautilus gnome-tweaks ;;
  "mate")     apt install -y mate-desktop-environment mate-terminal caja ;;
  "lxqt")     apt install -y lxqt lxterminal pcmanfm-qt ;;
  "openbox")  apt install -y openbox obconf tint2 lxterminal pcmanfm ;;
  "i3wm")     apt install -y i3 i3status dmenu lxterminal ;;
  "cinnamon") apt install -y cinnamon cinnamon-core gnome-terminal nemo ;;
esac > /dev/null 2>&1

echo "$SELECTED" | grep -q "media" && {
  dialog --title "Installing" --infobox "\nInstalling VLC + MPV..." 6 40
  apt install -y vlc mpv > /dev/null 2>&1
}

echo "$SELECTED" | grep -q "photo" && {
  dialog --title "Installing" --infobox "\nInstalling GIMP + Darktable..." 6 40
  apt install -y gimp darktable > /dev/null 2>&1
}

echo "$SELECTED" | grep -q "games" && {
  dialog --title "Installing" --infobox "\nInstalling 3D games ($ARCH)..." 6 40
  apt install -y supertuxkart neverball extremetuxracer freedoom pingus > /dev/null 2>&1
  [[ "$ARCH" == "amd64" ]] && apt install -y openarena xonotic > /dev/null 2>&1
}

echo "$SELECTED" | grep -q "wine" && {
  dialog --title "Installing" --infobox "\nInstalling Wine..." 6 40
  dpkg --add-architecture i386 && apt update > /dev/null 2>&1
  apt install -y wine wine64 wine32 winetricks > /dev/null 2>&1
}

echo "$SELECTED" | grep -q "steam" && {
  if [[ "$ARCH" != "amd64" ]]; then
    dialog --msgbox "⚠️ Steam is x86_64 only. Skipping on $ARCH." 7 45
  else
    dialog --title "Installing" --infobox "\nInstalling Steam + Proton..." 6 40
    dpkg --add-architecture i386 && apt update > /dev/null 2>&1
    apt install -y libgl1-mesa-dri:i386 libgl1:i386 libc6:i386 libstdc++6:i386 \
      libsdl2-2.0-0 zenity > /dev/null 2>&1
    wget -O /tmp/steam.deb "https://cdn.akamai.steamstatic.com/client/installer/steam.deb" 2>/dev/null
    dpkg -i /tmp/steam.deb 2>/dev/null || apt --fix-broken install -y > /dev/null 2>&1
    rm -f /tmp/steam.deb
  fi
}

# ─────────────────────────────────────────────
# Bashrc
# ─────────────────────────────────────────────
cat >> ~/.bashrc << 'EOF'

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
EOF

source ~/.bashrc 2>/dev/null
eval $(dbus-launch --sh-syntax) 2>/dev/null

[[ "$DE" == "xfce" ]] && {
  xfconf-query -c xsettings -p /Net/ThemeName -s "Greybird" 2>/dev/null
  xfconf-query -c xfwm4 -p /general/theme -s "Greybird" 2>/dev/null
  xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -n -t string -s "xfce4-popup-whiskermenu" 2>/dev/null
}

rm -f "$TMP" "$TMP2"

dialog --title "✅ Done!" \
  --msgbox "\nDebian setup complete!\n\n  DE     : $DE\n  Arch   : $ARCH\n\nExit proot and run:\n  tx11start" 13 45
clear
