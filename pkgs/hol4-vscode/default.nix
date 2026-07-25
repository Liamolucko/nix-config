{ vscode-utils, buildNpmPackage, fetchFromGitHub }:
let
  pname = "hol4-vscode";
  version = "0.0.20-unstable-2026-03-27";
  src = fetchFromGitHub {
    owner = "HOL-Theorem-Prover";
    repo = pname;
    rev = "0a8bfceb8e068714a59f91cf23c754182c774d67";
    hash = "";
  };

  vsix = buildNpmPackage {
    name = "${pname}-${version}.vsix";
    src = fetchFromGitHub {
      owner = "HOL-Theorem-Prover";
      repo = pname;
      rev = "0a8bfceb8e068714a59f91cf23c754182c774d67";
      hash = "";
    };
    npmDepsHash = "";
    installPhase = ''
      npm exec --package=@vscode/vsce -- vsce package --out $out
    '';
  };
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit pname version;

  vscodeExtPublisher = "oskarabrahamsson";
  vscodeExtName = ".hol4-mode";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  src = vsix;
})
