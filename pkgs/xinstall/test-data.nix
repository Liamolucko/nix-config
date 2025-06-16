# Here's how to package a new release of Vivado:
#
# - Download the single-file download, then run (in fish):
#
#   ```fish
#   for path in (ls)
#       echo "\"$path\" = \"$(nix hash file $path)\";"
#   end
#   ```
#
#   to get the hashes of all the archives. Then, paste that data into `hashes`
#   in `meta/<version>.nix`, and manually remove the version suffixes. You might
#   have to add in a `suffixes` as well.
# - Run ${xinstall}/xsetup -b ConfigGen to generate an install_config.txt, and
#   make sure there's a module in `vivado.nix` for every option in the
#   `Modules=...` line, using `versionOlder` / `versionAtLeast` to deal with
#   changes in the module list.
# - Run `NIXPKGS_ALLOW_UNFREE=1 nix eval --impure .#vivado.archives`, and paste
#   the result into `archives` in `meta/<version>.nix`.
# - Rename `base` to `Vivado`, and move the archives that are used to generate
#   `opt/Xilinx/.xinstall` into an `xinstall` module (so that it can be shared
#   with standalone DocNav).
# - And you're done! Test it out, and maybe add some `patches` or a
#   `postInstall`/`postFixup` in `modules.nix` if something isn't working.
{
  # Which archive to replace all the other archives with for archive tests: this
  # should be the smallest one you have downloaded.
  dummyArchive = "installer_0020";
}
