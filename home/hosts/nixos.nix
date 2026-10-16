{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  imports = [
    ./vr.nix
  ];

  home.stateVersion = "24.11"; # Please read the comment before changing.

  nixpkgs.overlays = [ inputs.nixpkgs-xr.overlays.default ];

  xdg.configFile."niri/host.kdl".source = ../niri/hosts/nixos.kdl;
}
