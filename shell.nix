{ pkgs ? import <nixpkgs> {}
, ocamlVersion ? import ./nix/ocamlDefaultVersion.nix }:
let
  ocamlPackages = pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}";
  local = pkgs.callPackage ./. { inherit ocamlVersion; };
in
pkgs.mkShell {
  inputsFrom = with local; [
    elastic-apm
    elastic-apm-logs-reporter
    elastic-apm-lwt-client
    elastic-apm-lwt-reporter
    elastic-apm-rock
  ];
  buildInputs = [ ocamlPackages.ocaml-lsp ocamlPackages.ocp-indent ] ++ local.testPackages;
}
