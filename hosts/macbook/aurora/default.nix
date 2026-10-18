# omacom/linux-aurora kernel

{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  rebase = false;

  # the kernel only follows the pinned nixpkgs-asahi-kernel input, see flake.nix
  pkgsKernel = import inputs.nixpkgs-asahi-kernel { inherit (pkgs.stdenv.hostPlatform) system; };

  release = {
    version = "7.1.12";
    rev = "5ec1028c81526e1ed31db2b97e47edf8663e83cb";
    hash = "sha256-wBnBcM0NsAtafWpHUgCUNRa0DznzqCIqyMH9vdkfPzI=";
  };

  kernel = pkgsKernel.linuxManualConfig {
    inherit (release) version;
    modDirVersion = "${release.version}-aurora";
    src = pkgsKernel.fetchFromGitHub {
      owner = "omacom";
      repo = "linux-aurora";
      inherit (release) rev hash;
    };
    configfile = ./config;
    kernelPatches = [
      {
        # omacom/linux-aurora#84
        name = "appledrm-panel-size";
        patch = ./appledrm-panel-size.patch;
      }
    ];
    # what buildLinux would derive from the config, NixOS modules check these
    features = {
      efiBootStub = true;
      netfilterRPFilter = true;
      rust = true;
    };
    extraMeta.branch = lib.versions.majorMinor release.version;
  };
in
lib.mkMerge [
  {
    nixpkgs.overlays = [
      (final: prev: {
        # m1n1-aurora 1.6.1.aurora17-5, source commit from the release's
        # mesa-matched-stack.json
        m1n1 = prev.m1n1.overrideAttrs {
          version = "1.6.1-aurora17";
          src = final.fetchFromGitHub {
            owner = "omacom";
            repo = "m1n1";
            rev = "d05ba17dfb771871d608225be42968bbb1e75a18";
            hash = "sha256-Ed1B/SyqCeq+1YPECS0J80tJickA/mgBJ1S0yGxx4aA=";
          };
        };
      })
    ];

    # this m1n1 describes its ADT copy and log to Linux as phram regions, the
    # release keeps phram from binding them at boot
    boot.blacklistedKernelModules = [ "phram" ];

  }

  (lib.mkIf (!rebase) {
    boot.kernelPackages = lib.mkForce (pkgsKernel.linuxPackagesFor kernel);
    # NixOS default initrd modules are not in aurora's config
    boot.initrd.allowMissingModules = true;
  })

  (lib.mkIf rebase {
    boot.kernelPatches = [
      {
        name = "aurora";
        patch = ./aurora.patch.xz;
        # Kconfig symbols aurora adds, set as in its release config
        structuredExtraConfig = with lib.kernel; {
          APPLE_CLPC = module;
          APPLE_MCC = yes;
          APPLE_PMC = yes;
          APPLE_PMP_REPORT_NEO = yes;
          APPLE_SEP_FV_INTERFACE = yes;
          APPLE_T6030_DISPLAY_GATE = yes;
          BT_MTK7932_PCIE = module;
          DRM_ACCEL_ANE = module;
          DRM_APPLE_FABRIC_CORE = module;
          DRM_APPLE_NEO = no;
          DRM_ASAHI_NEO = module;
          HID_APPLE_MTP_HAPTIC = module;
          MT7932_FULLMAC = module;
          PCIE_APPLE_PIODMA_DIAG = yes;
          RESET_APPLE_CIO = yes;
          SENSORS_APPLE_PMP_J613 = module;
          SERIAL_APPLE_DOCKCHANNEL = yes;
          SERIAL_APPLE_DOCKCHANNEL_EARLYCON = yes;
          SND_SOC_APPLE_T8140_AOP_AUDIO = module;
          SPI_APPLE_QSPI = module;
          USB4_APPLE_SOC = module;
        };
      }
      {
        # aurora builds pcie-apple in, it is a module here
        name = "pcie-apple-module";
        patch = ./pcie-apple-module.patch;
      }
    ];
  })
]
