{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    ags.url = "github:KZDKM/ags";
    Hyprspace.url = "github:KZDKM/Hyprspace";
    Hedge.url = "github:KZDKM/Hedge";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
        inherit (self) outputs;
        system = "x86_64-linux";
    in
    {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs system; };
            modules = [ ./nixos/configuration.nix ];
        };
        # TODO: maybe convert to standalone
        homeConfigurations = {
            "kzdkm@nixos" = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.${system};
                extraSpecialArgs = { inherit inputs outputs system; };
                modules = [ ./home-manager/home.nix ];
            };
        };
    };
  }
