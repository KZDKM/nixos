{
  inputs,
  pkgs,
  system,
  ...
}:
let
  # Fuck mozilla
  uBlockRelease = pkgs.lib.importJSON (
    builtins.fetchurl {
      url = "https://api.github.com/repos/gorhill/uBlock/releases/latest";
      sha256 = "sha256:01ndjxbfci3in373cf075v0k2nbwvqf0lqazvlxhk8pal6gnrxvg";
    }
  );
  uBlockUrl = builtins.head (
    builtins.filter (a: builtins.match ".*firefox.*" a.name != null) uBlockRelease.assets
  );
in
{
  programs.firefox = {
    enable = true;
  };
  environment.systemPackages = [
    (pkgs.wrapFirefox (inputs.zen-browser.packages."${system}".zen-browser-unwrapped.override {
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
    }) { })
  ];
  # Set default browser
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };
}
