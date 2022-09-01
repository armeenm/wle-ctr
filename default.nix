{ pkgs }:

let
  nix2container = pkgs.nix2container.nix2container;

  tmp = pkgs.nixpkgs.runCommand "tmp" {} ''
    mkdir -p $out/tmp
  '';

  fcCache = pkgs.nixpkgs.runCommand "fcCache" {} ''
    mkdir -p $out/var/cache/fontconfig
  '';

in nix2container.buildImage {
  name = "wolframengine";
  tag = "13.1.0";

  copyToRoot = [
    tmp
    fcCache

    (pkgs.nixpkgs.symlinkJoin {
      name = "root";
      paths = with pkgs.nixpkgs; [
        bash
        coreutils
        fontconfig.out
        ncurses
        readline
        wolfram-engine
      ];
    })
  ];

  perms = [
    {
      path = tmp;
      regex = ".*";
      mode = "0777";
    }
    {
      path = fcCache;
      reges = ".*";
      mode = "0700";
    }
  ];

  config = {
    entrypoint = [ "/bin/WolframKernel" ];
  };
}
