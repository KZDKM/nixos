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
  qemuDispatcher = pkgs.writeShellApplication {
    name = "libvirt-qemu-dispatcher";
    bashOptions = [ ];
    text = builtins.readFile ./scripts/qemu-dispatcher.sh;
  };
  startScript = pkgs.writeShellApplication {
    name = "gpu-bind-vfio";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.kmod
    ];
    bashOptions = [ ];
    text = ''
      VGA='${vgaPciId}'
      HDA='${audioPciId}'
    '' + builtins.readFile ./scripts/gpu-bind-vfio.sh;
  };
  releaseScript = pkgs.writeShellApplication {
    name = "gpu-bind-host";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.pciutils
      pkgs.gawk
      pkgs.kmod
    ];
    bashOptions = [ ];
    # unquoted PCI addresses, never contain spaces
    excludeShellChecks = [
      "SC2046"
      "SC2086"
    ];
    text = builtins.readFile ./scripts/gpu-bind-host.sh;
  };

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
    "libvirt/hooks/qemu.d/${vmName}/prepare/begin/gpu.sh".source = lib.getExe startScript;
    "libvirt/hooks/qemu.d/${vmName}/release/end/gpu.sh".source = lib.getExe releaseScript;
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
    "L+ /var/lib/libvirt/hooks/qemu - - - - ${lib.getExe qemuDispatcher}"
  ];
}
