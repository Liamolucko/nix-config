# Unfortunately this only works for synthesis, not simulation, since
# /usr/bin/gcc is hardcoded in. Replacing all instances of "/usr/bin/gcc" with
# "gcc" doesn't work, so it seems like the path must be constructed at runtime.
#
# TODO:
# - Remove 'Add Design Tools or Devices' desktop entry, it's broken due to removing .xinstall (and would have crashed anyway when trying to modify the Nix store).
# - do something about xlicdiag being in both vivado and vitis hls; easiest answer is probably to just hardcode only including vitis_hls and apcc from vitis hls, since those plus xlicdiag are the only 3 binaries it has anyway.
# - The desktop entries' filenames contain timestamps, get rid of those.
args@{
  lib,
  requireFile,
  runCommand,
  glibc,
  temurin-jre-bin-21,
  xinstall,
  meta,
  pname ? "vivado",
  modules ? [ ],
  archives ? [ ],
  debug ? false,
  nativeBuildInputs ? [ ],
  preBuild ? "",
  postBuild ? "",
  ...
}:
let
  requireArchive =
    basename:
    requireFile rec {
      name = "${basename}_${meta.version}_${meta.suffix}.xz";
      message = ''
        Xilinx's archives cannot be downloaded automatically as they are gated behind
        export control.

        To obtain them, you can either:
        - Use the `xinstall` package and select the 'Download Image (Install
          Separately)' option, then set 'Image Contents' to 'Selected Product Only',
          making sure to select a superset of the components you want to install.
        - Download and extract https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_${meta.version}_${meta.suffix}.tar.gz.

        The first option is recommended, since it requires significantly less download
        time / disk space.

        Then, run nix-store --add-fixed sha256 /path/to/download/payload/* to add all of
        the archives to the nix store.

        The specific archive that you are missing is ${name}.
      '';
      hash = meta.hashes.${basename};
    };

  archiveCmds = lib.concatStringsSep "\n" (
    lib.map (
      archiveName:
      let
        archive = requireArchive archiveName;
      in
      if lib.elem archiveName archives then
        "ln -s '${archive}' $out/'${archive.name}'"
      else
        "touch $out/'${archive.name}'"
    ) (lib.attrNames meta.hashes)
  );
  payload = runCommand "payload" { } ''
    mkdir -p $out
    ${archiveCmds}
  '';

  modulesCfg = lib.concatStringsSep "," (
    lib.map (module: "${module}:${if lib.elem module modules then "1" else "0"}") (
      lib.attrNames (lib.filterAttrs (name: value: !(value.internal or false)) meta.modules)
    )
  );
  debugFlag = lib.optionalString debug "-x";
in
# Use runCommand instead of mkDerivation because the default hooks are not
# designed to handle this volume of data, and run extremely slowly; plus most of
# them aren't useful to us.
#
# TODO: would it be better to instead just use mkDerivation with `dontFixup = true`?
runCommand "${pname}-${meta.version}"
  (
    {
      inherit pname;
      inherit (meta) version;

      # glibc is there for getconf.
      nativeBuildInputs = [ glibc ] ++ nativeBuildInputs;

      meta = {
        description = "Design software for AMD adaptive SoCs and FPGAs";
        homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
      };
    }
    // (lib.removeAttrs args [
      "lib"
      "requireFile"
      "runCommand"
      "glibc"
      "temurin-jre-bin-21"
      "xinstall"
      "meta"
      "pname"
      "modules"
      "archives"
      "debug"
      "nativeBuildInputs"
      "preBuild"
      "postBuild"
    ])
  )
  ''
    cp -r ${xinstall}/* .

    ${preBuild}

    cp ${./install_config.txt} install_config.txt
    substituteInPlace install_config.txt \
      --subst-var-by out $out/opt/Xilinx \
      --subst-var-by modules '${modulesCfg}'

    PAYLOAD_LOCATION_FROM_USER=${payload} ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt ${debugFlag}

    # Switch out the vendored JRE for our version, since for some reason Vivado's
    # version relies on /usr/share/fontconfig existing.
    for jre in $(find "$out/opt/Xilinx" -name 'jre*'); do
      rm -rf "$jre"
      ln -s ${temurin-jre-bin-21} "$jre"
    done

    # For some reason Vivado puts its desktop entries and such into /build; copy
    # them into the right spot.
    if [ -e .local/share ]; then
      mkdir -p $out/share
      cp -r .local/share/* $out/share
    fi
    if [ -e .config ]; then
      mkdir -p $out/etc/xdg
      cp -r .config/* $out/etc/xdg
    fi

    local exe
    while IFS= read -r -d "" exe; do
      isELF "$exe" || continue
      echo "patching $exe"
      patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 "$exe" || true
    done < <(find "$out" -executable -type f -print0)

    patchShebangs --host $out

    ${postBuild}
  ''
