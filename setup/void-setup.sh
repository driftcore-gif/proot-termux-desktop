#!/bin/bash
# Void Linux setup — Run inside proot

xbps-install -y dialog 2>/dev/null
TMP=$(mktemp); TMP2=$(mktemp)

dialog --title "Proot-termux-desktop v0.40" --msgbox "\nVoid Linux Proot Setup\n\n⚠️ Void is not officially tested." 9 45

dialog --title "Select Desktop" \
  --menu "\nChoose desktop:" 18 58 8 \
  "xfce" "🟢 XFCE — Lightweight" "kde" "🔴 KDE — Heavy" "gnome" "🔴 GNOME — Heavy" \
  "mate" "🟡 MATE" "lxqt" "🟢 LXQt" "openbox" "🟢 Openbox" \
  "i3wm" "🟢 i3wm" "cinnamon" "🟡 Cinnamon" 2>"$TMP"

DE=$(cat "$TMP"); [[ -z "$DE" ]] && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

dialog --title "Optional Apps" \
  --checklist "\nSelect apps:" 12 50 3 \
  "media" "VLC + MPV" ON "photo" "GIMP + Darktable" ON "games" "3D games" ON 2>"$TMP2"

SELECTED=$(cat "$TMP2"); ARCH=$(uname -m)

dialog --title "Installing" --infobox "\nUpdating Void..." 5 35
xbps-install -Su xbps > /dev/null 2>&1 && xbps-install -u > /dev/null 2>&1
xbps-install -y dbus git wget nano mesa vulkan-loader > /dev/null 2>&1
case "$DE" in
  "xfce")     xbps-install -y xfce4 xfce4-terminal xfce4-whiskermenu-plugin thunar ;;
  "kde")      xbps-install -y kde5 konsole dolphin ;;
  "gnome")    xbps-install -y gnome gnome-terminal ;;
  "mate")     xbps-install -y mate mate-terminal ;;
  "lxqt")     xbps-install -y lxqt lxterminal ;;
  "openbox")  xbps-install -y openbox tint2 lxterminal ;;
  "i3wm")     xbps-install -y i3 dmenu ;;
  "cinnamon") xbps-install -y cinnamon gnome-terminal ;;
esac > /dev/null 2>&1

echo "$SELECTED" | grep -q "media" && xbps-install -y vlc mpv > /dev/null 2>&1
echo "$SELECTED" | grep -q "photo" && xbps-install -y gimp darktable > /dev/null 2>&1
echo "$SELECTED" | grep -q "games" && { xbps-install -y supertuxkart freedoom > /dev/null 2>&1; [[ "$ARCH" == "x86_64" ]] && xbps-install -y xonotic > /dev/null 2>&1; }

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0; export PULSE_SERVER=tcp:127.0.0.1; export mesa_glthread=true
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && eval $(dbus-launch --sh-syntax)
EOF

eval $(dbus-launch --sh-syntax) 2>/dev/null
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"
dialog --title "✅ Done!" --msgbox "\nVoid ready!\n  DE: $DE\n\nRun: tx11start" 10 40
clear
