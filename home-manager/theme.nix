{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  target = "${config.xdg.configHome}/noctalia/settings.json";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
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
      ".local/share/icons/MoreWaita".source = pkgs.fetchFromGitHub {
        owner = "somepaulo";
        repo = "MoreWaita";
        rev = "main";
        sha256 = "sha256-eCMU5RNlqHN6tImGd2ur+rSC+kR5xQ8Zh4BaRgjBHVc=";
      };
      # Set fcitx5 theme
      ".config/fcitx5/conf/classicui.conf".text = ''
        Vertical Candidate List=False
        Theme=macos12-light
        DarkTheme=macos12-dark
        UseDarkTheme=True
        PerScreenDPI=True
        EnableFractionalScale=True
      '';
      ".config/gtk-3.0/gtk.css".source = ./themes/gtk-3.0/gtk.css;
      ".config/gtk-4.0/gtk.css".source = ./themes/gtk-4.0/gtk.css;
    };
  };
  programs.noctalia = {
    enable = true;
    settings = {
    colors = {
      mPrimary = "#ffffff";
      mOnPrimary = "#1b1b1b";
      mSecondary = "#c6c6c6";
      mOnSecondary = "#303030";
      mTertiary = "#e2e2e2";
      mOnTertiary = "#1b1b1b";
      mError = "#ffb4ab";
      mOnError = "#690005";
      mSurface = "#000000";
      mOnSurface = "#e2e2e2";
      mSurfaceVariant = "#1a1a1a";
      mOnSurfaceVariant = "#c6c6c6";
      mOutline = "#474747";
      mShadow = "#000000";
      mHover = "#e2e2e2";
      mOnHover = "#1b1b1b";
    };
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        catwalk = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        kde-connect = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        pomodoro = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
    };

  };
  home.activation = {
    installConfigIfMissing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${target}" ]; then
        echo "Bootstrapping ${target} from repo default"
        ${pkgs.coreutils}/bin/install -D -m 0644 -v \
          "${./noctalia-settings.json}" \
          "${target}"
      else
        echo "${target} already exists — skipping bootstrap"
      fi
    '';
  };
}
