# omacom/linux-aurora kernel

{
  inputs,
  lib,
  pkgs,
  ...
}:
let
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

        # this is needed for an ongoing issue of chromium showing green
        libva-v4l2_request-sofus13 = prev.libva-v4l2_request-sofus13.overrideAttrs {
          version = "1.3-aurora-unstable-2026-10-11";
          src = final.fetchFromGitHub {
            owner = "omacom";
            repo = "libva-v4l2_request";
            rev = "4f60c51f7841dd74bb61c94a4ad31e630bbdab01";
            hash = "sha256-+M2XnhPP/vdNZqBZcQ1nk/EXZFHdDGPAbvF67AK1J5A=";
          };
        };
      })
    ];

    # this m1n1 describes its ADT copy and log to Linux as phram regions, the
    # release keeps phram from binding them at boot
    boot.blacklistedKernelModules = [ "phram" ];

    boot.kernelPackages = lib.mkForce (pkgsKernel.linuxPackagesFor kernel);
    # NixOS default initrd modules are not in aurora's config
    boot.initrd.allowMissingModules = true;
  }
]
