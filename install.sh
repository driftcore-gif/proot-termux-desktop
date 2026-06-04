#!/data/data/com.termux/files/usr/bin/bash
# install.sh — Full Termux setup with dialog TUI

pkg install -y dialog 2>/dev/null

TERMUX_BIN="/data/data/com.termux/files/usr/bin"
TX11_BIN="$TERMUX_BIN/tx11start"
TMP=$(mktemp)

# ─────────────────────────────────────────────
# Welcome
# ─────────────────────────────────────────────
dialog --title "Proot-termux-desktop v0.40" \
  --msgbox "\nWelcome to Proot-termux-desktop!\n\nThis installer will:\n\n  1. Enable x11-repo + root-repo\n  2. Update package lists\n  3. Install all Termux packages\n  4. Install selected proot distro\n  5. Generate tx11start\n  6. Auto-launch proot setup\n\nPress OK to begin." 18 52

# ─────────────────────────────────────────────
# Select distro
# ─────────────────────────────────────────────
dialog --title "Select Distro" \
  --menu "\nChoose Linux distribution:" 16 58 5 \
  "debian"    "✅ Debian      — Most stable, recommended" \
  "ubuntu"    "✅ Ubuntu      — Good compatibility" \
  "archlinux" "⚡ Arch Linux  — Cutting edge" \
  "fedora"    "⚠️  Fedora      — Heavier" \
  "void"      "🚫 Void        — Not tested" \
  2>"$TMP"

DISTRO=$(cat "$TMP")
[[ -z "$DISTRO" ]] && clear && exit 0

# ─────────────────────────────────────────────
# Select connection
# ─────────────────────────────────────────────
dialog --title "Connection Type" \
  --menu "\nChoose display connection type:" 12 56 2 \
  "tx11" "Termux:X11 — Fast, low latency (recommended)" \
  "vnc"  "VNC        — Remote capable, flexible" \
  2>"$TMP"

CONNECTION=$(cat "$TMP")
[[ -z "$CONNECTION" ]] && clear && exit 0

# ─────────────────────────────────────────────
# Confirm
# ─────────────────────────────────────────────
dialog --title "Confirm Setup" \
  --yesno "\nConfiguration:\n\n  Distro     : $DISTRO\n  Connection : $CONNECTION\n\nProceed?" 12 48

[[ $? -ne 0 ]] && clear && exit 0
clear

# ─────────────────────────────────────────────
# Step 1 — Enable repos FIRST then update
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 1/5 — Enabling repos"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Installing x11-repo..."
pkg install -y x11-repo
echo "📦 Installing root-repo..."
pkg install -y root-repo
echo "📦 Updating package lists..."
pkg update -y
echo "✅ Repos enabled and updated"
echo ""

# ─────────────────────────────────────────────
# Step 2 — Install all packages
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 2/5 — Installing Termux packages"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📦 Installing proot-distro..."
pkg install -y proot-distro

echo "📦 Installing termux-x11-nightly..."
pkg install -y termux-x11-nightly

echo "📦 Installing virglrenderer-android..."
pkg install -y virglrenderer-android

echo "📦 Installing pulseaudio..."
pkg install -y pulseaudio

echo "📦 Installing wget curl git..."
pkg install -y wget curl git

if [[ "$CONNECTION" == "vnc" ]]; then
  echo "📦 Installing tigervnc..."
  pkg install -y tigervnc
fi

echo "✅ All Termux packages installed"
echo ""

# ─────────────────────────────────────────────
# Step 3 — Install proot distro
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 3/5 — Installing $DISTRO proot"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
proot-distro install "$DISTRO" || echo "⚠️ Already installed or failed"
echo "✅ $DISTRO ready"
echo ""

# ─────────────────────────────────────────────
# Step 4 — Generate tx11start
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 4/5 — Generating tx11start"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$TX11_BIN" << SCRIPT
#!/data/data/com.termux/files/usr/bin/bash
CONNECTION="${CONNECTION}"
DISTRO="${DISTRO}"
VNC_PORT="5901"
VNC_DISPLAY=":1"

detect_gpu() {
  local egl hw renderer
  egl=\$(getprop ro.hardware.egl 2>/dev/null | tr '[:upper:]' '[:lower:]')
  hw=\$(cat /proc/cpuinfo 2>/dev/null | grep -i "hardware" | tr '[:upper:]' '[:lower:]')
  renderer=\$(getprop ro.hardware 2>/dev/null | tr '[:upper:]' '[:lower:]')
  if echo "\$egl \$hw \$renderer" | grep -qi "nvidia\|tegra"; then echo "nvidia"
  elif echo "\$egl \$hw \$renderer" | grep -qi "intel\|i915\|iris"; then echo "intel"
  elif echo "\$egl \$hw \$renderer" | grep -qi "rockchip\|rk3"; then echo "rockchip"
  elif echo "\$egl \$hw \$renderer" | grep -qi "adreno\|qcom\|qualcomm\|snapdragon"; then echo "adreno"
  elif echo "\$egl \$hw \$renderer" | grep -qi "mali\|exynos\|mediatek\|dimensity\|helio"; then echo "mali"
  elif echo "\$hw" | grep -qi "x86\|x86_64"; then echo "intel"
  else echo "others"
  fi
}

