VGA=$(lspci -D -d 1002:7550 | awk '{print $1}')
HDA=$(lspci -D -d 1002:ab40 | awk '{print $1}')
UPSTREAM=$(basename "$(readlink -f /sys/bus/pci/devices/$VGA/../)")

gpu_bound() {
  [ "$(basename "$(readlink -f /sys/bus/pci/devices/$VGA/driver 2>/dev/null)" 2>/dev/null)" = "amdgpu" ]
}

wait_driverless() {
  for _i in 1 2 3 4 5; do
    [ -e "/sys/bus/pci/devices/$1/driver" ] || return 0
    sleep 1
  done
  return 1
}

for attempt in 1 2 3; do
  echo "$VGA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
  echo "$HDA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true

  echo "" > /sys/bus/pci/devices/$VGA/driver_override 2>/dev/null || true
  echo "" > /sys/bus/pci/devices/$HDA/driver_override 2>/dev/null || true

  if [ "$attempt" -gt 1 ] && [ -n "$UPSTREAM" ]; then
    cur=$(setpci -s "$UPSTREAM" BRIDGE_CONTROL.w)
    setpci -s "$UPSTREAM" BRIDGE_CONTROL.w=$(printf '%04x' $((0x$cur | 0x40)))
    sleep 1
    setpci -s "$UPSTREAM" BRIDGE_CONTROL.w="$cur"
    sleep 1
  fi

  setpci -s "${VGA#0000:}" CAP_PM+4.w=0x0000 2>/dev/null || true
  sleep 1

  modprobe amdgpu 2>/dev/null || true
  wait_driverless "$VGA" || true
  timeout 15 \
    sh -c 'echo "'"$VGA"'" > /sys/bus/pci/drivers/amdgpu/bind' \
    2>/dev/null || true
  sleep 3

  if gpu_bound; then
    break
  fi
done

# Rebind audio: force off vfio-pci and confirm driverless first
echo "$HDA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
echo "" > /sys/bus/pci/devices/$HDA/driver_override 2>/dev/null || true
wait_driverless "$HDA" || \
  echo "WARN: $HDA still has a driver before snd_hda_intel bind" >&2

modprobe snd_hda_intel 2>/dev/null || true
timeout 10 \
  sh -c 'echo "'"$HDA"'" > /sys/bus/pci/drivers/snd_hda_intel/bind' \
  2>/dev/null || echo "WARN: snd_hda_intel bind for $HDA timed out or failed" >&2

# Restore VT consoles
for vt in /sys/class/vtconsole/vtcon*; do
  [ -e "$vt/bind" ] && echo 1 > "$vt/bind" 2>/dev/null || true
done
