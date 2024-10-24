{ xinstall }:
xinstall.run {
  pname = "docnav";
  edition = "DocNav";
  product = "Documentation Navigator (Standalone)";

  modules = [ "DocNav" ];

  postInstall = ''
    rm -rf $out/opt/Xilinx/.xinstall
  '';
}
