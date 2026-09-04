{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  memflow-kmod = config.boot.kernelPackages.callPackage ./packages/memflow-kmod.nix { };
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

in
{
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"

    "amdgpu"
    "kvmfr"
  ];

  boot.kernelPatches = [
    {
      name = "kvm";
      patch = ./kvm.patch;
    }
  ];
  nixpkgs.overlays = [
    (final: prev: {
    #  qemu = prev.qemu.overrideAttrs (old: rec {
    #    version = "11.0.0";
    #    src = prev.fetchurl {
    #      url = "https://download.qemu.org/qemu-${version}.tar.xz";
    #      hash = "sha256-wEyjYBJlPzLRHGdNNwz1KnEOfT8Ywti2PkkyBSpIVNY=";
    #    };
    #    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    #      prev.python3Packages.setuptools
    #      prev.python3Packages.wheel
    #    ];
    #    # Re-add your patch if you want it back:
    #    #patches = (old.patches or [ ]) ++ [ ./qemu.patch ];
    #  });
      patchedLibtpms = prev.libtpms.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -e 's|/TPMCmd/Platform/src/|/|g' ${./libtpms.patch} | patch -p1
        '';
      });
      patchedSwtpm = pkgs.swtpm.override { libtpms = pkgs.patchedLibtpms; };
    })
    (final: prev: {
      looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          patch -p2 --ignore-whitespace --verbose < ${./looking-glass.patch}
        '';
      });
    })
  ];

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=1002:164e,1002:1640"
    "vfio-iommu_type1.allow_unsafe_interrupts=1"
    "kvmfr.static_size_mb=64"
    "kvm_amd.avic=1"
    "kvm_amd.force_avic=1"
    "kvm.ignore_msrs=0" # important to always GP on unknown MSRs
    "tsc=reliable"
  ];
  specialisation = {
    # Flip: igpu for host, dgpu passed to VM
    dgpu-passthrough.configuration = {
      boot.kernelParams = lib.mkForce [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
        "amdgpu.ppfeaturemask=0xffffffff"
        "mitigations=off"
        "amd_iommu=on"
        "iommu=pt"
        #"vfio-pci.ids=1002:7550,1002:ab40"
        "vfio-iommu_type1.allow_unsafe_interrupts=1"
        "kvmfr.static_size_mb=64"
        "kvm_amd.avic=1"
        "kvm_amd.force_avic=1"
        "kvm.ignore_msrs=0"
        "tsc=reliable"
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
      ];
    };
  };
  boot.extraModprobeConfig = ''
    softdep amdgpu pre: vfio_pci
  '';
  environment.etc = {
    "vbios/7950x.rom".source = ./vbios/vbios_7950x.bin;
    "vbios/9070.rom".source = ./vbios/9070.bin;
    "vbios/7950xGOP.rom".source = ./vbios/AMDGopDriver_7950x.rom;
  };
  environment.systemPackages = [
    (pkgs.looking-glass-client.overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -fcf-protection=none";
      NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " --export-dynamic";
    }))
  ];
  security.wrappers = {
    looking-glass = {
      owner = "kzdkm";
      group = "kvm";
      capabilities = "cap_sys_ptrace+ep";
      source = "${pkgs.looking-glass-client}/bin/looking-glass-client";
    };
  };
  boot.extraModulePackages = [ memflow-kmod ];
  boot.kernelModules = [ "memflow" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"
  '';

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = true;
        #package = pkgs.qemu_kvm;
        swtpm = {
          enable = true;
          package = pkgs.patchedSwtpm;
        };
        vhostUserPackages = [ pkgs.virtiofsd ];
        verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
            "/dev/kvmfr0"
          ]
        '';
      };
    };
    spiceUSBRedirection.enable = true;
    waydroid.enable = true;
    docker.enable = true;
  };

  facter.reportPath = ./facter.json;
  barelyMetal = {
    cpu = "amd";
    enable = true;
    probeData = builtins.fromJSON (builtins.readFile ./probe.json);
    spoofing = {
      bootLogo = ./boot-logo.bmp;
      spoofUsbSerials = true;
    };
    lookingGlass = {
      enable = true;
      spoofKvmfrIds = true;
      shmSize = 64;
    };
    users = [

      "kzdkm"
    ];
  };
  systemd.tmpfiles.rules = [
    "z /var/lib/barely-metal/bin/qemu-system-x86_64 0755 root kvm -"
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${qemuDispatcher}"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Share Server";
        "netbios name" = "nixos";
        security = "user";
      };

      share = {
        path = "/srv/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  fileSystems."/dev/hugepages" = {
    device = "hugetlbfs";
    fsType = "hugetlbfs";
    options = [
      "pagesize=1G"
      "mode=01770"
      "gid=libvirtd"
    ];
  };

  environment.etc = {
    "looking-glass-client.ini".text = ''
      [input]
      autoCapture=yes
      grabKeyboardOnFocus=yes
      rawMouse=yes
    '';
    "libvirt/hooks/qemu.d/${vmName}/prepare/begin/gpu.sh".source = startScript;
    "libvirt/hooks/qemu.d/${vmName}/release/end/gpu.sh".source = releaseScript;
  };


}
