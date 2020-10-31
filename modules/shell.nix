{ config, pkgs, ... }:

{
  programs.bash.enableCompletion = true;
  programs.bash.interactiveShellInit = ''
    if command -v fzf-share >/dev/null; then
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    fi
  '';
  environment.shellAliases = {
    manfzf = ''
      manix "" | grep "^# " | sed "s/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //" | fzf --preview="manix {}" | xargs manix
    '';
  };
  # programs.zsh.enable = true;
  # programs.zsh.autosuggestions.enable = true;
  # programs.zsh.syntaxHighlighting.enable = true;
  # programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";
  # programs.zsh.ohMyZsh.enable = true;
}
