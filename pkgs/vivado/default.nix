{
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

  modules = [ "Vivado" ] ++ modules;
  inherit extraPaths;

  postInstall = ''
    rm -rf $out/opt/Xilinx/.xinstall
  '';
}
