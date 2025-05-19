{ inputs, config, pkgs, system, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./browser.nix
      ./spicetify.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nixos";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
        };
      };
    };

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # Just in case...
  hardware.graphics.enable = true;

  users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kzdkm = {
    isNormalUser = true;
    description = "kzdkm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install Hyprland.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Setup zeh
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  # Set desktop portal
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-hyprland
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  fonts.fontconfig.enable = true;
  fonts.packages = [
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-cjk-sans
    pkgs.inter
    pkgs.fira-mono
    pkgs.fira-code
    pkgs.font-awesome
  ];
  environment.systemPackages = [
  # essentials
    ((pkgs.vim_configurable.override {  }).customize{
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        set shiftwidth=2
        set tabstop=2
        set expandtab
        set autoindent
        set smartindent
        syntax on
        " ...
      '';
      }
    )
    pkgs.wget
    pkgs.curl
    pkgs.git
    pkgs.psmisc
    pkgs.pciutils
    pkgs.ffmpeg-full
    pkgs.home-manager
    pkgs.gh

  # themes
    pkgs.adw-gtk3
    (pkgs.callPackage pkgs.stdenv.mkDerivation {
      name = "kvlibadwaita-theme";
      src = pkgs.fetchFromGitHub {
          owner = "GabePoel";
          repo = "KvLibadwaita";
          rev = "main";
          sha256 = "sha256-xBl6zmpqTAH5MIT5iNAdW6kdOcB5MY0Dtrb95hdYpwA=";
      };
      installPhase = ''
        mkdir -p $out/share/Kvantum/
        cp -r ./src/* $out/share/Kvantum
      '';
    })

  # system services
    pkgs.v2raya
    pkgs.ags
    pkgs.networkmanagerapplet
    pkgs.blueman
    inputs.ags.packages."${system}".default
    pkgs.hypridle
    pkgs.hyprsunset
    pkgs.sway-audio-idle-inhibit

  # must-have software
    pkgs.blackbox-terminal
    pkgs.pwvucontrol
    pkgs.easyeffects
    pkgs.mission-center
    pkgs.warp

    pkgs.zed-editor
    pkgs.vscodium
    pkgs.obsidian
    pkgs.libreoffice

    pkgs.steam
    pkgs.vesktop
    pkgs.obs-studio
    pkgs.netease-cloud-music-gtk

  # utilities
    pkgs.gnome-tweaks
    pkgs.nil
    pkgs.nixd
    pkgs.globalprotect-openconnect
    pkgs.adwsteamgtk
    pkgs.gdm-settings
    pkgs.fastfetch
  ];

  # Set default themes
  environment.etc = {
    #"xdg/gtk-2.0".source =  ./themes/gtk-2.0;
    "xdg/gtk-3.0".source =  ./themes/gtk-3.0;
    "xdg/Kvantum/kvantum.kvconfig".text = ''
      theme=KvLibadwaita
    '';
  };
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              gtk-theme = "adw-gtk3";
            };
          };
        }
    ];
  };

  # Enable input method
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = [
       pkgs.fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
       pkgs.fcitx5-chinese-addons  # table input method support
       (pkgs.callPackage pkgs.stdenv.mkDerivation {
             name = "fcitx5-theme";
             src = pkgs.fetchFromGitHub {
                 owner = "witt-bit";
                 repo = "fcitx5-theme-macos12";
                 rev = "main";
                 sha256 = "sha256-H0X3+/mJ8KH73cZhv3ilNz77CBviQma4D2cKQ/iNiVM=";
             };
             installPhase = ''
               mkdir -p $out/share/fcitx5/themes
               cp -r ./* $out/share/fcitx5/themes
             '';
           })
     ];
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  # Enable nix-ld for compatibility
  programs.nix-ld.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable v2rayA daemon
  services.v2raya.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
