# Replaces nix-index's stock command-not-found handler.
#
# Two things the upstream script gets wrong for this fleet:
#   - It chooses legacy `nix-env -iA` / `nix-shell -p` syntax whenever
#     ~/.nix-profile/manifest.json is absent, which it is on machines that only
#     ever install declaratively.
#   - It never mentions comma, even though common.nix enables it, so the
#     fastest path to just running the thing is the one it hides.
#
# nix-locate reads the prebuilt database from programs.nix-index.package,
# which nix-index-database swaps for the with-full-db variant.
{
  config,
  lib,
  ...
}: let
  handler = ''
    command_not_found_handle() {
      local cmd="$1"

      # Gate on fd 2, not fd 1: both the nix-locate lookup below and every
      # suggestion it prints go to stderr, so stderr is what decides whether
      # the work is worth doing. Testing stdout would run the lookup only to
      # discard it under `cmd 2>/dev/null`, and would withhold suggestions
      # under `cmd > file` even though the terminal is right there. Upstream
      # tests -t 1; this is a deliberate divergence.
      if [ -n "''${MC_SID-}" ] || ! [ -t 2 ]; then
        echo "$cmd: command not found" >&2
        return 127
      fi

      local attrs
      attrs=$(${config.programs.nix-index.package}/bin/nix-locate \
        --minimal --no-group --type x --type s --whole-name --at-root \
        "/bin/$cmd" 2>/dev/null)

      if [ -z "$attrs" ]; then
        echo "$cmd: command not found" >&2
        return 127
      fi

      {
        echo "The program '$cmd' is not installed. Run it once with:"
        echo
        echo "    , $cmd ..."
        echo
        echo "Or from a specific package:"
        echo "$attrs" | while read -r attr; do
          echo "    nix shell nixpkgs#$attr -c $cmd ..."
        done
        echo
        echo "To install it for your user:"
        echo "$attrs" | while read -r attr; do
          echo "    nix profile install nixpkgs#$attr"
        done
      } >&2

      return 127
    }
  '';
in {
  # Ours replaces theirs rather than layering on top of it.
  programs.nix-index = {
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  programs.bash.interactiveShellInit = handler;

  # zsh looks for the -handler spelling; reuse the same body.
  programs.zsh.interactiveShellInit =
    handler
    + ''
      command_not_found_handler() {
        command_not_found_handle "$@"
      }
    '';
}
