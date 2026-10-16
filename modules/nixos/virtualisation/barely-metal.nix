{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
{
  barelyMetal = {
    cpu = "amd";
    enable = false;
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
  ];
}
