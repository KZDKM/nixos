{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  impure = builtins ? currentSystem;
  onMacbook = impure && builtins.currentSystem == "aarch64-linux";
in
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support

    ./aurora
    ./aurora/touchid.nix
    ./boot.nix
    ./hardware-configuration.nix

    ./apps.nix
    ./compat.nix

    ../../modules/nixos
  ];

  assertions = [
    {
      assertion = impure;
      message = "the macbook config reads firmware from /boot/vendorfw, build it with --impure";
    }
  ];

  nixpkgs.overlays = [ (import ../../overlays/dev inputs) ];

  hardware.asahi.enable = true;
  hardware.asahi.extractPeripheralFirmware = onMacbook;
  hardware.asahi.peripheralFirmwareDirectory = if onMacbook then /boot/vendorfw else null;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  # ESP roughly 500M , 120M for asahi/vendorfw/m1n1, a generation takes up to 100M
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = false;

  #boot.kernelParams = [ "apple_pmgr_misc.idle_fabric_pstate=1" ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;  # size in MiB
      priority = 10;
    }
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # 8G
  };

  hardware.asahi.avd.vaapi-support = true;

  networking.hostName = "KZDKMs-MBP-NixOS";
  # wpa_supplicant lacks WPA3 on the broadcom chips
  networking.networkmanager.wifi.backend = "iwd";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # TODO: set to the value in /etc/nixos/configuration.nix on the macbook

}
