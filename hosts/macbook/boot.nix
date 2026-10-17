{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Bootloader.
  boot = {
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
    };
    # keep in sync with the dgpu-passthrough specialisation in modules/nixos/virtualisation/vfio.nix
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "appledrm.show_notch=1"
    ];

    # splash
    plymouth = {
      enable = true;
      theme = "spinner";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";
      # plymouth runs on simpledrm in the initrd (the aurora display driver is a
      # module that loads later), which has no panel size to pick a scale from
      extraConfig = "DeviceScale=2";
    };
  };
}
