# PLACEHOLDER so the macbook config evaluates from other hosts.
# Replace with /etc/nixos/hardware-configuration.nix generated on the macbook
# before switching, these devices do not exist.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
    options = [ "subvol=nixos" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
