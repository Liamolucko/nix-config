{
  vscode-utils,
  buildNpmPackage,
  fetchFromGitHub,
  vsce,
}:
let
  pname = "hol4-vscode";
  version = "0.0.20-unstable-2026-03-27";

  vsix = buildNpmPackage {
    name = "${pname}-${version}.vsix";
    src = fetchFromGitHub {
      owner = "HOL-Theorem-Prover";
      repo = pname;
      rev = "0a8bfceb8e068714a59f91cf23c754182c774d67";
      hash = "sha256-SlReEuHTfoXwq4oeilLksu0vhRD7XG7mR+eOebW19xE=";
    };
    npmDepsHash = "sha256-YUtdts+BeNdg/whCMxf5KglMHlBxkmZjq+u4eiF3ZTo=";

    nativeBuildInputs = [ vsce ];

    dontNpmBuild = true;
    installPhase = ''
      vsce package --out $out --skip-license
    '';
  };
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit pname version;

  vscodeExtPublisher = "oskarabrahamsson";
  vscodeExtName = "hol4-mode";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  src = vsix;

  # putting off adding meta until they add a license to the repo...
})
