{
  description = "";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    utils.url = github:numtide/flake-utils;
    nix2container.url = github:nlewo/nix2container;
    wolframengine.url = path:/home/armeen/src/wolframengine;
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        name = "wolframengine";
        version = "13.0.0";

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        lib = pkgs.lib;

        nix2container = inputs.nix2container.packages.${system}.nix2container;
        wolframengine = inputs.wolframengine.defaultPackage.${system};

      in rec {
        packages.${name} = pkgs.dockerTools.buildLayeredImage {
          inherit name;
          tag = version;

          contents = with pkgs; [
            coreutils
            gnugrep
            #iputils
            ncurses
            wolframengine
          ];

          config = {
            Entrypoint = [ "/bin/WolframKernel" ];
          };
        };

        packages."${name}2" = nix2container.buildImage {
          inherit name;
          tag = version;

          contents = [
            (pkgs.symlinkJoin {
              name = "root";
              paths = [
                wolframengine
              ] ++ (with pkgs; [
                bash
                coreutils
                gnugrep
                ncurses
              ]);
            })
          ];

          config = {
            Entrypoint = [ "/bin/WolframKernel" ];
          };
        };

        defaultPackage = packages.${name};

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            jdk11
          ];
        };
      }
    );
}
