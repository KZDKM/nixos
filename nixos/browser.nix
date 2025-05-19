{ inputs, system, ... }: {
  environment.systemPackages = [
    inputs.zen-browser.packages."${system}".default
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
