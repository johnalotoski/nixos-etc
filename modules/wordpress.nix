{
  self,
  pkgs,
  lib,
  ...
}: let
  wpPkgs = self.inputs.nixpkgs-wordpress.legacyPackages.x86_64-linux;

  wpThemes = {
    # twentytwentyone = pkgs.stdenv.mkDerivation {
    #   name = "twentytwentyone";
    #   src = pkgs.fetchurl {
    #     url = https://downloads.wordpress.org/theme/twentytwentytwo.1.3.zip;
    #     sha256 = "sha256-a5YLhx0c/Va6FkGteNSOif14/zWL6cs4r4zqIUjngLQ=";
    #   };
    #   buildInputs = [ pkgs.unzip ];
    #   installPhase = "mkdir -p $out; cp -R * $out/";
    # };

    # wordpress-theme-responsive = pkgs.stdenv.mkDerivation {
    #   name = "responsive";
    #   src = pkgs.fetchurl {
    #     url = http://wordpress.org/themes/download/responsive.1.9.7.6.zip;
    #     sha256 = "06i26xlc5kdnx903b1gfvnysx49fb4kh4pixn89qii3a30fgd8r8";
    #   };
    #   buildInputs = [ pkgs.unzip ];
    #   installPhase = "mkdir -p $out; cp -R * $out/";
    # };
  };

  wpPlugins = {
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

  services.wordpress = {
    sites.localhost = {
      package = wpPkgs.callPackage ../pkgs/wordpress.nix {};
      themes = with wpPkgs; [
        # wordpressPackages.themes.twentytwentytwo
        # wpThemes.twentytwentyone
      ];
      plugins = with wpPkgs.wordpressPackages.plugins; [
        # antispam-bee
        # opengraph
      ];
      extraConfig = ''
        define('FS_METHOD', 'direct');
      '';
    };
  };
}
