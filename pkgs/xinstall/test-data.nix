# A place to fill in what modules you've downloaded for testing.
{
  # This is a bit of a random choice, but it works because it doesn't add in extra
  # dependency modules like e.g. the 7 series does.
  #
  # TODO: I think it should be possible to allow using anything here by running
  # everything with `archives = []` so they'll crash after logging what modules
  # they're using, and then using `intersect` on those instead of the archives.
  testDevice = "Install Devices for Kria SOMs and Starter Kits";
  archives = [
    # Replace this with the list of archives in /path/to/download/payload.
    #
    # It should look something like this:
    # "docnav_0001"
    # "docnav_0002"
    # "ip_clibs_0003"
    # "ip_clibs_0004"
    # "ise_0001"
    # "ise_0004"
    # "rdi_0002"
    # "rdi_0003"
    # "vitis_cplus_0005"
    # "vitis_cplus_0006"
  ];
}
