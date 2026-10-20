
{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  environment.systemPackages = [
    pkgs.ipsw
  ];
}
