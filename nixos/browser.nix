{ inputs, pkgs, system, ... }:
let
  # Fuck mozilla
  uBlockRelease = pkgs.lib.importJSON (
    builtins.fetchurl {
      url = "https://api.github.com/repos/gorhill/uBlock/releases/latest";
      sha256 = "sha256:1zsgiyqc7p81v08ipgvlqjzygy7pshnmw9dllfidn2dc64l0zz0h";
    }
  );
  uBlockUrl = builtins.head (builtins.filter (a: builtins.match ".*firefox.*" a.name != null) uBlockRelease.assets);
in {
  programs.firefox = {
    enable = true;
  };
  environment.systemPackages = [
    (pkgs.wrapFirefox (inputs.zen-browser.packages."${system}".beta-unwrapped.override {
      policies = {
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = uBlockUrl.browser_download_url;
            installation_mode = "force_installed";
          };
        };
      };
    }) {})
    ];
  # Set default browser
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };
}
