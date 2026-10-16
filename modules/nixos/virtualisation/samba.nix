{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Share Server";
        "netbios name" = "nixos";
        security = "user";
      };

      share = {
        path = "/srv/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
