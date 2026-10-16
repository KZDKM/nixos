{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  services.gnome.gnome-keyring.enable = true;
}
