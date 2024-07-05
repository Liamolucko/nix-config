# A testing module, for figuring out what modules a module depends on.
#
# It exposes all modules as available to the installer, and doesn't disable
# hidden modules (modules that the default config doesn't tell you exist); that
# way, the installer will select the dependencies of your chosen module the way
# it would naturally without any of our interference.
#
# To use it, set `configName` to the name of the module you're adding /
# updating, and then look at the debug logs that this module also enables. You
# should see a section like this:
#
# DEBUG - Module: Vivado dest: /nix/store/.../opt/Xilinx/Vivado/2024.1 Archive numbers in module: ...
# DEBUG - Module: Vitis C++ dest: /nix/store/.../opt/Xilinx/Vitis_HLS/2024.1/vcxx Archive numbers in module: ...
# DEBUG - Module: Vitis HLS dest: /nix/store/.../opt/Xilinx/Vitis_HLS/2024.1 Archive numbers in module: ...
# ...
# DEBUG - Number of archives to extract: 361
#
# Ignoring the base modules (currently Adds Common Links, Vitis HLS, Vivado, and
# Xilinx Information Center, and Vitis C++ (kinda); you can find out what they
# are by setting `configName` to `null`), the modules listed there are the
# dependencies of your module.
#
# To start with, set them all as `looseDeps`; then, if the module doesn't show
# up anymore when you try to install it via. `archiveTests`, it means at least
# one of them needs to go in `tightDeps`, because it needs to be installed at
# the same time as your module.
#
# Also, feel free to ctrl-c the build once you've got the bit you needed out of
# the log.
{
  name = "test";
  configName = "Spartan-7";
  debug = true;
  allModules = true;
  ignoreHidden = true;
  archives = import ./test-archives.nix;
}
