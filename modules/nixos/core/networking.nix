{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable v2rayA daemon
  services.v2raya.enable = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "kzdkm";
    dataDir = "/home/kzdkm"; # default location for new folders
    configDir = "/home/kzdkm/.config/syncthing";
  };
}
