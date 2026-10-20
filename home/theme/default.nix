{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  target = "${config.xdg.stateHome}/noctalia/settings.toml";
  # Same derivation as the system package; Kvantum only picks up themes from
  # user-writable locations plus its own DATADIR, so expose it under
  # ~/.config/Kvantum too (Qt5's plugin does not scan XDG data dirs at all).
  kvlibadwaita = pkgs.callPackage ../../pkgs/kvlibadwaita.nix { };
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
      # moved to modules/nixos/desktop/theming.nix
      #pkgs.morewaita-icon-theme
    ];
    file = {
      "Pictures/Wallpapers/default.jpg".source = ./wallpaper.jpg;
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
      ".config/gtk-3.0/gtk.css".source = ./gtk-3.0/gtk.css;
      ".config/gtk-4.0/gtk.css".source = ./gtk-4.0/gtk.css;
      # Kvantum theme: Qt6 finds the system copy in $XDG_DATA_DIRS, but Qt5
      # uses the built-in fallback because nixpkgs only patches the Qt6 style
      # for XDG support. A user config also survives sandboxes that hide /etc.
      ".config/Kvantum/kvantum.kvconfig".text = ''
        theme=KvLibadwaitaDark
      '';
      ".config/Kvantum/KvLibadwaita".source = "${kvlibadwaita}/share/Kvantum/KvLibadwaita";
      ".config/Kvantum/Colors".source = "${kvlibadwaita}/share/Kvantum/Colors";
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
      if [ ! -e "${config.xdg.stateHome}/noctalia/settings.toml" ]; then
        echo "Bootstrapping "${config.xdg.stateHome}/noctalia/settings.toml" from repo default"
        ${pkgs.coreutils}/bin/install -D -m 0644 -v \
          "${./noctalia/settings.toml}" \
          ""${config.xdg.stateHome}/noctalia/settings.toml""
      else
        echo ""${config.xdg.stateHome}/noctalia/settings.toml" already exists — skipping bootstrap"
      fi
    '';
  };
}
