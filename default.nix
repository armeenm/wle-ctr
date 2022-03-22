{ name, tag, pkgs, nix2container, wolframengine }:

let
  tmp = pkgs.runCommand "tmp" {} ''
    mkdir -p $out/tmp
  '';

in nix2container.buildImage {
  inherit name tag;

  contents = [
    tmp
    (pkgs.symlinkJoin {
      name = "root";
      paths = [ wolframengine ] ++ (with pkgs; [
        bash
        ncurses
      ]);
    })
  ];

  perms = [ {
      path = tmp;
      regex = ".*";
      mode = "0777";
  } ];

  config = {
    entrypoint = [ "/bin/WolframKernel" ];
  };
}
