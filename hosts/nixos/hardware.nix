{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
let
  liquidctlSetup = pkgs.writeShellScript "liquidctl-setup" ''
    ${pkgs.liquidctl}/bin/liquidctl initialize --match H1 --pump-mode=quiet
    ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan1 speed 30 30 40 70 50 100
    ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan2 speed 30 30 40 70 50 100
  '';
in
{
  hardware.amdgpu.initrd.enable = false;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
    ];
  };
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  environment.systemPackages = [
    pkgs.ddcutil
    pkgs.liquidctl
  ];

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
    memoryPercent = 25;  # 8G
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="4001", MODE="0660", TAG+="uaccess"
    KERNEL=="i2c-*", GROUP="i2c", MODE="0660"
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"
  '';

  # === Run on every boot ===
  # One-shot service that runs after multi-user.target (USB/PCI devices are ready)
  systemd.services.liquidctl-fan-setup = {
    description = "Initialize liquidctl device and set fan curves on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ]; # ensures hardware is up

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; # optional, keeps the unit "active"
      ExecStart = pkgs.writeShellScript "liquidctl-boot-setup" ''
        echo "Running liquidctl initialize + fan setup on boot..."
        ${liquidctlSetup}
      '';
      # Optional: make the boot service retry once if the device isn't ready yet
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  # === Run on resume from suspend (and hibernate/hybrid-sleep) ===
  # Classic systemd-sleep hook (runs as root, very early on resume)
  environment.etc."systemd/system-sleep/liquidctl-post-resume" = {
    text = ''
      #!/bin/sh
      # $1 = "pre" or "post", $2 = sleep type (suspend, hibernate, etc.)
      if [ "$1" = "post" ]; then
        echo "Running liquidctl initialize + fan setup after resume..."
        ${liquidctlSetup}
      fi
    '';
    mode = "0755";
  };
}
