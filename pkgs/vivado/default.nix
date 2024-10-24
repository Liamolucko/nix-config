{
  lib,
  xinstall,
  modules ? [
    # Default to the same modules as the installer so that
    # `nix build nixpkgs#vivado` actually does something useful.
    "Vitis Model Composer(Toolbox for MATLAB and Simulink. Includes the functionality of System Generator for DSP)"
    "DocNav"
    "Install Devices for Kria SOMs and Starter Kits"
    "Zynq-7000"
    "Zynq UltraScale+ MPSoC"
    "Spartan-7"
    "Artix-7"
    "Kintex-7"
    "Kintex UltraScale"
    "Artix UltraScale+"
    "Kintex UltraScale+"
    "Virtex UltraScale+"
    "Virtex UltraScale+ 58G"
    "Virtex UltraScale+ HBM"
  ],
  extraPaths ? [ ],
}:
let
  edition = "Vivado ML Standard";
  product = "Vivado";
  validModules = [
    "Vitis Networking P4"
    "Vitis Model Composer(Toolbox for MATLAB and Simulink. Includes the functionality of System Generator for DSP)"
    "Vitis Embedded Development"
    "Power Design Manager (PDM)"
    "DocNav"
    "Install Devices for Kria SOMs and Starter Kits"
    "Zynq-7000"
    "Zynq UltraScale+ MPSoC"
    "Spartan-7"
    "Artix-7"
    "Kintex-7"
    "Kintex UltraScale"
    "Artix UltraScale+"
    "Kintex UltraScale+"
    "Virtex UltraScale+"
    "Virtex UltraScale+ 58G"
    "Virtex UltraScale+ HBM"
  ];
in
xinstall.run {
  pname = "vivado";
  inherit
    edition
    product
    validModules
    extraPaths
    ;
  modules = [ "Vivado" ] ++ modules;

  postInstall = ''
    rm -rf $out/opt/Xilinx/.xinstall
  '';

  passthru.archiveTests =
    let
      base = xinstall.run {
        pname = "vivado-test-base";
        inherit
          edition
          product
          validModules
          ;
        # Vivado tries to stop you from installing it without any devices installed, but
        # including a downloadRecord.dat bypasses this: it seems to base the check on
        # your downloaded modules instead of what you've actually selected.
        #
        # We don't need to specify the "Vivado" module: that just tells `xinstall.run`
        # to use its archives and apply its patching, neither of which we care about
        # here.
        modules = [ ];
        inherit (import ./test-data.nix) archives;
        debug = true;
        preInstall = ''
          cp ${(import ./test-data.nix).downloadRecord} data/downloadRecord.dat
        '';
      };
    in
    {
      inherit base;
    }
    // lib.mapAttrs (
      name: value:
      xinstall.run {
        pname = "vivado-test-${lib.replaceStrings [ "+" ] [ "Plus" ] name}";
        inherit
          edition
          product
          validModules
          ;
        modules = [ name ];
        inherit (import ./test-data.nix) archives;
        debug = true;
        xinstall = "${base}/opt/Xilinx/.xinstall/Vivado_${xinstall.version}";
        preInstall = ''
          substituteInPlace data/instRecord.dat \
            --replace-fail ${base}/opt/Xilinx $out/opt/Xilinx
        '';
      }
    ) xinstall.meta.modules;
}
