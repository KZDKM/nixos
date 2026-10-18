# Local patches from ~/Patches/dev-niri and ~/Patches/dev-zed, takes the flake
# inputs. To refresh them:
#   niri-ctm-gamma.patch:         git -C ~/Patches/dev-niri format-patch -1 --stdout work
#   niri-fullscreen-notch.patch:  git -C ~/Patches/dev-niri diff HEAD
#   zed-uclamp-boost.patch:       git -C ~/Patches/dev-zed diff HEAD
inputs: final: prev: {
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
    # Swipe gesture speed overrides
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/layout/monitor.rs \
        --replace-fail "WORKSPACE_GESTURE_MOVEMENT: f64 = 300.;" "WORKSPACE_GESTURE_MOVEMENT: f64 = 900.;"
      substituteInPlace src/layout/scrolling.rs \
        --replace-fail "VIEW_GESTURE_WORKING_AREA_MOVEMENT: f64 = 1200.;" "VIEW_GESTURE_WORKING_AREA_MOVEMENT: f64 = 2400.;"
    '';
    # `niri --version` still says 26.04
    doInstallCheck = false;
  });

  # Built from the pinned nixpkgs-zed input (see flake.nix), so updating nixpkgs
  # doesn't rebuild it. home/hosts/macbook.nix uses this for home-manager too.
  zed-editor =
    (import inputs.nixpkgs-zed { inherit (final.stdenv.hostPlatform) system; }).zed-editor.overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [ ./zed-uclamp-boost.patch ];
      });
}
