{ inputs, config, pkgs, system, ... }:
let
  uudeck = pkgs.stdenv.mkDerivation {
        name = "uudeck";
        uumonitor = pkgs.fetchurl {
          url = "https://uu.gdl.netease.com/uuplugin/steam-deck-plugin-x86_64/v9.0.0/uu.tar.gz";
          sha256 = "sha256-AXmuJSZEBaEXNvKr6VS1u7UeT2MnLZdxr2SwtspCWts=";
        };
        uuservice = ./uuservice;
        dontBuild = true;
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          tar -xzf $uumonitor
          mkdir -p $out
          install -Dm755 ./uuplugin $out/bin/uuplugin
          install -Dm644 $uuservice $out/lib/systemd/system/uuplugin.service
          install -dm755 "$out/etc/uuplugin"
          install -Dm755 ./uu.conf "$out/etc/uu.conf"
        '';
        postFixup = ''
          wrapProgram $out/bin/uuplugin \
          --set PATH ${pkgs.lib.makeBinPath [
                pkgs.coreutils
                pkgs.findutils
                pkgs.gnumake
                pkgs.gnused
                pkgs.gnugrep
              ]}
        '';
      };
in
{
  environment.systemPackages = [ uudeck ];
  environment.etc = {
    "uu.conf".source = "${uudeck}/etc/uu.conf";
    "uuplugin/uu".text = "";
  };
  systemd.packages = [ uudeck ];
  systemd.services.uuplugin.enable = true;
}
