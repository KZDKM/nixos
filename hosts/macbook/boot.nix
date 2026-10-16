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
    };
  };
}
