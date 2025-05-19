{inputs, system, ...}: {
  imports = [
    inputs.spicetify-nix.nixosModules.spicetify
  ];
  programs.spicetify = {
    enable = true;
    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${system}.extensions; [
        adblock
        lastfm
    ];
    theme = inputs.spicetify-nix.legacyPackages.${system}.themes.defaultDynamic;
  };
}
