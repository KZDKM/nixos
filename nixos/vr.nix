{
  inputs,
  config,
  pkgs,
  pkgs-old,
  system,
  ...
}:
{

  boot.kernelPatches = [
    #{
      #name = "bsb";
      #patch = ./bsb.patch;
    #}
    {
      name = "amdgpu-ignore-ctx-privileges";
      patch = pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      };
    }
  ];
  services.lact.enable = true;
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  environment.systemPackages = [
    pkgs.wayvr
    pkgs.xr-hardware
  ];
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    IPC_EXIT_WHEN_IDLE = "1";
    U_PACING_APP_USE_MIN_FRAME_PERIOD = "1";
    #XRT_DEBUG_GUI = "1";
    XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";
    XRT_COMPOSITOR_DESIRED_MODE = "1";
    LH_OVERRIDE_ICD_MM = "64";
    #XRT_CURATED_GUI = "1";
  };
  services.udev.extraRules = ''
    # Bigscreen Beyond
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", GROUP="i2c"
    # Bigscreen Bigeye
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", GROUP="i2c"
    # Bigscreen Beyond Audio Strap
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", GROUP="i2c"
    # Bigscreen Beyond Firmware Mode?
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", GROUP="i2c"
  '';
}
