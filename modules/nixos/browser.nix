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
    (pkgs.wrapFirefox ((inputs.zen-browser.packages."${system}".zen-browser-unwrapped.override {
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
    }).overrideAttrs (old: {
          passthru = (old.passthru or { }) // {
            withFFmpeg = true;
          };
        })) {
      extraPrefs = ''
        defaultPref("mousewheel.default.delta_multiplier_y", 100);
        defaultPref("zen.urlbar.replace-newtab", false);
      '';
    })
    inputs.helium.packages.${system}.default
  ];
  # Set default browser
  xdg.mime = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (type: { name = type; value = "helium.desktop"; }) [
        "text/html"
        "application/xhtml+xml"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xht"
        "application/x-extension-xhtml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ]
    );
  };
}