GPU=\$(detect_gpu)
echo "🚀 Booting (GPU: \$GPU | Distro: \$DISTRO)..."

pkill -f virgl_test_server 2>/dev/null
pkill -f termux-x11 2>/dev/null
pkill -f Xvnc 2>/dev/null
sleep 1

case "\$GPU" in
  "nvidia")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.6COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.6COMPAT; export mesa_glthread=true"
    ;;
  "intel")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.6COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.6COMPAT; export mesa_glthread=true"
    ;;
  "rockchip")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=3.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.1 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=3.3COMPAT; export mesa_glthread=true"
    ;;
  "adreno")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    MESA_EXTENSION_OVERRIDE="+GL_EXT_shader_texture_lod" GALLIUM_DRIVER=virpipe \
    virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.3COMPAT; export mesa_glthread=true"
    ;;
  "mali")
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 \
    GALLIUM_DRIVER=virpipe virgl_test_server_android --angle-gl &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.3COMPAT; export mesa_glthread=true"
    ;;
  *)
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.0 GALLIUM_DRIVER=virpipe virgl_test_server_android &
    GPU_ENV="export GALLIUM_DRIVER=virpipe; export MESA_NO_ERROR=1; export MESA_GL_VERSION_OVERRIDE=4.0; export mesa_glthread=true"
    ;;
esac
sleep 1

echo "🎙️ Audio..."
pulseaudio --kill 2>/dev/null; sleep 1
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --load="module-sles-source" --exit-idle-time=-1 2>/dev/null || \
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --load="module-aaudio-source" --exit-idle-time=-1 2>/dev/null || \
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1 2>/dev/null
sleep 1

if [[ "\$CONNECTION" == "tx11" ]]; then
  am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null
  sleep 2
  termux-x11 :0 -ac &
  sleep 2
  DISPLAY_VAR=":0"
else
  vncserver \$VNC_DISPLAY -geometry 1280x720 -depth 24 2>/dev/null
  sleep 2
  DISPLAY_VAR="\$VNC_DISPLAY"
  echo "📱 Connect VNC to: localhost:\$VNC_PORT"
fi

DE="xfce"
[[ -f ~/.proot-de ]] && DE=\$(cat ~/.proot-de)

case "\$DE" in
  "xfce")     DE_CMD="startxfce4" ;;
  "kde")      DE_CMD="startplasma-x11" ;;
  "gnome")    DE_CMD="gnome-session" ;;
  "mate")     DE_CMD="mate-session" ;;
  "lxqt")     DE_CMD="startlxqt" ;;
  "openbox")  DE_CMD="openbox-session" ;;
  "i3wm")     DE_CMD="i3" ;;
  "cinnamon") DE_CMD="cinnamon-session" ;;
  *)          DE_CMD="startxfce4" ;;
esac

proot-distro login "\$DISTRO" --shared-tmp -- bash -c "
  export DISPLAY=\${DISPLAY_VAR}
  export PULSE_SERVER=tcp:127.0.0.1
  export WINEDEBUG=-all
  export WINEPREFIX=~/.wine
  \${GPU_ENV}
  mkdir -p /run/dbus
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1
  [ -z \"\\\$DBUS_SESSION_BUS_ADDRESS\" ] && eval \\\$(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
  xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
  echo \"🎮 Ready (GPU: \${GPU})\"
  \${DE_CMD}
"
SCRIPT

chmod +x "$TX11_BIN"
echo "✅ tx11start installed to $TX11_BIN"
echo ""

# ─────────────────────────────────────────────
# Step 5 — Auto-login proot
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 5/5 — Launching $DISTRO proot"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐧 Auto-logging into $DISTRO..."
echo "📦 Will run: ~/desktop/setup/${DISTRO}-setup.sh"
echo ""
sleep 2

rm -f "$TMP"

proot-distro login "$DISTRO" --shared-tmp -- bash -c "
  if [ -f ~/desktop/setup/${DISTRO}-setup.sh ]; then
    bash ~/desktop/setup/${DISTRO}-setup.sh
  else
    echo '⚠️  Setup file not found!'
    echo '👉 Clone repo first:'
    echo '   git clone https://github.com/driftcore-gif/Debian-termux-desktop.git ~/desktop'
    echo '   bash ~/desktop/install.sh'
    bash
  fi
"

echo ""
echo "✅ All done! Run: tx11start"
