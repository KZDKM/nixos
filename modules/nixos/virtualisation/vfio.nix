{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  vmName = "Windows-dgpu";

  vendorId = "1002";
  vgaDeviceId = "7550";
  audioDeviceId = "ab40";
  vgaPciId = "0000:03:00.0";
  audioPciId = "0000:03:00.1";

  # The dispatcher: libvirt calls /etc/libvirt/hooks/qemu, this fans out
  # to /etc/libvirt/hooks/qemu.d/<guest>/<hook>/<state>/*
  qemuDispatcher = pkgs.writeShellScript "libvirt-qemu-dispatcher" ''
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
  '';
  startScript = pkgs.writeShellScript "gpu-bind-vfio" ''
      VGA='${vgaPciId}'
      HDA='${audioPciId}'

      # 2. Drop VT consoles and framebuffer (release host display from the GPU)
      for vt in /sys/class/vtconsole/vtcon*/bind; do
        [ -w "''$vt" ] && echo 0 > "''$vt" 2>/dev/null || true
      done
      for d in /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 \
               /sys/bus/platform/drivers/simple-framebuffer/simple-framebuffer.0; do
        [ -e "''$d" ] || continue
        ${pkgs.coreutils}/bin/basename "''$d" > "''$(${pkgs.coreutils}/bin/dirname "''$d")/unbind" 2>/dev/null || true
      done

      # 3. D0 lock BEFORE unbind (Navi reset-domain hygiene)
      [ -e "/sys/bus/pci/devices/''$VGA/d3cold_allowed" ] && \
        echo 0 > "/sys/bus/pci/devices/''$VGA/d3cold_allowed"
      echo "on" > "/sys/bus/pci/devices/''$VGA/power/control"

      # Pin override first so autoprobe can't re-grab for amdgpu
      echo vfio-pci > "/sys/bus/pci/devices/''$VGA/driver_override"
      echo vfio-pci > "/sys/bus/pci/devices/''$HDA/driver_override"

      # Unbind from host drivers
      echo "''$VGA" > "/sys/bus/pci/devices/''$VGA/driver/unbind" 2>/dev/null || true
      echo "''$HDA" > "/sys/bus/pci/devices/''$HDA/driver/unbind" 2>/dev/null || true

      # 5. BAR2 resize to 8 MB (device must be driverless now)
      if [ -e "/sys/bus/pci/devices/''$VGA/resource2_resize" ]; then
        echo 3 > "/sys/bus/pci/devices/''$VGA/resource2_resize" 2>/dev/null \
          || echo "WARN: BAR2 resize failed" >&2
      fi

      # Bind to vfio-pci
      ${pkgs.kmod}/bin/modprobe vfio-pci
      echo "''$VGA" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
      echo "''$HDA" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true

      # Block until BOTH functions confirmed on vfio-pci, else fail the hook
      for dev in "''$VGA" "''$HDA"; do
        ok=0
        for i in ''$(${pkgs.coreutils}/bin/seq 1 40); do
          drv=''$(${pkgs.coreutils}/bin/basename "''$(readlink -f /sys/bus/pci/devices/''$dev/driver 2>/dev/null)" 2>/dev/null)
          if [ "''$drv" = "vfio-pci" ]; then ok=1; break; fi
          sleep 0.25
        done
        if [ "''$ok" != "1" ]; then
          echo "ERROR: ''$dev failed to bind vfio-pci" >&2
          exit 1
        fi
      done
    '';
    releaseScript = pkgs.writeShellScript "gpu-bind-host" ''
        VGA=''$(${pkgs.pciutils}/bin/lspci -D -d 1002:7550 | ${pkgs.gawk}/bin/awk '{print ''$1}')
        HDA=''$(${pkgs.pciutils}/bin/lspci -D -d 1002:ab40 | ${pkgs.gawk}/bin/awk '{print ''$1}')
        UPSTREAM=''$(${pkgs.coreutils}/bin/basename "''$(readlink -f /sys/bus/pci/devices/''$VGA/../)")

        gpu_bound() {
          [ "''$(${pkgs.coreutils}/bin/basename "''$(readlink -f /sys/bus/pci/devices/''$VGA/driver 2>/dev/null)" 2>/dev/null)" = "amdgpu" ]
        }

        wait_driverless() {
          for _i in 1 2 3 4 5; do
            [ -e "/sys/bus/pci/devices/$1/driver" ] || return 0
            sleep 1
          done
          return 1
        }

        for attempt in 1 2 3; do
          echo "''$VGA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
          echo "''$HDA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true

          echo "" > /sys/bus/pci/devices/''$VGA/driver_override 2>/dev/null || true
          echo "" > /sys/bus/pci/devices/''$HDA/driver_override 2>/dev/null || true

          if [ "''$attempt" -gt 1 ] && [ -n "''$UPSTREAM" ]; then
            cur=''$(${pkgs.pciutils}/bin/setpci -s "''$UPSTREAM" BRIDGE_CONTROL.w)
            ${pkgs.pciutils}/bin/setpci -s "''$UPSTREAM" BRIDGE_CONTROL.w=''$(printf '%04x' ''$((0x''$cur | 0x40)))
            sleep 1
            ${pkgs.pciutils}/bin/setpci -s "''$UPSTREAM" BRIDGE_CONTROL.w="''$cur"
            sleep 1
          fi

          ${pkgs.pciutils}/bin/setpci -s "''${VGA#0000:}" CAP_PM+4.w=0x0000 2>/dev/null || true
          sleep 1

          ${pkgs.kmod}/bin/modprobe amdgpu 2>/dev/null || true
          wait_driverless "''$VGA" || true
          ${pkgs.coreutils}/bin/timeout 15 \
            sh -c 'echo "'"''$VGA"'" > /sys/bus/pci/drivers/amdgpu/bind' \
            2>/dev/null || true
          sleep 3

          if gpu_bound; then
            break
          fi
        done

        # Rebind audio: force off vfio-pci and confirm driverless first
        echo "''$HDA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
        echo "" > /sys/bus/pci/devices/''$HDA/driver_override 2>/dev/null || true
        wait_driverless "''$HDA" || \
          echo "WARN: ''$HDA still has a driver before snd_hda_intel bind" >&2

        ${pkgs.kmod}/bin/modprobe snd_hda_intel 2>/dev/null || true
        ${pkgs.coreutils}/bin/timeout 10 \
          sh -c 'echo "'"''$HDA"'" > /sys/bus/pci/drivers/snd_hda_intel/bind' \
          2>/dev/null || echo "WARN: snd_hda_intel bind for ''$HDA timed out or failed" >&2

        # Restore VT consoles
        for vt in /sys/class/vtconsole/vtcon*; do
          [ -e "''$vt/bind" ] && echo 1 > "''$vt/bind" 2>/dev/null || true
        done
      '';

  # also used by the dgpu-passthrough specialisation, which mkForce's the list
  vfioKernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "vfio-iommu_type1.allow_unsafe_interrupts=1"
    "kvmfr.static_size_mb=64"
    "kvm_amd.avic=1"
    "kvm_amd.force_avic=1"
    "kvm.ignore_msrs=0" # important to always GP on unknown MSRs
    "tsc=reliable"
  ];
