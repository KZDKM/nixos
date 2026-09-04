{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./libs.nix
    ./browser.nix
    #./spicetify.nix
    #./uuplugin.nix
    ./vr.nix
    ./vm.nix
    ./gaming.nix
    ./dev.nix
  ];

  # Bootloader.
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        splashImage = null;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };
    kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel_ccache;
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "amdgpu.ppfeaturemask=0xffffffff"
      "mitigations=off"
    ];

    # splash
    plymouth = {
      enable = true;
      theme = "spinner";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";
    };
  };
  hardware.amdgpu.initrd.enable = false;
  hardware.i2c.enable = true;

  networking.hostName = "nixos";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

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
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
          ];
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
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
    ];
  };
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kzdkm = {
    isNormalUser = true;
    description = "kzdkm";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "i2c"
      "kvm"
      "input"
      "memflow"
    ];
  };
  users.groups.memflow = {};

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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Inter"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "Fira Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };
  fonts.packages = [
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-cjk-sans
    pkgs.inter
    pkgs.fira-mono
    pkgs.fira-code
    pkgs.font-awesome
  ];
  services.gnome.core-apps.enable = true;
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

    # themes
    pkgs.adw-gtk3
    (pkgs.callPackage pkgs.stdenv.mkDerivation {
      name = "kvlibadwaita-theme";
      src = pkgs.fetchFromGitHub {
        owner = "GabePoel";
        repo = "KvLibadwaita";
        rev = "main";
        sha256 = "sha256-jCXME6mpqqWd7gWReT04a//2O83VQcOaqIIXa+Frntc=";
      };
      installPhase = ''
        mkdir -p $out/share/Kvantum/
        cp -r ./src/* $out/share/Kvantum
      '';
    })

    # system services
    pkgs.ags
    pkgs.networkmanagerapplet
    #inputs.ags.packages."${system}".default
    pkgs.noctalia-shell
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
    pkgs.inkscape
    pkgs.ungoogled-chromium
    pkgs.kdePackages.kdenlive

    pkgs.vesktop
    pkgs.obs-studio
    pkgs.netease-cloud-music-gtk
    (pkgs.prismlauncher.override {
      jdks = [
        pkgs.jdk11
        pkgs.jdk21
        pkgs.jdk25
      ];
    })
    #pkgs.lutris
    pkgs.wechat
    pkgs.tor-browser
    pkgs.telegram-desktop
    pkgs.ayugram-desktop
    pkgs.pomodoro-gtk
    pkgs.lmstudio
    pkgs.qbittorrent

    # utilities
    pkgs.gnome-tweaks
    pkgs.gpclient
    pkgs.gdm-settings
    pkgs.fastfetch
    pkgs.junction
    pkgs.protonplus
    pkgs.morewaita-icon-theme
    pkgs.solaar
    pkgs.xwayland-satellite
    pkgs.sbctl
    pkgs.vicinae
    pkgs.brightnessctl
    pkgs.ddcutil
    pkgs.usbutils
    pkgs.picocom # for serial monitoring
    pkgs.swayidle
    pkgs.wayland-pipewire-idle-inhibit
    pkgs.input-leap
    pkgs.kdePackages.qttools
    pkgs.kdePackages.kdeconnect-kde
    pkgs.gabutdm # download manager
    pkgs.liquidctl
    pkgs.gamescope
  ];

  # for kernel builds
  programs.ccache.enable = true;
  programs.ccache.packageNames = [ "linuxPackages_zen.kernel" ];
  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_DEBUG=1
          export KBUILD_BUILD_TIMESTAMP=""
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export CCACHE_SLOPPINESS="random_seed"
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
    inputs.nix-cachyos-kernel.overlays.default
    (self: super: {
      linuxKernel_ccache =
        pkgs.cachyosKernels.linux-cachyos-rc-lto.override
          {
            stdenv = pkgs.ccacheStdenv;
            buildPackages = super.buildPackages // {
              stdenv = pkgs.ccacheStdenv;
            };
            cpuSched = "bore";
            processorOpt = "zen4";
            tickrate = "full";
          };
    })
  ];
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;  # size in MiB
      priority = 10;
    }
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;  # 8G
  };
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  boot.kernel.sysctl = {
    "kernel.pid_max" = 4194304;
    "kernel.threads-max" = 4194304;
    "vm.max_map_count" = 2097152;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "kzdkm";
    dataDir = "/home/kzdkm"; # default location for new folders
    configDir = "/home/kzdkm/.config/syncthing";
  };
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" ];
    #scheduler = "scx_cosmos";
    #extraArgs = [
    #  "-m"
    #  "performance"
    #  "-c"
    #  "0"
    #  "-p"
    #  "0"
    #  "-w"
    #];
    package = pkgs.scx.rustscheds;
  };
  services.ananicy.enable = false;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="4001", MODE="0660", TAG+="uaccess"
    KERNEL=="i2c-*", GROUP="i2c", MODE="0660"
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"
    KERNEL=="memflow" SUBSYSTEM=="misc" GROUP="memflow" MODE="0660"
  '';

  programs.virt-manager.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.javaPackages.compiler.temurin-bin.jre-11;
  };

  # Set default themes
  environment.etc = {
    #"xdg/gtk-2.0".source =  ./themes/gtk-2.0;
    #"xdg/gtk-3.0".source =  ./themes/gtk-3.0;
    #"xdg/gtk-4.0".source =  ./themes/gtk-4.0;
    "xdg/Kvantum/kvantum.kvconfig".text = ''
      theme=KvLibadwaitaDark
    '';
    "niri/config.kdl".source = ../home-manager/config.kdl;
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
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
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
      pkgs.fcitx5-gtk # alternatively, kdePackages.fcitx5-qt
      pkgs.qt6Packages.fcitx5-chinese-addons # table input method support
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
    cpuFreqGovernor = "schedutil";
  };

  # === Run on every boot ===
  # One-shot service that runs after multi-user.target (USB/PCI devices are ready)
  systemd.services.liquidctl-fan-setup = {
    description = "Initialize liquidctl device and set fan curves on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ]; # ensures hardware is up

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; # optional, keeps the unit "active"
      ExecStart = pkgs.writeShellScript "liquidctl-boot-setup" ''
        echo "Running liquidctl initialize + fan setup on boot..."
        ${pkgs.liquidctl}/bin/liquidctl initialize --match H1 --pump-mode=quiet
        ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan1 speed 30 30 40 70 50 100
        ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan2 speed 30 30 40 70 50 100
      '';
    };
  };

  # === Run on resume from suspend (and hibernate/hybrid-sleep) ===
  # Classic systemd-sleep hook (runs as root, very early on resume)
  environment.etc."systemd/system-sleep/liquidctl-post-resume" = {
    text = ''
      #!/bin/sh
      # $1 = "pre" or "post", $2 = sleep type (suspend, hibernate, etc.)
      if [ "$1" = "post" ]; then
        echo "Running liquidctl initialize + fan setup after resume..."
        ${pkgs.liquidctl}/bin/liquidctl initialize --match H1 --pump-mode=quiet
        ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan1 speed 30 30 40 70 50 100
        ${pkgs.liquidctl}/bin/liquidctl --match H1 set fan2 speed 30 30 40 70 50 100
      fi
    '';
    mode = "0755";
  };

  # Optional: make the boot service retry once if the device isn't ready yet
  systemd.services.liquidctl-fan-setup.serviceConfig.Restart = "on-failure";
  systemd.services.liquidctl-fan-setup.serviceConfig.RestartSec = "2s";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
