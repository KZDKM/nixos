{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
      trusted-users = [ "root" "kzdkm" ];
      substituters = [ "https://deepseek-harness-nix.cachix.org" ];
      trusted-public-keys = [
        "deepseek-harness-nix.cachix.org-1:5NrkwLN9veNMhiINtU5ZeV4isXFhFsOwn6Ms7J1M+TA="
      ];
    };
}
