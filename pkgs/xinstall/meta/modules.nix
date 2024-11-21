# Metadata about how to install modules which require special attention.
{
  lib,
  autoPatchelfHook,
  buildFHSEnv,
  libxcrypt-legacy,
  makeWrapper,
  ncurses5,
  qt5,
  xorg,
  zlib,
  meta,
}:
{
  "Vivado" =
    let
      # xelab assumes that GCC is available at /usr/bin/gcc, so we have to use an FHS
      # env.
      xelab-fhs = buildFHSEnv {
        name = "xelab-fhs";
        targetPkgs = pkgs: [ pkgs.gcc ];
        runScript = "";
      };
    in
    {
      patches =
        [
          # Required for the GUI's detection of when runs have finished to work.
          ../patches/vivado-no-abs-touch.patch
          # Required for the generated simulation scripts to work.
          ../patches/vivado-no-abs-bash.patch
          # Required for Vivado to be able to modify the `.ini`s it copies from the Nix
          # store which I believe contain the paths of simulated versions of IP. (The
          # ModelSim/Questa bits aren't necessarily needed since those aren't part of
          # Vivado itself and so might not be in the Nix store, but they also might be so
          # I included them anyway.)
          ../patches/vivado-chmod-ini.patch
          # There's no way to fake the argv[0] of a shell script, as far as I'm aware, so
          # we need to patch it.
          ../patches/vivado-xelab-argv0.patch
          # Allows Vivado to run on aarch64 (via Rosetta or FEX).
          ../patches/vivado-ignore-arch.patch
        ]
        ++ lib.optionals (lib.versionOlder "2024.2" meta.version) [
          ../patches/vitis-hls-ignore-arch.patch
        ];
      nativeBuildInputs = [
        makeWrapper
      ];
      postInstall =
        ''
          mkdir -p $out/bin
          for exe in $(ls $out/opt/Xilinx/Vivado/${meta.version}/bin); do
            if ! echo "$exe" | grep -E 'loader|unwrapped|.*\.sh'; then
              # We have to make wrappers instead of symlinks because Vivado looks for all its
              # stuff relative to the binary you're running, so putting them in the wrong spot
              # breaks it.
              makeWrapper "$out/opt/Xilinx/Vivado/${meta.version}/bin/$exe" "$out/bin/$exe"
            fi
          done

          makeWrapper $out/opt/Xilinx/Vitis_HLS/${meta.version}/bin/vitis_hls $out/bin/vitis_hls

          mkdir -p $out/etc/udev/rules.d
          find \
            $out/opt/Xilinx/Vivado/${meta.version}/data/xicom/cable_drivers/lin64/install_script/install_drivers \
            -name '*.rules' -exec cp '{}' $out/etc/udev/rules.d ';'
        ''
        + lib.optionalString (lib.versionOlder meta.version "2024.2") ''
          makeWrapper $out/opt/Xilinx/Vitis_HLS/${meta.version}/bin/apcc $out/bin/apcc
        '';
      postFixup =
        ''
          ln -s ${libxcrypt-legacy}/lib/libcrypt.so.1 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
          ln -s ${ncurses5}/lib/libtinfo.so.5 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
          ln -s ${xorg.libX11}/lib/libX11.so.6 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
          ln -s ${zlib}/lib/libz.so.1 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o

          mv $out/opt/Xilinx/Vivado/${meta.version}/bin/{xelab,.xelab-wrapped}
          makeWrapper ${xelab-fhs}/bin/xelab-fhs $out/opt/Xilinx/Vivado/${meta.version}/bin/xelab \
          --add-flags $out/opt/Xilinx/Vivado/${meta.version}/bin/.xelab-wrapped
        ''
        + lib.optionalString (lib.versionOlder meta.version "2024.2") ''
          ln -s ${libxcrypt-legacy}/lib/libcrypt.so.1 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
          ln -s ${ncurses5}/lib/libtinfo.so.5 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
          ln -s ${xorg.libX11}/lib/libX11.so.6 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
          ln -s ${zlib}/lib/libz.so.1 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
        '';
    };

  "DocNav" = {
    nativeBuildInputs = [
      autoPatchelfHook
      qt5.wrapQtAppsHook
    ];
    buildInputs = [
      qt5.qtserialport
      qt5.qtwebengine
    ];
    # Make sure to only apply this to DocNav: some of Vivado's binaries have empty
    # section names, which crashes patchelf.
    dontAutoPatchelf = true;
    postInstall = ''
      mkdir -p $out/bin
      # Using a symlink works here because it's already wrapped, meaning that the
      # original binary still gets invoked from its original path.
      ln -s $out/opt/Xilinx/DocNav/docnav $out/bin
    '';
    postFixup = ''
      rm -rf $out/opt/Xilinx/DocNav/{lib,libexec,plugins,translations}
      patchelf $out/opt/Xilinx/DocNav/docnav \
        --replace-needed libcrypto.so.10 libcrypto.so \
        --replace-needed libssl.so.10 libssl.so
      autoPatchelf $out/opt/Xilinx/DocNav
      wrapQtApp $out/opt/Xilinx/DocNav/docnav
    '';
  };
}