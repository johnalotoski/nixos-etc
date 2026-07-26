# Stages an upstream Bitwarden browser extension build at a stable path, so the
# browser loads a known artifact from the store rather than tracking the Web
# Store independently of this config.
#
# Registration is manual and per browser profile: Chromium policy install needs
# a CRX update_url, which the upstream release zips do not carry.
#   brave://extensions -> remove any store-installed copy
#     -> Developer mode -> Load unpacked -> /etc/bitwarden-browser-extension
# Set the login region before entering credentials.
#
# Unpacked builds get a different extension ID than the store build, so
# anything keyed to that ID (biometric unlock, desktop app integration) will
# not be available.
{pkgs, ...}: let
  # Pinned deliberately; confirm the browser still authenticates before moving
  # it. Changing this without the matching hash fails the build.
  version = "2026.3.0";

  extension = pkgs.runCommand "bitwarden-browser-extension-${version}" {
    src = pkgs.fetchurl {
      url = "https://github.com/bitwarden/clients/releases/download/browser-v${version}/dist-chrome-${version}.zip";
      hash = "sha256-sbYPZetU37dGMxKjmaqJ0+salgaWKK6wUu/CX3pfHvk=";
    };
    nativeBuildInputs = [pkgs.unzip];
  } ''
    mkdir -p $out
    unzip -q $src -d $out

    # Refuse to stage an artifact whose manifest disagrees with the pin.
    test "$(${pkgs.jq}/bin/jq -r .version $out/manifest.json)" = "${version}"
  '';
in {
  # Stable path, GC-rooted by the system closure so the directory the browser
  # loads from cannot be collected.
  environment.etc."bitwarden-browser-extension".source = extension;
}
