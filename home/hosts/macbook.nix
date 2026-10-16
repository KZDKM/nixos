{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  home.stateVersion = "26.11"; # Please read the comment before changing.

  xdg.configFile."niri/host.kdl".source = ../niri/hosts/macbook.kdl;
}
