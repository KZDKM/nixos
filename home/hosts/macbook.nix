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

  # IDA Pro (native aarch64) is installed by its own installer into the home
  # dir, which creates no desktop entry. IDAPython uses the nix-ld libpython:
  #   ~/ida-pro-9.3/idapyswitch -s /run/current-system/sw/share/nix-ld/lib/libpython3.13.so.1.0
  xdg.desktopEntries.ida-pro =
    let
      idaDir = "${config.home.homeDirectory}/ida-pro-9.3";
    in
    {
      name = "IDA Pro";
      genericName = "Disassembler";
      exec = "${idaDir}/ida %f";
      icon = "${idaDir}/appico.png";
      categories = [ "Development" ];
      startupNotify = true;
    };
}
