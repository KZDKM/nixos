{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Enable nix-ld for compatibility
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      mesa
      libGL
      vulkan-loader

      # beamng
      alsa-lib.out
      at-spi2-atk.out
      cups.lib
      dbus.lib
      fontconfig.lib
      freetype.out
      glamoroustoolkit.out
      glib.out
      libgbm.out
      libgcc.lib
      libuuid.lib
      libx11.out
      libxcb.out
      libxcomposite.out
      libxdamage.out
      libxext.out
      libxfixes.out
      libxkbcommon.out
      libxrandr.out
      nspr.out
      nss.out
      pango.out
      systemdLibs.out
      xorg_sys_opengl.out

      glib
      glib-networking

      # binja
      dbus.lib
      fontconfig.lib
      freetype.out
      libGL
      libgcc.lib
      libx11.out
      libxkbcommon.out
      libz.out

      libxcb
      libxcb-wm
      libxcb-cursor
      libxcb-util
      libxcb-image
      libxcb-render-util
      libxcb-keysyms
      wayland
      wayland-protocols
      egl-wayland

      #ida
      python313

      llvmPackages.libclang

    ];
  };
  environment.systemPackages = [
    inputs.nix-alien.packages.${system}.nix-alien
    pkgs.nil
    pkgs.nixd
  ];
}
