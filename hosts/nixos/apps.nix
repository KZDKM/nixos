{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  # not available on aarch64
  environment.systemPackages = [
    inputs.claude-desktop-nix.packages.${system}.default
    pkgs.jan
  ];
}
