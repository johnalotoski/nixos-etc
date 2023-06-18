{
  config,
  lib,
  ...
}:
{
  services.hylafax = {
    enable = true;
    countryCode = "1";
    # Works with startech.com usb fax
    modems.ttyACM0 = {
      config = {
        FAXNumber = "11234567890";
        LocalIdentifier = "Local";
        RingsBeforeAnswer = 2;
      };
      type = "class2";
    };
  };

  environment.etc."hosts.hfaxd" = {
    mode = "0600";
    user = "uucp";
    text = ".*";
  };
}
