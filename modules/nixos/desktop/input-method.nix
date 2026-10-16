{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Enable input method
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = [
      pkgs.fcitx5-gtk # alternatively, kdePackages.fcitx5-qt
      pkgs.qt6Packages.fcitx5-chinese-addons # table input method support
      (pkgs.callPackage ../../../pkgs/fcitx5-macos-theme.nix { })
    ];
  };
}
