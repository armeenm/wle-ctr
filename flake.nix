{
  description = "";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    utils.url = github:numtide/flake-utils;
    nix2container.url = github:nlewo/nix2container;
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        name = "wolframengine";
        version = "13.0.1";

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        nix2container = inputs.nix2container.packages.${system}.nix2container;
        
      in rec {
        packages.${name} = import ./default.nix {
          inherit name pkgs nix2container;
          tag = version;
        };

        defaultPackage = packages.${name};

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            skopeo
          ];
        };
      }
    );
}
