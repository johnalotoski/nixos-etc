{ config, pkgs, ... }:

{
  # Close the 0lk LUKS volume key post boot so the unencrypted
  # key data cannot be accessed without unlocking again.
  systemd.services.closeLuksKeyVol = {
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.cryptsetup}/bin/cryptsetup luksClose 0lk || true";
  };
}
