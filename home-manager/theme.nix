{pkgs, ...} : {
  gtk = {
    enable = true;
    iconTheme = {
      name = "Skeuowaita";
    };
    cursorTheme = {
      name = "Bibata-Original-Classic";
    };
  };
  home = {
    packages = [
      pkgs.bibata-cursors
    ];
    file = {
        # Clone icon theme
        ".local/share/icons/Skeuowaita".source = pkgs.fetchFromGitHub {
            owner = "EuriNaiz";
            repo = "Skeuowaita";
            rev = "main";
            sha256 = "sha256-hbqrNcb2IOY1zxgBRjTM3gNPtWw3BXZ6VnAvw5VhMY8=";
        };
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
