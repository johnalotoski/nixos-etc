{ config, pkgs, ... }:
{
  services.lorri.enable = true;
  programs.bash.interactiveShellInit = ''eval "$(direnv hook bash)"'';
  programs.zsh.interactiveShellInit = ''eval "$(direnv hook zsh)"'';
}
