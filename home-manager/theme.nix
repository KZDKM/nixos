{pkgs, ...} : {
  gtk = {
    enable = true;
    #iconTheme = {
    #  name = "MoreWaita";
    #};
    cursorTheme = {
      name = "Bibata-Original-Classic";
    };
  };
  home = {
    packages = [
      pkgs.bibata-cursors
      # moved to configuration.nix
      #pkgs.morewaita-icon-theme
    ];
    file = {
        # Clone icon theme
        #".local/share/icons/MoreWaita".source = pkgs.fetchFromGitHub {
        #    owner = "somepaulo";
        #    repo = "MoreWaita";
        #    rev = "main";
        #    sha256 = "sha256-eCMU5RNlqHN6tImGd2ur+rSC+kR5xQ8Zh4BaRgjBHVc=";
        #};
        # Set fcitx5 theme
        ".config/fcitx5/conf/classicui.conf".text = ''
          Vertical Candidate List=False
          Theme=default-light
          DarkTheme=default-dark
          UseDarkTheme=True
          PerScreenDPI=True
          EnableFractionalScale=True
        '';
        ".config/gtk-3.0/gtk.css".source =  ./themes/gtk-3.0/gtk.css;
        ".config/gtk-4.0/gtk.css".source =  ./themes/gtk-4.0/gtk.css;
    };
  };
}
