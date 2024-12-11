{
  self,
  pkgs,
  ...
}: {
  nix = {
    package = self.inputs.nix.packages.${pkgs.system}.nix;

    settings = {
      builders-use-substitutes = true;

      extra-sandbox-paths = [
        "/etc/skopeo/auth.json=/etc/nix/skopeo/auth.json"
      ];

      # Fallback to source builds for failing cache paths
      fallback = true;

      max-jobs = 12;

      substituters = [
        "https://cache.iog.io"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      trusted-users = ["builder" "jlotoski" "root"];
    };

    extraOptions = ''
      netrc-file = /etc/nix/netrc
      experimental-features = nix-command flakes fetch-closure auto-allocate-uids configurable-impure-env
      auto-allocate-uids = false
      impure-env =
    '';
  };
}
