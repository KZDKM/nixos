{
  imports = [
    ./core/boot.nix
    ./core/nix.nix
    ./core/locale.nix
    ./core/users.nix
    ./core/networking.nix
    ./core/performance.nix

    ./desktop/session.nix
    ./desktop/audio.nix
    ./desktop/fonts.nix
    ./desktop/theming.nix
    ./desktop/input-method.nix

    ./apps.nix
    ./nix-ld.nix
    ./browser.nix
    #../../old/spicetify.nix
    #../../old/uuplugin/uuplugin.nix
    ./vr
    ./virtualisation
    ./gaming.nix
    ./dev.nix
  ];
}
