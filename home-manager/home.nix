{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{

  imports = [
    #./hyprland.nix
    ./theme.nix
    ./niri.nix
    ./zed.nix
  ];
  home = {
    username = "kzdkm";
    homeDirectory = "/home/kzdkm";
    stateVersion = "24.11"; # Please read the comment before changing.
    file."Pictures/Wallpapers/default.jpg".source = ./wallpaper.jpg;

  };

  xdg.configFile."openxr/1/active_runtime.json".source =
    "${pkgs.monado}/share/openxr/1/openxr_monado.json";
  xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "${config.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${config.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';
  services.swayidle =
    let
      lock = "${inputs.noctalia.packages.${system}.default}/bin/noctalia-shell ipc call lockScreen lock";
      # Hyprland
      # display = status: "hyprctl dispatch dpms ${status}";
      # Niri
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      timeouts = [
        {
          timeout = 2370; # in seconds
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds' -t 5000";
        }
        {
          timeout = 2400;
          command = lock;
        }
        {
          timeout = 2400;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = 2700;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = [
        {
          event = "before-sleep";
          # adding duplicated entries for the same event may not work
          command = (display "off") + "; " + lock;
        }
        {
          event = "after-resume";
          command = display "on";
        }
        {
          event = "lock";
          command = (display "off") + "; " + lock;
        }
        {
          event = "unlock";
          command = display "on";
        }
      ];
    };
}
