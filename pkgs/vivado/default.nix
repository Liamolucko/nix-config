{
  lib,
  pkgs,
  callPackage,
  buildFHSEnv,
  runCommand,
  writeText,
  libxcrypt-legacy,
  makeWrapper,
  ncurses5,
  xinstall,
  xorg,
  zlib,
  meta ? import ./meta.nix,
  modules ? [ ],
  extraPaths ? [ ],
}:
let
  modulesXml = lib.concatStrings (
    lib.mapAttrsToList (name: value: ''
      <entry>
        <key>${value.internalName}</key>
        <value>${name}</value>
      </entry>
    '') (lib.filterAttrs (name: value: value ? internalName) meta.modules)
  );
  downloadRecord = writeText "download-record" ''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <installationRecord imageVersion="NA" originalVersion="${meta.version}" version="${meta.version}">
      <installedModules>
        ${modulesXml}
      </installedModules>
      <installedPackage>WebPACKEdition_Web</installedPackage>
      <installedProduct>VivadoProd</installedProduct>
    </installationRecord>
  '';

  # xelab assumes that GCC is available at /usr/bin/gcc, so we have to use an FHS
  # env.
  #
  # TODO: I think we only previously tried patching /usr/bin/gcc out of the vivado binary... what if we try doing it to specifically xelab instead?
  xelab-fhs = buildFHSEnv {
    name = "xelab-fhs";
    targetPkgs = pkgs: [ pkgs.gcc ];
    runScript = "";
  };

  # The downloadRecord.dat is necessary to bypass xinstall's check that you've
  # selected at least one device: it seems to base it on the downloaded modules
  # instead of what you've actually selected, so if we always include all modules
  # we won't run into that error.
  stage1-installer = runCommand "vivado-stage1-installer" { } ''
    mkdir $out
    ${lib.getExe xorg.lndir} ${xinstall} $out
    cp ${downloadRecord} $out/data/downloadRecord.dat
  '';

  stage1 = callPackage ./common.nix {
    xinstall = stage1-installer;
    inherit meta;
    pname = "vivado-base";
    archives = meta.baseArchives;
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
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
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
    '';
  };

  stage2-installer = xinstall.overrideAttrs {
    name = "vivado-stage2-installer";
    src = "${stage1}/opt/Xilinx/.xinstall/Vivado_${meta.version}";
    unpackCmd = "";
    postFixup = ''
      substituteInPlace $out/data/instRecord.dat \
        --replace-fail ${stage1}/opt/Xilinx @out@
    '';
  };

  linkExtraPaths = lib.concatStringsSep "\n" (
    lib.map (path: "${lib.getExe xorg.lndir} ${path} $out/opt/Xilinx") (
      [ "${stage1}/opt/Xilinx" ] ++ extraPaths
    )
  );

  stage2 = callPackage ./common.nix {
    xinstall = stage2-installer;
    inherit meta modules;
    archives = lib.sort lib.lessThan (
      lib.unique (lib.concatMap (mod: meta.modules.${mod}.archives) modules)
    );
    nativeBuildInputs = [
      makeWrapper
    ] ++ lib.concatMap (mod: (meta.modules.${mod}.nativeBuildInputs or (x: [ ])) pkgs) modules;
    buildInputs = lib.concatMap (mod: (meta.modules.${mod}.buildInputs or (x: [ ])) pkgs) modules;
    preBuild = ''
      substituteInPlace data/instRecord.dat \
        --subst-var-by out $out/opt/Xilinx

      mkdir -p $out/opt/Xilinx
      ${linkExtraPaths}

      # Make .xinstall a copy instead of a symlink so that the installer can modify
      # it.
      rm -rf $out/opt/Xilinx/.xinstall
      cp -r ${stage1}/opt/Xilinx/.xinstall $out/opt/Xilinx/.xinstall
      chmod -R +w $out/opt/Xilinx/.xinstall

      # The installer checks for existing desktop/menu entries here to see what it has
      # to include in the new versions.
      mkdir .local
      cp -r ${stage1}/share .local/share
      cp -r ${stage1}/etc/xdg .config
      chmod -R +w .local/share .config
    '';

    # TODO: use some variant of `substitute` instead of sed? (And do it during copying it over in the first place in preBuild)
    postBuild = ''
      rm -rf $out/opt/Xilinx/.xinstall

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

      # Replace all the desktop entries' references to the previous derivation with
      # the new one, so that when Vivado's run through them it can see the new modules
      # that have been installed.
      find $out/{share,etc} -type f -exec sed -i "s@${stage1}@$out@" '{}' ';'

      ${lib.concatMapStrings (mod: meta.modules.${mod}.postBuild or "") modules}
    '';
  };
in
stage2
// {
  archiveTests =
    lib.mapAttrs (
      name: value:
      stage2.override {
        modules = [ name ];
        archives = import ./test-archives.nix;
        debug = true;
      }
    ) meta.modules
    // {
      base = stage1.override {
        archives = import ./test-archives.nix;
        debug = true;
      };
    };
}
