{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
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
