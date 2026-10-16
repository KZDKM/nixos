{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    #nixpkgs-zen619.url = "github:NixOS/nixpkgs/1c9104f5510d214bd947a46f36f78bd2a0f2eb05";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # unused, niri comes from nixpkgs
    #niri-package = {
    #  url = "github:urayde/niri";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    #niri = {
    #  url = "github:sodiboo/niri-flake";
    #  inputs.niri-unstable.follows = "niri-package";
    #  # inputs.niri-stable.follows = "niri-package"; if you use stable
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # used by old/spicetify.nix
    #spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    #spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # used by old/hyprland
    #ags.url = "github:KZDKM/ags";
    #ags.inputs.nixpkgs.follows = "nixpkgs";
    #Hyprspace.url = "github:KZDKM/Hyprspace";
    #Hedge.url = "github:KZDKM/Hedge";

    # unused, booting with grub
    #lanzaboote = {
    #  url = "github:nix-community/lanzaboote/v0.4.2";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
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
