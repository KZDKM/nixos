# shared by all hosts, host specific modules are imported in hosts/<host>
{ inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default

    ./core/nix.nix
    ./core/auth.nix
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
    ./dev.nix
  ];
}
