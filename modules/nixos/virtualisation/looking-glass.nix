{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          patch -p2 --ignore-whitespace --verbose < ${./patches/looking-glass.patch}
        '';
      });
    })
  ];

  environment.systemPackages = [
    (pkgs.looking-glass-client.overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -fcf-protection=none";
      NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " --export-dynamic";
    }))
  ];
  security.wrappers = {
    looking-glass = {
      owner = "kzdkm";
      group = "kvm";
      capabilities = "cap_sys_ptrace+ep";
      source = "${pkgs.looking-glass-client}/bin/looking-glass-client";
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
  '';

  environment.etc."looking-glass-client.ini".text = ''
    [input]
    autoCapture=yes
    grabKeyboardOnFocus=yes
    rawMouse=yes
  '';
}
