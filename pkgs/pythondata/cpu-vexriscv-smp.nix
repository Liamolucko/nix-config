import ./common.nix {
  kind = "cpu";
  name = "vexriscv_smp";
  hash = "sha256-ZigxOPTelx96hCw3t5TASgvxgMjJvOqLAiPHXhe0sXc=";
  license = licenses: licenses.mit;
  # They seem to have used pythondata-cpu-vexriscv as a starting point and
  # forgotten to update the test.py.
  doCheck = false;
}
