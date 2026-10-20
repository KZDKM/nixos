{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
let
  inherit (pkgs) lib;

  # remove appmenu from DSH
  dshDesktop =
    inputs.deepseek-harness.packages.${system}.dsh-desktop-official.overrideAttrs
      (previous: {
        postInstall = (previous.postInstall or "") + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
          menuBundle="$out/lib/dsh-desktop/resources/app/lib/main.js"
          chmod u+w "$menuBundle"
          substituteInPlace "$menuBundle" \
            --replace-fail 'width: 1280,' 'autoHideMenuBar: true, width: 1280,'
          chmod 444 "$menuBundle"
        '';
      });
in
{

  imports = [
    inputs.claude-desktop-nix-flake.nixosModules.default
    inputs.deepseek-harness.nixosModules.default
  ];
  # List packages installed in system profile. To search, run:
  environment.systemPackages = [
    # essentials
    ((pkgs.vim-full.override { }).customize {
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [
          vim-nix
          vim-lastplace
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        set shiftwidth=2
        set tabstop=2
        set expandtab
        set autoindent
        set smartindent
        syntax on
      '';
    })
    pkgs.wget
    pkgs.curl
    pkgs.git
    pkgs.psmisc
    pkgs.pciutils
    pkgs.ffmpeg-full
    pkgs.home-manager
    pkgs.gh

    # system services
    pkgs.ags
    #pkgs.networkmanagerapplet
    #inputs.ags.packages."${system}".default
    #inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.hypridle
    pkgs.hyprsunset
    pkgs.sway-audio-idle-inhibit
    pkgs.grimblast

    # must-have software
    pkgs.blackbox-terminal
    pkgs.pwvucontrol
    pkgs.easyeffects
    pkgs.mission-center
    pkgs.warp
    pkgs.gnome-solanum

    pkgs.zed-editor
    pkgs.vscodium
    pkgs.obsidian
    pkgs.libreoffice
    pkgs.apostrophe
    pkgs.typesetter
    pkgs.inkscape
    pkgs.ungoogled-chromium
    pkgs.kdePackages.kdenlive
    pkgs.foliate
    pkgs.evince

    pkgs.vesktop
    pkgs.obs-studio
    pkgs.netease-cloud-music-gtk
    pkgs.wechat
    #pkgs.tor-browser
    pkgs.telegram-desktop
    pkgs.ayugram-desktop
    pkgs.pomodoro-gtk
    pkgs.lmstudio
    pkgs.lmstudio-bionic
    pkgs.qbittorrent

    # utilities
    pkgs.gnome-tweaks
    pkgs.gpclient
    pkgs.gdm-settings
    pkgs.fastfetch
    pkgs.junction
    pkgs.xwayland-satellite
    pkgs.sbctl
    pkgs.vicinae
    pkgs.brightnessctl
    pkgs.usbutils
    pkgs.picocom # for serial monitoring
    pkgs.swayidle
    pkgs.wayland-pipewire-idle-inhibit
    pkgs.input-leap
    pkgs.kdePackages.qttools
    pkgs.kdePackages.kdeconnect-kde
    pkgs.gabutdm # download manager
    pkgs.cachix
  ];

  programs.java = {
    enable = true;
    package = pkgs.javaPackages.compiler.temurin-bin.jre-11;
  };

  programs.claude-desktop.enable = true;

  # The module builds dsh from its overlay on our nixpkgs, which never matches
  # what deepseek-harness-nix.cachix.org holds (built against the flake's own
  # nixpkgs pin, x86_64-linux only). Use the flake's packages so x86_64 hits the
  # cache; aarch64 still builds, but only when the flake moves, not on every
  # nixpkgs update.
  programs.dsh = {
    package = inputs.deepseek-harness.packages.${system}.dsh;
    desktop = {
      enable = true;
      package = dshDesktop;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # apostrophe 3.5 from NixOS/nixpkgs#576276, 3.4 errors out on current nixpkgs
  # TODO: drop once the PR is merged
  nixpkgs.overlays = [
    (final: prev: {
      apostrophe = final.callPackage (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/cbb63b7f7e19cbb5b58a6a9d5ea771cdec407138/pkgs/by-name/ap/apostrophe/package.nix";
        sha256 = "sha256-8eVCfnqBjwFRd60EeH0U29uyaWiGE7+kT2+1cGoachs=";
      }) { };
    })
  ];

  # Evince for PDF (GNOME brings Papers, which would win otherwise)
  xdg.mime.defaultApplications = builtins.listToAttrs (
    map (type: { name = type; value = "org.gnome.Evince.desktop"; }) [
      "application/pdf"
      "application/x-bzpdf"
      "application/x-ext-pdf"
      "application/x-gzpdf"
      "application/x-xzpdf"
    ]
  );
}
