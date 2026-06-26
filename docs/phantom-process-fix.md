# Phantom Process Fix (Android 12+)
pkg install android-tools -y
# Enable Wireless Debugging in Developer Options
adb pair IP:PORT
adb connect IP:PORT
adb shell "device_config set_sync_disabled_for_tests persistent"
adb shell "device_config put activity_manager max_phantom_processes 2147483647"
