{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-zen619.url = "github:NixOS/nixpkgs/1c9104f5510d214bd947a46f36f78bd2a0f2eb05";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/65f066926ccf86ac7c6e872fd0851bd78e08a9b0";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri-package = {
      url = "github:urayde/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.niri-unstable.follows = "niri-package";
      # inputs.niri-stable.follows = "niri-package"; if you use stable
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:KZDKM/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";
    Hyprspace.url = "github:KZDKM/Hyprspace";
    Hedge.url = "github:KZDKM/Hedge";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    barely-metal = {
      url = "github:KZDKM/BarelyMetal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Recommended: nixos-facter for hardware auto-detection
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      barely-metal,
      nixos-facter-modules,
      niri,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            outputs
            system
            ;
        };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          barely-metal.nixosModules.default
          nixos-facter-modules.nixosModules.facter
          ./nixos/configuration.nix
        ];
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
