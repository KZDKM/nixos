{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" ];
    #scheduler = "scx_cosmos";
    #extraArgs = [
    #  "-m"
    #  "performance"
    #  "-c"
    #  "0"
    #  "-p"
    #  "0"
    #  "-w"
    #];
    package = pkgs.scx.rustscheds;
  };
  services.ananicy.enable = false;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };
}
