{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  home.stateVersion = "26.11"; # Please read the comment before changing.

  # same patched zed as the system, home-manager doesn't get the NixOS overlays
  programs.zed-editor.package = (pkgs.extend (import ../../overlays/dev inputs)).zed-editor;

  xdg.configFile."niri/host.kdl".source = ../niri/hosts/macbook.kdl;
}
