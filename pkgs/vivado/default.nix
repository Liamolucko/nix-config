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
xinstall.run {
  pname = "vivado";
  edition = "Vivado ML Standard";
  product = "Vivado";
  validModules =
    [
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
    ]
    ++ lib.optionals (lib.versionAtLeast xinstall.version "2024.2") [
      "Versal AI Edge Series"
      "Versal Prime Series"
      # install_config.txt also lists an extra "Versal ACAP" module, but that seems to
      # be a mistake: the debug logs have warnings that it can't be configured and
      # installing it doesn't do anything. It doesn't show up in downloadRecord.dat
      # either, so I think it simply doesn't exist.
    ];

  modules = [ "Vivado" ] ++ modules;
  inherit extraPaths;

  postInstall = ''
    rm -rf $out/opt/Xilinx/.xinstall
  '';
}
