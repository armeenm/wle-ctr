{
  description = "";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    utils.url = github:numtide/flake-utils;
    nix2container.url = github:nlewo/nix2container;
  };

  outputs = inputs@{ self, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = rec {
          nixpkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          nix2container = inputs.nix2container.packages.${system};

          stdenv = nixpkgs.stdenvNoCC;
          mkShell = nixpkgs.mkShell.override { inherit stdenv; };
        };

        packages = rec {
          default = wle-ctr;
          wle-ctr = import ./. {
            inherit pkgs;
          };
        };
        
      in rec {
        inherit packages;

        devShell = pkgs.mkShell {
          packages = with pkgs.nixpkgs; [
            podman
            skopeo
          ];

          shellHook = ''
            export PATH=$PWD/util:$PATH
          '';
        };
      }
    );
}
