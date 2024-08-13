{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.fex;

  commonConfig = {
    wrapInterpreterInShell = false;
    # A translation of "${pkgs.fex}/share/binfmts/FEX-*".
    interpreter = "${pkgs.fex}/bin/FEXInterpreter";
    offset = 0;
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    matchCredentials = true;
    fixBinary = true;
    preserveArgvZero = true;
    # FEX also specifies an additional flag here, `expose_interpreter optional`:
    # this seems to have been set in advance of it being added to the kernel in
    # https://lore.kernel.org/lkml/20230907204256.3700336-1-gpiccoli@igalia.com/.
    # But that hasn't been merged so there's no point specifying it, plus NixOS
    # doesn't support it in the first place (unsurprisingly).
  };
in
{
  options = {
    programs.fex.enable = lib.mkEnableOption "Enable the use of FEX to run x86 and x86_64 binaries";
    programs.fex.package = lib.mkPackageOption pkgs "fex" { };
  };

  config = lib.mkIf cfg.enable {
    boot.binfmt.registrations.FEX-x86 = commonConfig // {
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
    };
    boot.binfmt.registrations.FEX-x86_64 = commonConfig // {
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    };
    nix.settings.extra-sandbox-paths = [
      "/run/binfmt"
      "${pkgs.fex}"
    ];
    nix.settings.extra-platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
