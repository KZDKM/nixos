{
  inputs,
  config,
  pkgs,
  lib,
  pkgs-old,
  system,
  ...
}:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      steamtinkerlaunch
    ];
    package = pkgs.steam.override {
      extraProfile = ''
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      '';
    };
  };
  security.wrappers.bwrap.enable = lib.mkForce false;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  environment.systemPackages = [
    pkgs.adwsteamgtk
    pkgs.steamcmd
    pkgs.boxflat
    pkgs.wineWow64Packages.stable
    pkgs.wine
    pkgs.wine64
    pkgs.wineWow64Packages.staging
    pkgs.winetricks
    pkgs.wineWow64Packages.waylandFull
  ];
}
