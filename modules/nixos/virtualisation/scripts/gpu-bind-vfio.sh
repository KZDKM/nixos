# 2. Drop VT consoles and framebuffer (release host display from the GPU)
for vt in /sys/class/vtconsole/vtcon*/bind; do
  [ -w "$vt" ] && echo 0 > "$vt" 2>/dev/null || true
done
for d in /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 \
         /sys/bus/platform/drivers/simple-framebuffer/simple-framebuffer.0; do
  [ -e "$d" ] || continue
  basename "$d" > "$(dirname "$d")/unbind" 2>/dev/null || true
done

# 3. D0 lock BEFORE unbind (Navi reset-domain hygiene)
[ -e "/sys/bus/pci/devices/$VGA/d3cold_allowed" ] && \
  echo 0 > "/sys/bus/pci/devices/$VGA/d3cold_allowed"
echo "on" > "/sys/bus/pci/devices/$VGA/power/control"

# Pin override first so autoprobe can't re-grab for amdgpu
echo vfio-pci > "/sys/bus/pci/devices/$VGA/driver_override"
echo vfio-pci > "/sys/bus/pci/devices/$HDA/driver_override"

# Unbind from host drivers
echo "$VGA" > "/sys/bus/pci/devices/$VGA/driver/unbind" 2>/dev/null || true
echo "$HDA" > "/sys/bus/pci/devices/$HDA/driver/unbind" 2>/dev/null || true

# 5. BAR2 resize to 8 MB (device must be driverless now)
if [ -e "/sys/bus/pci/devices/$VGA/resource2_resize" ]; then
  echo 3 > "/sys/bus/pci/devices/$VGA/resource2_resize" 2>/dev/null \
    || echo "WARN: BAR2 resize failed" >&2
fi

# Bind to vfio-pci
modprobe vfio-pci
echo "$VGA" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
echo "$HDA" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true

# Block until BOTH functions confirmed on vfio-pci, else fail the hook
for dev in "$VGA" "$HDA"; do
  ok=0
  for _i in $(seq 1 40); do
    drv=$(basename "$(readlink -f /sys/bus/pci/devices/$dev/driver 2>/dev/null)" 2>/dev/null)
    if [ "$drv" = "vfio-pci" ]; then ok=1; break; fi
    sleep 0.25
  done
  if [ "$ok" != "1" ]; then
    echo "ERROR: $dev failed to bind vfio-pci" >&2
    exit 1
  fi
done
