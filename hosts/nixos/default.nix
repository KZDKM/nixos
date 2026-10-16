{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  imports = [
    #inputs.lanzaboote.nixosModules.lanzaboote
    inputs.barely-metal.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr

    ./hardware-configuration.nix
    ./hardware.nix
    ./boot.nix
    ./performance.nix
    ./apps.nix

    ../../modules/nixos
    ../../modules/nixos/vr
    ../../modules/nixos/virtualisation
    ../../modules/nixos/gaming.nix
  ];

  networking.hostName = "nixos";

  facter.reportPath = ./facter.json;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
