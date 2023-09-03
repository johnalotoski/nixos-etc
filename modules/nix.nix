{
  self,
  pkgs,
  ...
}: {
  nix = {
    package = self.inputs.nix.packages.${pkgs.system}.nix;

    settings = {
      extra-sandbox-paths = [
        "/etc/skopeo/auth.json=/etc/nix/skopeo/auth.json"
      ];

      max-jobs = 12;

      substituters = [
        "https://cache.iog.io"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      trusted-users = ["root" "jlotoski"];
    };

    extraOptions = ''
      netrc-file = /etc/nix/netrc
      experimental-features = nix-command flakes repl-flake fetch-closure
    '';
  };
}
