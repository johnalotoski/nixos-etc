{
  boot = {
    # For multi-sdr support which is more difficult to suppress from shell on a temporary basis
    blacklistedKernelModules = [
      "dvb_usb_rtl28xxu"
      "rtl2832"
      "rtl2830"
      "dvb_usb_v2"
    ];

    # For multi-sdr support which is more difficult to suppress from shell on a temporary basis
    extraModprobeConfig = ''
      install dvb_usb_rtl28xxu /run/current-system/sw/bin/false
      install rtl2832 /run/current-system/sw/bin/false
      install rtl2830 /run/current-system/sw/bin/false
      install dvb_usb_v2 /run/current-system/sw/bin/false
    '';
  };
}
