set -e
GUEST_NAME="$1"
HOOK_NAME="$2"
STATE_NAME="$3"

HOOK_DIR="/etc/libvirt/hooks/qemu.d"
HOOK_PATH="$HOOK_DIR/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

if [ -d "$HOOK_PATH" ]; then
  for script in "$HOOK_PATH"/*; do
    if [ -x "$script" ]; then
      "$script" "$@"
    fi
  done
fi
exit 0
