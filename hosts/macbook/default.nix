{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  # Peripheral firmware (wifi, bluetooth, ...) stays on the ESP, it is
  # non-redistributable and this repo is public. Reading it needs --impure,
  # when evaluated from another machine the firmware is left out.
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
  # the ESP is 476M, ~120M of it is asahi/vendorfw/m1n1, a generation with its
  # own kernel takes ~70-100M
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = false;

  # 16G of RAM is not enough for parallel kernel/rust builds
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
