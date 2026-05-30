#!/bin/bash
# Arch Linux setup — Run inside proot

pacman -S --noconfirm dialog 2>/dev/null
TMP=$(mktemp); TMP2=$(mktemp)

dialog --title "Proot-termux-desktop v0.40" --msgbox "\nArch Linux Proot Setup" 7 40

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

DE=$(cat "$TMP"); [[ -z "$DE" ]] && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

dialog --title "Optional Apps" \
  --checklist "\nSelect apps:" 12 50 3 \
  "media" "VLC + MPV" ON \
  "photo" "GIMP + Darktable" ON \
  "games" "3D Linux games" ON \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")
ARCH=$(uname -m)

dialog --title "Installing" --infobox "\nUpdating Arch ($ARCH)..." 6 40
pacman -Syu --noconfirm > /dev/null 2>&1

dialog --title "Installing" --infobox "\nInstalling base + $DE..." 6 40
pacman -S --noconfirm dbus git wget nano mesa vulkan-loader > /dev/null 2>&1
case "$DE" in
  "xfce")     pacman -S --noconfirm xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      pacman -S --noconfirm plasma konsole dolphin ;;
  "gnome")    pacman -S --noconfirm gnome gnome-terminal ;;
  "mate")     pacman -S --noconfirm mate mate-terminal ;;
  "lxqt")     pacman -S --noconfirm lxqt lxterminal ;;
  "openbox")  pacman -S --noconfirm openbox tint2 lxterminal ;;
  "i3wm")     pacman -S --noconfirm i3 dmenu ;;
  "cinnamon") pacman -S --noconfirm cinnamon gnome-terminal ;;
esac > /dev/null 2>&1

echo "$SELECTED" | grep -q "media" && pacman -S --noconfirm vlc mpv > /dev/null 2>&1
echo "$SELECTED" | grep -q "photo" && pacman -S --noconfirm gimp darktable > /dev/null 2>&1
echo "$SELECTED" | grep -q "games" && { pacman -S --noconfirm supertuxkart neverball freedoom > /dev/null 2>&1; [[ "$ARCH" == "x86_64" ]] && pacman -S --noconfirm xonotic openarena > /dev/null 2>&1; }

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0; export PULSE_SERVER=tcp:127.0.0.1; export mesa_glthread=true
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && eval $(dbus-launch --sh-syntax)
EOF

eval $(dbus-launch --sh-syntax) 2>/dev/null
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"
dialog --title "✅ Done!" --msgbox "\nArch ready!\n  DE: $DE | Arch: $ARCH\n\nRun: tx11start" 10 40
clear
