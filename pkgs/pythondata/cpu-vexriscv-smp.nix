import ./common.nix {
  kind = "cpu";
  name = "vexriscv_smp";
  hash = "sha256-vJ19t0V3mV0XTQfD86/L3J09/OBbZHsiy1cQ96r9fXc=";
  license = licenses: licenses.mit;
  # They seem to have used pythondata-cpu-vexriscv as a starting point and
  # forgotten to update the test.py.
  doCheck = false;
}
