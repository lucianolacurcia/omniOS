{
  description = "omniOS - NixOS configs for thinkpad and bc250";

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://claude-code.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };

    # BC-250: Mesa patches + oberon governor
    nix-oberon = {
      url = "github:soapyham/nix-oberon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # BC-250: kernel driver freq/voltage patch + Rust governor
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, niri, noctalia, claude-code, nix-oberon, nur, ... }:
  let
    system = "x86_64-linux";
    commonHomeManager = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit nixvim noctalia claude-code; };
      home-manager.users.luciano = import ./home/luciano.nix;
    };
  in
  {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixvim noctalia claude-code; };
      modules = [
        ./hosts/thinkpad/configuration.nix
        ./hosts/thinkpad/hardware-configuration.nix

        niri.nixosModules.niri

        home-manager.nixosModules.home-manager
        commonHomeManager
      ];
    };

    nixosConfigurations.bc250 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixvim noctalia claude-code nix-oberon; };
      modules = [
        ./hosts/bc250/configuration.nix
        ./hosts/bc250/hardware-configuration.nix

        niri.nixosModules.niri
        nix-oberon.nixosModules.default

        home-manager.nixosModules.home-manager
        commonHomeManager
      ];
    };
  };
}