in
{
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"

    "amdgpu"
    "kvmfr"
  ];

  boot.kernelParams = vfioKernelParams ++ [
    "vfio-pci.ids=1002:164e,1002:1640"
  ];
  specialisation = {
    # Flip: igpu for host, dgpu passed to VM
    dgpu-passthrough.configuration = {
      boot.kernelParams = lib.mkForce (
        [
          # keep in sync with core/boot.nix
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
          "amdgpu.ppfeaturemask=0xffffffff"
          "mitigations=off"
        ]
        ++ vfioKernelParams
        ++ [
          #"vfio-pci.ids=1002:7550,1002:ab40"
          "irqaffinity=0-6,16-22"
          "nohz_full=7-15,23-31"
          "rcu_nocbs=7-15,23-31"
          "kvm_amd.nested=1"
          "kvm_amd.npt=1"
          "kvm_amd.vls=1"
          "kvm_amd.vgif=1"
          "default_hugepagesz=1G"
          "hugepagesz=1G"
          "hugepages=16"
        ]
      );
    };
  };
  boot.extraModprobeConfig = ''
    softdep amdgpu pre: vfio_pci
  '';
  environment.etc = {
    "vbios/7950x.rom".source = ./vbios/vbios_7950x.bin;
    "vbios/9070.rom".source = ./vbios/9070.bin;
    "vbios/7950xGOP.rom".source = ./vbios/AMDGopDriver_7950x.rom;
    "libvirt/hooks/qemu.d/${vmName}/prepare/begin/gpu.sh".source = startScript;
    "libvirt/hooks/qemu.d/${vmName}/release/end/gpu.sh".source = releaseScript;
  };

  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"
  '';

  fileSystems."/dev/hugepages" = {
    device = "hugetlbfs";
    fsType = "hugetlbfs";
    options = [
      "pagesize=1G"
      "mode=01770"
      "gid=libvirtd"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${qemuDispatcher}"
  ];
}
