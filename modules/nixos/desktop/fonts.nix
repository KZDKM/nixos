{
  inputs,
  config,
  pkgs,
  system,
  ...
}:
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Inter"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "Fira Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };
  fonts.packages = [
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-cjk-sans
    pkgs.inter
    pkgs.fira-mono
    pkgs.fira-code
    pkgs.font-awesome
  ];
}
