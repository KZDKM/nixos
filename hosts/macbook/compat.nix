
{
  inputs,
  config,
  pkgs,
  system,
  ...
}: {
  imports = [
    inputs.nix-x86-on-aarch64.nixosModules.default
    {
      programs.x86-on-arm = {
        enable = true;
        steam.enable = true; # Optional desktop application
        wine.enable = true;  # Optional Wine launcher
      };
    }
  ];
}
