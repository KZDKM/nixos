{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{

  imports = [
    inputs.claude-desktop-nix-flake.nixosModules.default
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
    pkgs.networkmanagerapplet
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
    #pkgs.apostrophe
    pkgs.inkscape
    pkgs.ungoogled-chromium
    pkgs.kdePackages.kdenlive

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
  ];

  programs.java = {
    enable = true;
    package = pkgs.javaPackages.compiler.temurin-bin.jre-11;
  };

  programs.claude-desktop.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
