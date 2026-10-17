# Touch ID with aurora's apple_sep driver, the userspace side of
# tools/aurora-sep/aurora-touchid in the kernel tree and
# aurora-silicon/aurora-sep-userspace (libfprint's `aurora` driver).
#
# Matching runs in the Secure Enclave, Linux only sees /dev/sep-bio. The enclave
# saves its state after every enrol and verify into the device-wide xART store
# on the iBoot system container (nvme0n1p1), which macOS uses too. The driver
# writes there only with xartWrites below, and nothing works without it. Read
# tools/aurora-sep/XART-SAFETY.md and keep a raw image of that partition first:
#   sudo dd if=/dev/disk/by-partlabel/iBootSystemContainer of=<off-disk file> bs=1M
#
# The sensor calibration is per Mac and stays out of the repo, like
# /boot/vendorfw. Extract it once (read-only), then rebuild:
#   sudo aurora-extract-mesa-calibration -o /var/lib/aurora-touchid/mesa_calibration.bin
{
  lib,
  pkgs,
  ...
}:
let
  xartWrites = true;

  calibration = /var/lib/aurora-touchid/mesa_calibration.bin;

  # aurora-silicon/aurora-sep-userspace, libfprint/
  userspace = "https://raw.githubusercontent.com/aurora-silicon/aurora-sep-userspace/4cd00a488f97889d3d2f068e5f2694d7f9aaf5ed/libfprint";

  # the driver's ioctl interface (version 4), not in the kernel headers yet
  sepHeader = pkgs.runCommand "apple-sep-uapi" { } ''
    install -Dm644 ${
      pkgs.fetchurl {
        url = "${userspace}/apple-sep.h";
        hash = "sha256-AMsJQwRh4LB3Jhm8IFTI+XlEhPvD2AcmiVXA+y3kXBA=";
      }
    } $out/linux/apple-sep.h
  '';

  libfprint = pkgs.libfprint.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (pkgs.fetchurl {
        url = "${userspace}/libfprint-1.94.100-apple-sep.patch";
        hash = "sha256-Va70ogGVaKE66kgGTtg4WKfOSQJjb46F5Gh3zp2O8XI=";
      })
      (pkgs.fetchurl {
        url = "${userspace}/0002-aurora-report-unusable-captures-as-retries.patch";
        hash = "sha256-allEcQhM5dbmXj7azMfxCmLdO7HPwrzfprPyNXkGYgo=";
      })
    ];
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = toString (old.env.NIX_CFLAGS_COMPILE or "") + " -I${sepHeader}";
    };
  });

  extractCalibration = pkgs.runCommand "aurora-extract-mesa-calibration" { } ''
    install -Dm755 ${
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/omacom/linux-aurora/5ec1028c81526e1ed31db2b97e47edf8663e83cb/tools/aurora-sep/aurora-touchid/extract-mesa-calibration";
        hash = "sha256-Fah43POCoixdgH8PLHVP5w05uuyI9lrqGDsf5Wz2lEE=";
      }
    } $out/bin/aurora-extract-mesa-calibration
    sed -i '1s|.*|#!${pkgs.python3}/bin/python3|' $out/bin/aurora-extract-mesa-calibration
  '';
in
{
  boot.kernelParams = lib.mkIf (!xartWrites) [
    "apple_sep.xart_writes=0"
    "apple_sep.provision_keybag=0"
  ];

  # J414s's sensor node names no firmware-name, so the driver asks for the default
  hardware.firmware = lib.optional (builtins.pathExists calibration) (
    pkgs.runCommand "aurora-mesa-calibration" { } ''
      install -Dm644 ${calibration} $out/lib/firmware/apple/mesa_calibration.bin
    ''
  );

  environment.systemPackages = [ extractCalibration ];

  # The driver attaches to the running enclave once per boot (reloading it needs
  # a reboot), and reads the xART store from the iBoot container, so load it
  # once that partition is there, as aurora's apple-sep.service does.
  systemd.services.apple-sep = {
    description = "Apple SEP and Touch ID";
    wantedBy = [ "multi-user.target" ];
    wants = [ "dev-disk-by\\x2dpartlabel-iBootSystemContainer.device" ];
    after = [ "dev-disk-by\\x2dpartlabel-iBootSystemContainer.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe apple_sep";
    };
  };

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override { inherit libfprint; };
  };

  systemd.services.fprintd = {
    after = [ "apple-sep.service" ];
    serviceConfig = {
      # /dev/sep-bio shows up a few seconds after modprobe, once the enclave is
      # up. Without waiting fprintd caches "No devices available" until it idles.
      ExecStartPre = "${pkgs.writeShellScript "wait-for-sep-bio" ''
        i=0
        while [ ! -e /dev/sep-bio ] && [ $i -lt 150 ]; do sleep 0.1; i=$((i + 1)); done
        exit 0
      ''}";
      # a path rule would be resolved before /dev/sep-bio exists
      DeviceAllow = [ "char-misc rw" ];
    };
  };

  # A lock screen waiting for a finger at lid close leaves the sensor claimed
  # after resume; stopping fprintd drops the claim, D-Bus starts it again.
  powerManagement.powerDownCommands = ''
    if ${pkgs.systemd}/bin/systemctl -q is-active fprintd.service; then
      ${pkgs.coreutils}/bin/timeout 5 ${pkgs.systemd}/bin/systemctl stop fprintd.service || true
    fi
  '';
}
