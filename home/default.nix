{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{

  imports = [
    #../old/hyprland/hyprland.nix
    ./theme
    ./niri
    ./zed.nix
    ./idle.nix
  ];
  home = {
    username = "kzdkm";
    homeDirectory = "/home/kzdkm";
  };
}
