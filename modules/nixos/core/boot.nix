{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
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
    #kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel_ccache;
    #kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    kernelPackages = pkgs.linuxPackages_zen;
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
    };
    # keep in sync with the dgpu-passthrough specialisation in virtualisation/vfio.nix
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

  # for kernel builds
  #programs.ccache.enable = true;
  #programs.ccache.packageNames = [ "linuxPackages_zen.kernel" ];
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    #(self: super: {
    #  ccacheWrapper = super.ccacheWrapper.override {
    #    extraConfig = ''
    #      export CCACHE_DEBUG=1
    #      export KBUILD_BUILD_TIMESTAMP=""
    #      export CCACHE_DIR="${config.programs.ccache.cacheDir}"
    #      export CCACHE_UMASK=007
    #      export CCACHE_SLOPPINESS="random_seed"
    #      if [ ! -d "$CCACHE_DIR" ]; then
    #        echo "====="
    #        echo "Directory '$CCACHE_DIR' does not exist"
    #        echo "Please create it with:"
    #        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
    #        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
    #        echo "====="
    #        exit 1
    #      fi
    #      if [ ! -w "$CCACHE_DIR" ]; then
    #        echo "====="
    #        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
    #        echo "Please verify its access permissions"
    #        echo "====="
    #        exit 1
    #      fi
    #    '';
    #  };
    #})
    #(self: super: {
    #  linuxKernel_ccache =
    #    pkgs.cachyosKernels.linux-cachyos-rc-lto.override
    #      {
    #        stdenv = pkgs.ccacheStdenv;
    #        buildPackages = super.buildPackages // {
    #          stdenv = pkgs.ccacheStdenv;
    #        };
    #        cpuSched = "bore";
    #        processorOpt = "zen4";
    #        tickrate = "full";
    #      };
    ##})
  ];

  #nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
}
