#!@bash@/bin/sh

APP_DATA_DIR="$HOME/.local/share/CASetupUtility"
RO_ASSETS_DIR="@out@/share/CASetupUtility"


# On first run, set up the writable directory
if [ ! -d "$APP_DATA_DIR/data" ]; then
  echo "First run: Initializing data in $APP_DATA_DIR..."
  mkdir -p "$APP_DATA_DIR/data"

  # Copy the files you identified as mutable
  cp "$RO_ASSETS_DIR/local_firmwares.txt" "$APP_DATA_DIR/data/"
  cp -r "$RO_ASSETS_DIR/cas" "$APP_DATA_DIR/data/"
  cp -r "$RO_ASSETS_DIR/firmware" "$APP_DATA_DIR/data/firmware"
  cp -r "$RO_ASSETS_DIR/help" "$APP_DATA_DIR/data/help"
  cp "$RO_ASSETS_DIR/device.txt" "$APP_DATA_DIR/data/device.txt"
  touch "$APP_DATA_DIR/data/temp.hex"

  # Symlink the files you identified as read-only
  ln -s "$RO_ASSETS_DIR/fonts" "$APP_DATA_DIR/data/fonts"
  ln -s "$RO_ASSETS_DIR/supl.exe" "$APP_DATA_DIR/data/supl.exe"

  chmod -R u+rwX "$APP_DATA_DIR"
fi

# cd into the directory that CONTAINS the 'data' directory
cd "$APP_DATA_DIR"

# Execute the patched binary
exec "@out@/libexec/CASetupUtility" -stylesheet "@out@/share/CASetupUtility/light-theme.qss" "$@"
