{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # macbook asahi kernel pin
    nixpkgs-asahi-kernel.url = "github:nixos/nixpkgs/55bfb4d7437bd4e09ab7cba58a43bd68eb310044";
    # patched zed pin (overlays/dev)
    nixpkgs-zed.url = "github:nixos/nixpkgs/55bfb4d7437bd4e09ab7cba58a43bd68eb310044";

    #nixpkgs-zen619.url = "github:NixOS/nixpkgs/1c9104f5510d214bd947a46f36f78bd2a0f2eb05";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # used by old/spicetify.nix
    #spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    #spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # used by old/hyprland
    #ags.url = "github:KZDKM/ags";
    #ags.inputs.nixpkgs.follows = "nixpkgs";
    #Hyprspace.url = "github:KZDKM/Hyprspace";
    #Hedge.url = "github:KZDKM/Hedge";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    barely-metal = {
      url = "github:KZDKM/BarelyMetal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    claude-desktop-nix-flake.url = "github:poeck/claude-desktop-nix-flake";
    deepseek-harness.url = "github:moraxyc/deepseek-harness.nix";

    nix-x86-on-aarch64 = {
      url = "github:rowanG077/nix-x86-on-aarch64";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      mkHost =
        host: system:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              outputs
              system
              ;
          };
          modules = [ ./hosts/${host} ];
        };
      mkHome =
        host: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs outputs system; };
          modules = [
            ./home
            ./home/hosts/${host}.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost "nixos" "x86_64-linux";
        macbook = mkHost "macbook" "aarch64-linux";
      };
      homeConfigurations = {
        "kzdkm@nixos" = mkHome "nixos" "x86_64-linux";
        "kzdkm@macbook" = mkHome "macbook" "aarch64-linux";
      };
    };
}
