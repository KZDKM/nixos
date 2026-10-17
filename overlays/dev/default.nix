# Local patches from ~/Patches/dev-niri and ~/Patches/dev-zed. To refresh them:
#   niri-ctm-gamma.patch:         git -C ~/Patches/dev-niri format-patch -1 --stdout work
#   niri-fullscreen-notch.patch:  git -C ~/Patches/dev-niri diff HEAD
#   zed-uclamp-boost.patch:       git -C ~/Patches/dev-zed diff HEAD
final: prev: {
  # The niri patches are against main, they don't apply to the 26.04 release
  niri = prev.niri.overrideAttrs (old: {
    version = "26.04-unstable-2026-09-22";
    src = final.fetchFromGitHub {
      owner = "niri-wm";
      repo = "niri";
      rev = "5f4469b6a992492cf7221b269e9379f42e737649";
      hash = "sha256-3nX7BEcI3swElm9J5GycBkyglLYWumtKcIz9eMuo+Ug=";
    };
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit (final.niri) src;
      name = "niri";
      hash = "sha256-vtTh+TG6TdX46QydGKaeo50u2qdQf3UkQ50EML+5H9c=";
    };
    patches = (old.patches or [ ]) ++ [
      ./niri-ctm-gamma.patch
      ./niri-fullscreen-notch.patch
    ];
    # `niri --version` still says 26.04
    doInstallCheck = false;
  });

  # on hold, low priority (and a long build). Also set programs.zed-editor.package
  # in home/hosts/macbook.nix when enabling, home-manager doesn't get this overlay.
  # zed-editor = prev.zed-editor.overrideAttrs (old: {
  #   patches = (old.patches or [ ]) ++ [ ./zed-uclamp-boost.patch ];
  # });
}
