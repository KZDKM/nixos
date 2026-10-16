{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  memflow-kmod = config.boot.kernelPackages.callPackage ../../../pkgs/memflow-kmod.nix { };
in
{
  imports = [
    ./vfio.nix
    ./looking-glass.nix
    ./barely-metal.nix
    ./samba.nix
  ];

  boot.kernelPatches = [
    #{
    #  name = "kvm";
    #  patch = ./patches/kvm.patch;
    #}
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
          sed -e 's|/TPMCmd/Platform/src/|/|g' ${./patches/libtpms.patch} | patch -p1
        '';
      });
      patchedSwtpm = pkgs.swtpm.override { libtpms = pkgs.patchedLibtpms; };
    })
  ];

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
          #package = pkgs.patchedSwtpm;
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

  users.users.kzdkm.extraGroups = [
    "libvirtd"
    "docker"
    "kvm"
    "memflow"
  ];

  programs.virt-manager.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };
    }
  ];

  #boot.extraModulePackages = [ memflow-kmod ];
  #boot.kernelModules = [ "memflow" ];
  users.groups.memflow = {};
  services.udev.extraRules = ''
    KERNEL=="memflow" SUBSYSTEM=="misc" GROUP="memflow" MODE="0660"
  '';
}
