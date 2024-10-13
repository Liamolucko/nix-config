{
  lib,
  pkgs,
  callPackage,
  buildFHSEnv,
  libxcrypt-legacy,
  makeWrapper,
  ncurses5,
  xorg,
  zlib,
  meta ? callPackage ./meta.nix { },
  # TODO: replace this with the installer's default config.
  modules ? [ ],
  extraPaths ? [ ],
}:
let
  # xelab assumes that GCC is available at /usr/bin/gcc, so we have to use an FHS
  # env.
  xelab-fhs = buildFHSEnv {
    name = "xelab-fhs";
    targetPkgs = pkgs: [ pkgs.gcc ];
    runScript = "";
  };

  linkExtraPaths = lib.concatStringsSep "\n" (
    lib.map (path: "${lib.getExe xorg.lndir} ${path} $out/opt/Xilinx") extraPaths
  );
in
callPackage ./common.nix (
  {
    inherit meta modules;
    archives = lib.sort lib.lessThan (
      lib.unique (meta.baseArchives ++ lib.concatMap (mod: meta.modules.${mod}.archives) modules)
    );
    patches = [
      # Required for the GUI's detection of when runs have finished to work.
      ./no-abs-touch.patch
      # Required for the generated simulation scripts to work.
      ./no-abs-bash.patch
      # There's no way to fake the argv[0] of a shell script, as far as I'm aware, so
      # we need to patch it.
      ./xelab-argv0.patch
      # Allows Vivado to run on aarch64 (via Rosetta or FEX).
      ./ignore-arch.patch
    ];

    nativeBuildInputs = [
      makeWrapper
    ] ++ lib.concatMap (mod: meta.modules.${mod}.nativeBuildInputs or [ ]) modules;
    buildInputs = lib.concatMap (mod: meta.modules.${mod}.buildInputs or [ ]) modules;

    postInstall = ''
      rm -rf $out/opt/Xilinx/.xinstall
      ${linkExtraPaths}

      mkdir $out/bin
      for exe in $(ls $out/opt/Xilinx/Vivado/${meta.version}/bin); do
        if ! echo "$exe" | grep -E 'loader|unwrapped|.*\.sh'; then
          # We have to make wrappers instead of symlinks because Vivado looks for all its
          # stuff relative to the binary you're running, so putting them in the wrong spot
          # breaks it.
          makeWrapper "$out/opt/Xilinx/Vivado/${meta.version}/bin/$exe" "$out/bin/$exe"
        fi
      done

      makeWrapper $out/opt/Xilinx/Vitis_HLS/${meta.version}/bin/vitis_hls $out/bin/vitis_hls
      makeWrapper $out/opt/Xilinx/Vitis_HLS/${meta.version}/bin/apcc $out/bin/apcc

      mkdir -p $out/etc/udev/rules.d
      find \
        $out/opt/Xilinx/Vivado/${meta.version}/data/xicom/cable_drivers/lin64/install_script/install_drivers \
        -name '*.rules' -exec cp '{}' $out/etc/udev/rules.d ';'

      ${lib.concatMapStrings (mod: meta.modules.${mod}.postInstall or "") modules}
    '';

    postFixup = ''
      ln -s ${libxcrypt-legacy}/lib/libcrypt.so.1 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
      ln -s ${ncurses5}/lib/libtinfo.so.5 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
      ln -s ${xorg.libX11}/lib/libX11.so.6 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o
      ln -s ${zlib}/lib/libz.so.1 $out/opt/Xilinx/Vivado/${meta.version}/lib/lnx64.o

      ln -s ${libxcrypt-legacy}/lib/libcrypt.so.1 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
      ln -s ${ncurses5}/lib/libtinfo.so.5 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
      ln -s ${xorg.libX11}/lib/libX11.so.6 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o
      ln -s ${zlib}/lib/libz.so.1 $out/opt/Xilinx/Vitis_HLS/${meta.version}/lib/lnx64.o

      mv $out/opt/Xilinx/Vivado/${meta.version}/bin/{xelab,.xelab-wrapped}
      makeWrapper ${xelab-fhs}/bin/xelab-fhs $out/opt/Xilinx/Vivado/${meta.version}/bin/xelab \
        --add-flags $out/opt/Xilinx/Vivado/${meta.version}/bin/.xelab-wrapped

      ${lib.concatMapStrings (mod: meta.modules.${mod}.postFixup or "") modules}
    '';

    passthru.archiveTests =
      let
        base = callPackage ./common.nix {
          pname = "vivado-test-base";
          inherit meta;
          # Vivado tries to stop you from installing it without any devices installed, but
          # including a downloadRecord.dat bypasses this: it seems to base the check on
          # your downloaded modules instead of what you've actually selected.
          modules = [ ];
          archives = import ./test-archives.nix;
          debug = true;
          # We don't care about the output actually being usable, so no need for any
          # patching.
          preInstall = ''
            # Replace this with the path where you 'Download and Install Later'ed your
            # archives.
            cp ${/home/liam/Downloads/2024.1/data/downloadRecord.dat} data/downloadRecord.dat
          '';
        };
      in
      {
        inherit base;
      }
      // lib.mapAttrs (
        name: value:
        callPackage ./common.nix {
          pname = "vivado-test-${name}";
          inherit meta;
          modules = [ name ];
          archives = import ./test-archives.nix;
          debug = true;
          xinstall = "${base}/opt/Xilinx/.xinstall/Vivado_${meta.version}";
          preInstall = ''
            substituteInPlace data/instRecord.dat \
              --replace-fail ${base}/opt/Xilinx $out/opt/Xilinx
          '';
        }
      ) meta.modules;
  }
  // lib.foldl lib.mergeAttrs { } (
    lib.map (
      mod:
      lib.removeAttrs meta.modules.${mod} [
        "nativeBuildInputs"
        "buildInputs"
        "postInstall"
        "postFixup"
        "archives"
      ]
    ) modules
  )
)
