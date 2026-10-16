{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  environment.systemPackages = [
    pkgs.adw-gtk3
    (pkgs.callPackage ../../../pkgs/kvlibadwaita.nix { })
    pkgs.morewaita-icon-theme
  ];

  # Set default themes
  environment.etc = {
    #"xdg/gtk-2.0".source =  ./themes/gtk-2.0;
    #"xdg/gtk-3.0".source =  ./themes/gtk-3.0;
    #"xdg/gtk-4.0".source =  ./themes/gtk-4.0;
    "xdg/Kvantum/kvantum.kvconfig".text = ''
      theme=KvLibadwaitaDark
    '';
  };
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "adw-gtk3-dark";
            icon-theme = "MoreWaita";
          };
        };
      }
    ];
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };
}
