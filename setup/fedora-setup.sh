#!/bin/bash
# Fedora setup — Run inside proot

dnf install -y dialog 2>/dev/null
TMP=$(mktemp); TMP2=$(mktemp)

dialog --title "Proot-termux-desktop v0.40" --msgbox "\nFedora Proot Setup" 7 40

dialog --title "Select Desktop" \
  --menu "\nChoose desktop:" 18 58 8 \
  "xfce" "🟢 XFCE — Lightweight" \
  "kde" "🔴 KDE — Heavy" "gnome" "🔴 GNOME — Heavy" \
  "mate" "🟡 MATE" "lxqt" "🟢 LXQt" "openbox" "🟢 Openbox" \
  "i3wm" "🟢 i3wm" "cinnamon" "🟡 Cinnamon" 2>"$TMP"

DE=$(cat "$TMP"); [[ -z "$DE" ]] && rm -f "$TMP" "$TMP2" && exit 0
echo "$DE" > ~/.proot-de

dialog --title "Optional Apps" \
  --checklist "\nSelect apps:" 12 50 3 \
  "media" "VLC + MPV" ON "photo" "GIMP + Darktable" ON "games" "3D games" ON 2>"$TMP2"

SELECTED=$(cat "$TMP2"); ARCH=$(uname -m)

dialog --title "Installing" --infobox "\nUpdating Fedora..." 5 35
dnf upgrade -y > /dev/null 2>&1
dnf install -y dbus git wget nano mesa-dri-drivers vulkan-loader > /dev/null 2>&1
case "$DE" in
  "xfce")     dnf install -y xfce4-session xfdesktop xfwm4 xfce4-panel xfce4-terminal ;;
  "kde")      dnf install -y @kde-desktop-environment ;;
  "gnome")    dnf install -y @gnome-desktop ;;
  "mate")     dnf install -y @mate-desktop ;;
  "lxqt")     dnf install -y @lxqt-desktop ;;
  "openbox")  dnf install -y openbox tint2 lxterminal ;;
  "i3wm")     dnf install -y i3 dmenu ;;
  "cinnamon") dnf install -y @cinnamon-desktop ;;
esac > /dev/null 2>&1

echo "$SELECTED" | grep -q "media" && dnf install -y vlc mpv > /dev/null 2>&1
echo "$SELECTED" | grep -q "photo" && dnf install -y gimp darktable > /dev/null 2>&1
echo "$SELECTED" | grep -q "games" && { dnf install -y supertuxkart freedoom > /dev/null 2>&1; [[ "$ARCH" == "x86_64" ]] && dnf install -y xonotic openarena > /dev/null 2>&1; }

cat >> ~/.bashrc << 'EOF'
export DISPLAY=:0; export PULSE_SERVER=tcp:127.0.0.1; export mesa_glthread=true
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && eval $(dbus-launch --sh-syntax)
EOF

eval $(dbus-launch --sh-syntax) 2>/dev/null
[[ "$DE" == "xfce" ]] && xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
rm -f "$TMP" "$TMP2"
dialog --title "✅ Done!" --msgbox "\nFedora ready!\n  DE: $DE\n\nRun: tx11start" 10 40
clear
