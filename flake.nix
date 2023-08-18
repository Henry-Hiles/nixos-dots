{
  inputs = {
    nixpkgs-heroic.url = "github:aidalgol/nixpkgs?ref=heroic-2.9";
    nixpkgs-google.url = "git+file:/home/quadradical/Documents/Code/nixpkgs/";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    adwaita-steam = {
      url = "github:tkashkin/Adwaita-for-Steam";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    stylix,
    self,
    ...
  } @ inputs: let
    system = hostname:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs self nixpkgs;
        };
        modules =
          [
            "${self}/${hostname}/configuration.nix"
            "${self}/${hostname}/hardware-configuration.nix"
            ./common.nix
          ]
          ++ nixpkgs.lib.optionals (builtins.pathExists "${self}/${hostname}/home-manager.nix") [
            home-manager.nixosModules.home-manager
            "${self}/${hostname}/home-manager.nix"
          ]
          ++ nixpkgs.lib.optionals (builtins.pathExists "${self}/${hostname}/stylix.nix") [
            stylix.nixosModules.stylix
            "${self}/${hostname}/stylix.nix"
          ];
      };
  in {
    nixosConfigurations = {
      "quadraticpc" = system "quadraticpc";
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
