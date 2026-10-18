{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
{
  services.automatic-timezoned.enable = true;
  environment.etc."geoclue/conf.d/90-automatic-timezoned.conf".text = ''
    [ip]
    enable=true
    method=ichnaea

    [agent]
    whitelist=${
      lib.concatStringsSep ";" [
        "gnome-shell"
        "io.elementary.desktop.agent-geoclue2"
        "geoclue-demo-agent"
      ]
    }
  '';
  systemd.services.automatic-timezoned.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "30s";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
}
