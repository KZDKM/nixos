{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #  withUWSM = true;
  #};
  programs.niri = {
    enable = true;
    #package = inputs.niri.packages.${system}.niri-unstable;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QS_ICON_THEME = "MoreWaita";
  };
  environment.etc."niri/config.kdl".source = ../../../home/niri/config.kdl;

  programs.noctalia = {
    enable = true;
    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  # Set desktop portal
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-hyprland
  ];
}
