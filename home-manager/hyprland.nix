{inputs, system, pkgs, ...} : {
  home = {
    packages = [
        pkgs.hyprcursor
    ];
  };
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
        inputs.Hyprspace.packages."${system}".default
        inputs.Hedge.packages."${system}".default
    ];
    settings = {
      monitor = [
        "desc: ViewSonic Corporation VX2719-2K-PRO VZC204000021, 2560x1440@165, 0x0, 1"
      ];
      exec-once = [
        "hyprpm reload"
        "ags-shell"
        "uwsm finalize"
        "easyeffects --gapplication-service"
        "sway-audio-idle-inhibit"
        "hyprsunset"
        "fcitx5 -r -d"
      ];
      env = [
        "HYPRCURSOR_THEME, Bibata-Original-Classic"
        "HYPRCURSOR_SIZE, 24"
        "XCURSOR_THEME, Bibata-Original-Classic"
        "XCURSOR_SIZE, 24"
      ];
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        accel_profile = "flat";
        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          clickfinger_behavior = true;
          tap-to-click = false;
        };
        sensitivity = 0;
      };
      device = {
        name = "topre-realforce-hybrid-us-tkl";
        kb_options = "ctrl:swapcaps";
      };
      general = {
        gaps_in = 8;
        gaps_out = 16;
        border_size = 1;
        "col.active_border" = "rgba(707070ff)";
        "col.inactive_border" = "rgba(323232ff)";
        layout = "dwindle";
        allow_tearing = true;
      };
      decoration = {
        rounding = 14;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          popups = false;
        };
        shadow = {
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };
      animations = {
        enabled = true;
        first_launch_animation = false;
        bezier = [
          "easeOut, 0, 1, .2, 1"
        ];
        animation = [
          "windows, 1, 3, easeOut"
          "windowsOut, 1, 1, default, popin 80%"
          "border, 1, 5, default"
          "borderangle, 1, 6, default"
          "fade, 1, 2, default"
          "workspaces, 1, 3, easeOut"
          "layers, 1, 2, easeOut"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_forever = true;
        workspace_swipe_use_r = true;
        workspace_swipe_distance = 600;
        workspace_swipe_cancel_ratio = 0.1;
        workspace_swipe_min_speed_to_force = 15;
      };
      misc = {
        vfr = true;
        vrr = 2;
        focus_on_activate = true;
        background_color = "0x000000";
        disable_hyprland_logo = true;
        new_window_takes_over_fullscreen = 2;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      debug = {
        disable_scale_checks = true;
      };
      plugin = {
        hypro = {
          top = 64;
        };
        overview = {
          overrideGaps = false;
          gapsIn = 10;
      		gapsOut = 30;
      		panelHeight = 300;
      		reservedArea = 32;
      		workspaceActiveBorder = "rgba(99999999)";
      		workspaceInactiveBorder = "rgba(55555599)";
      		drawActiveWorkspace = true;
      		showOvelayLayers = true;
      		hideRealLayers = false;
      		affectStrut = false;
      		panelBorderWidth = 0;
      		panelBorderColor = "rgba(707070cc)";
      		panelColor = "rgba(10101044)";
        };
      };
      windowrule = [
        "float, class:re.sonny.Junction"
        "float, class:org.gnome.NautilusPreviewer"
        "float, class:xdg-desktop-portal-gtk"
        "nofocus, class:^(Ibus-ui-gtk3)$"
        "pin, title:^(画中画)$"
        "float, title:^(画中画)$"
        "move 100%-340 100%-200, title:^(画中画)$"
        "size 320 180, title:^(画中画)$"
        "keepaspectratio, title:^(画中画)$"
        "pin, title:^(Picture-in-Picture)$"
        "float, title:^(Picture-in-Picture)$"
        "move 100%-340 100%-200, title:^(Picture-in-Picture)$"
        "size 320 180, title:^(Picture-in-Picture)$"
        "keepaspectratio, title:^(Picture-in-Picture)$"
      ];
      # TODO: let ags set the rules
      layerrule = [
        "blur, rofi"
        "ignorezero, rofi"
        "blur, swayosd"
        "ignorezero, swayosd"
        "blur, waybar"
        "ignorezero, waybar"
        "xray 1, waybar"
        "blur, bar"
        "ignorezero, bar"
        "xray 1, bar"
        "blur, dock"
        "ignorezero, dock"
        "animation slide, bar"
        "animation slide, dock"
        "blurpopups, bar"
        "blurpopups, dock"
        "blur, players"
        "ignorezero, players"
        "blur, applauncher"
        "ignorezero, applauncher"
        "blur, notifications0"
        "ignorezero, notifications0"
        "blur, quicksettings"
        "ignorezero, quicksettings"
        "blur, notifications"
        "ignorezero, notifications"
      ];
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, T, exec, blackbox"
        "$mainMod, B, exec, zen-beta"
        "$mainMod, BackSpace, killactive,"
        "$mainMod SHIFT, Q, exec, uwsm stop"
        "$mainMod, E, exec, nautilus -w"
        "$mainMod, F, togglefloating, "
        "$mainMod, Space, exec, ags toggle applauncher"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit, "
        "$mainMod, D, exec, ags toggle dock"
        "$mainMod, Return, fullscreen, 1"
        "$mainMod SHIFT, Return, fullscreen"
        "$mainMod, TAB, exec, hyprctl dispatch overview:toggle"
        "$mainMod, F12, exec, grimblast save area"

        # Fn controls
         ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
        ", XF86LaunchA, exec, hyprctl dispatch overview:toggle"
        ", XF86Search, exec, ./go/bin/ags --toggle-window 'applauncher'"

        # Power button and lid switch
        ", XF86PowerOff, exec, systemctl suspend --now"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, r-1"
        "$mainMod, mouse_up, workspace, r+1"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "bindm = $mainMod, mouse:273, resizewindow"
      ];
      hotedge = [
        "DP-2,bottom,8,128,ags request 'show dock',ags request 'hide dock',1"
      ];
    };
  };
}
