{
  self,
  pkgs,
  lib,
  ...
}: let

  mkWpPkg = name: url: sha256: pkgs.stdenv.mkDerivation {
    inherit name;
    src = pkgs.fetchurl {
      inherit url sha256;
    };
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  mkTheme = mkWpPkg;
  mkPlugin = mkWpPkg;

  wpPkgs = self.inputs.nixpkgs-wordpress.legacyPackages.x86_64-linux;

  wpThemes = {
    twentytwentytwo = mkTheme "twentytwentytwo" "https://downloads.wordpress.org/theme/twentytwentytwo.1.3.zip" "sha256-a5YLhx0c/Va6FkGteNSOif14/zWL6cs4r4zqIUjngLQ=";
  };

  wpPlugins = {
    antispam-bee = mkPlugin "antispam-bee" "https://downloads.wordpress.org/plugin/antispam-bee.2.11.1.zip" "sha256-0hMMXW6HeX86dF8ekZl9CZF9CrnWrou4SLVJWYSqdl4=";
    wpforo = mkPlugin "wpforo" "https://downloads.wordpress.org/plugin/wpforo.2.1.1.zip" "sha256-ONmBYTB6owNpIuoIYMqjv/bp+i4X774nmZqx9J8kZ8o=";
  };
in {
  disabledModules = [
    "services/web-apps/wordpress.nix"
    "services/web-servers/apache-httpd/default.nix"
  ];
  imports = [
    (self.inputs.nixpkgs-wordpress + "/nixos/modules/services/web-apps/wordpress.nix")
    (self.inputs.nixpkgs-wordpress + "/nixos/modules/services/web-servers/apache-httpd/default.nix")
  ];

  services.phpfpm.phpPackage = pkgs.php80;

  services.wordpress = {
    sites.localhost = {
      package = wpPkgs.callPackage ../pkgs/wordpress.nix {};
      themes = with wpThemes; [
        twentytwentytwo
      ];
      plugins = with wpPlugins; [
        antispam-bee
        wpforo
      ];
      extraConfig = ''
        define( 'FS_METHOD', 'direct' );
        define( 'WP_DEFAULT_THEME', 'twentytwentytwo' );
        define( 'WP_DEBUG', true );
        define( 'WP_DEBUG_LOG', '/var/lib/wordpress/localhost/debug.log' );
      '';
    };
  };
}
