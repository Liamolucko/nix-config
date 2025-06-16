{
  lib,
  xinstall,
  # This needs to be overridden for the build to succeed, but we need to default
  # it to something to avoid getting an eval failure.
  modules ? [ ],
  extraPaths ? [ ],
}:
xinstall.run {
  pname = "vivado";
  edition = "Vivado ML Standard";
  product = "Vivado";
  optionalModules = [
    "Vitis Networking P4"
    (
      if lib.versionOlder xinstall.version "2025.1" then
        "Vitis Model Composer(Toolbox for MATLAB and Simulink. Includes the functionality of System Generator for DSP)"
      else
        "Vitis Model Composer(A toolbox for Simulink)"
    )
    "Vitis Embedded Development"
    "Power Design Manager (PDM)"
    "DocNav"
  ];
  # 2025.1 had a big naming overhaul.
  requiredModules =
    if lib.versionOlder xinstall.version "2025.1" then
      [
        "Install Devices for Kria SOMs and Starter Kits"
        "Zynq-7000"
        "Zynq UltraScale+ MPSoC"
        "Spartan-7"
        "Artix-7"
        "Kintex-7"
        "Kintex UltraScale"
        "Artix UltraScale+"
        "Kintex UltraScale+"
        "Virtex UltraScale+ HBM"
        "Virtex UltraScale+ 58G"
        "Virtex UltraScale+"
      ]
      ++ lib.optionals (lib.versionAtLeast xinstall.version "2024.2") [
        "Versal AI Edge Series"
        "Versal Prime Series"
        # install_config.txt also lists an extra "Versal ACAP" module, but that seems to
        # be a mistake: the debug logs have warnings that it can't be configured and
        # installing it doesn't do anything. It doesn't show up in downloadRecord.dat
        # either, so I think it simply doesn't exist.
      ]
    else
      [
        "Install devices for Alveo and edge acceleration platforms"
        "Install Devices for Kria SOMs and Starter Kits"
        # You're supposed to be able to install each product line separately (they even
        # added proper checkboxes to the GUI), but for some reason selecting any 7
        # series device causes all of them to be installed.
        "7 Series"
        "Zynq-7000 All Programmable SoC"
        "Zynq UltraScale+ MPSoCs"
        "Kintex UltraScale FPGAs"
        "Kintex UltraScale+ FPGAs"
        "Artix UltraScale+ FPGAs"
        "Virtex UltraScale+ FPGAs"
        "Virtex UltraScale+ HBM FPGAs"
        "Virtex UltraScale+ 58G FPGAs"
        "Spartan UltraScale+"
        # Versal Prime Series
        "xcvm1102"
        # Versal HBM Series
        "xcv80"
        # Versal AI Edge Series
        "xcve2002"
        "xcve2202"
        "xcve2102"
        "xcve2302"
      ];

  modules =
    [
      "xinstall"
      "Vivado"
    ]
    # TODO: does Vitis HLS actually do anything that proper Vitis doesn't in 2024.2? If not, don't bother supporting it after 2024.1
    ++ lib.optionals (lib.versionOlder xinstall.version "2025.1") [ "Vitis HLS" ]
    ++ lib.optionals (lib.versionAtLeast xinstall.version "2024.2") [ "Vitis for HLS" ]
    ++ modules;
  inherit extraPaths;
}
