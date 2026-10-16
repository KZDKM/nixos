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
    pkgs.jan
  ];
}
