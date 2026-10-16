{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kzdkm = {
    isNormalUser = true;
    description = "kzdkm";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "i2c"
      "kvm"
      "input"
      "memflow"
    ];
  };

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };
}
