{ pkgs, nix2container, wolframengine }:

let
  tmp = pkgs.runCommand "tmp" {} ''
    mkdir -p $out/tmp
  '';

in nix2container.buildImage {
  name = "wolframengine";
  tag = "13.0.0";

  contents = [
    tmp
    (pkgs.symlinkJoin {
      name = "root";
      paths = [ wolframengine ] ++ (with pkgs; [
        bash
        coreutils
        ncurses
        openssh
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
