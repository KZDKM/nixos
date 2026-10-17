{ lib, pkgs, ... }:
let
  tint = "rgba(0, 0, 0, 0.7)";
  userChrome = pkgs.writeText "userChrome.css" ''
    :root[zen-default-theme="true"] #zen-browser-background,
    :root[zen-default-theme="true"] #zen-toolbar-background {
      --zen-main-browser-background: ${tint} !important;
      --zen-main-browser-background-toolbar: ${tint} !important;
    }
  '';
  userJs = pkgs.writeText "user.js" ''
    user_pref("zen.widget.linux.transparency", true);
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';
in
{
  # Profile dirs have random names, so link into every profile that exists.
  home.activation.zenProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for profile in "$HOME"/.config/zen/*/; do
      [ -f "$profile/prefs.js" ] || continue
      run mkdir -p "$profile/chrome"
      run ln -sfn ${userChrome} "$profile/chrome/userChrome.css"
      run ln -sfn ${userJs} "$profile/user.js"
    done
  '';
}
