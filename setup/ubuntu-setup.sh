#!/bin/bash
# Ubuntu setup — Run inside proot

apt install -y dialog 2>/dev/null
TMP=$(mktemp); TMP2=$(mktemp)

dialog --title "Proot-termux-desktop v0.40" --msgbox "\nUbuntu Proot Setup" 7 40

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
  --checklist "\nSelect apps:" 14 55 4 \
  "media" "VLC + MPV" ON \
  "photo" "GIMP + Darktable" ON \
  "games" "3D Linux games" ON \
  "wine"  "Wine (experimental)" OFF \
  2>"$TMP2"

SELECTED=$(cat "$TMP2")
ARCH=$(dpkg --print-architecture)

dialog --title "Installing" --infobox "\nUpdating Ubuntu ($ARCH)..." 6 40
apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1

dialog --title "Installing" --infobox "\nInstalling base + $DE..." 6 40
apt install -y dbus dbus-x11 wget curl nano mesa-utils libgl1-mesa-dri > /dev/null 2>&1
case "$DE" in
  "xfce")     apt install -y xfce4 xfce4-goodies xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      apt install -y kde-plasma-desktop konsole dolphin ;;
  "gnome")    apt install -y gnome-shell gnome-terminal nautilus ;;
  "mate")     apt install -y mate-desktop-environment mate-terminal caja ;;
  "lxqt")     apt install -y lxqt lxterminal pcmanfm-qt ;;
  "openbox")  apt install -y openbox tint2 lxterminal pcmanfm ;;
  "i3wm")     apt install -y i3 i3status dmenu lxterminal ;;
  "cinnamon") apt install -y cinnamon cinnamon-core gnome-terminal nemo ;;
esac > /dev/null 2>&1

echo "$SELECTED" | grep -q "media" && { dialog --title "Installing" --infobox "\nVLC + MPV..." 5 35; apt install -y vlc mpv > /dev/null 2>&1; }
echo "$SELECTED" | grep -q "photo" && { dialog --title "Installing" --infobox "\nGIMP + Darktable..." 5 35; apt install -y gimp darktable > /dev/null 2>&1; }
echo "$SELECTED" | grep -q "games" && { dialog --title "Installing" --infobox "\nGames ($ARCH)..." 5 35; apt install -y supertuxkart neverball freedoom > /dev/null 2>&1; [[ "$ARCH" == "amd64" ]] && apt install -y xonotic openarena > /dev/null 2>&1; }
echo "$SELECTED" | grep -q "wine"  && { dpkg --add-architecture i386 && apt update > /dev/null 2>&1; apt install -y wine wine32 wine64 > /dev/null 2>&1; }

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0; export PULSE_SERVER=tcp:127.0.0.1; export mesa_glthread=true
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && eval $(dbus-launch --sh-syntax)
EOF

eval $(dbus-launch --sh-syntax) 2>/dev/null
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"
dialog --title "✅ Done!" --msgbox "\nUbuntu ready!\n  DE: $DE | Arch: $ARCH\n\nRun: tx11start" 10 40
clear
