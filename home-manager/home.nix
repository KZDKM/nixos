{ inputs, config, pkgs, system, ... }: {

  imports = [ ./hyprland.nix ./theme.nix ];
  home = {
    username = "kzdkm";
    homeDirectory = "/home/kzdkm";
    stateVersion = "24.11"; # Please read the comment before changing.
  };
}
