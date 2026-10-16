{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  boot.kernel.sysctl = {
    "kernel.pid_max" = 4194304;
    "kernel.threads-max" = 4194304;
    "vm.max_map_count" = 2097152;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "65536";
    }
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];
}
