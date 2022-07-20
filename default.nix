{ name, tag, pkgs, nix2container }:

let
  tmp = pkgs.runCommand "tmp" {} ''
    mkdir -p $out/tmp
  '';

  fcCache = pkgs.runCommand "fcCache" {} ''
    mkdir -p $out/var/cache/fontconfig
  '';

in nix2container.buildImage {
  inherit name tag;

  copyToRoot = [
    tmp
    fcCache

    (pkgs.symlinkJoin {
      name = "root";
      paths = with pkgs; [
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
