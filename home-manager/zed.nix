{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "github-theme"
      "github-dark-default"
    ];
    userSettings = {
      theme = {
        mode = "system";
        dark = "GitHub Dark Default";
        light = "GitHub Light";
      };
      vim_mode = true;
      base_keymap = "VSCode";
      relative_line_numbers = "enabled";
      ui_font_size = 15;
      buffer_font_size = 14;
      ui_font_family = "Inter";
      buffer_font_family = "Fira Code";
      buffer_line_height = "standard";
      buffer_font_weight = 400;
      autosave = "on_focus_change";
      languages = {
        "C++" = {
          format_on_save = "on";
          tab_size = 4;
        };
      };
      indent_guides = {
        line_width = 1;
        active_line_width = 1;
        coloring = "fixed";
      };
    };
  };
}
