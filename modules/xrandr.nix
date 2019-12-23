{ config, pkgs, ... }:
{
  services.xserver.displayManager.setupCommands = ''
    if [ "$(xrandr | -c grep " connected ")" -eq "3" ]; then
      xrandr --dpi 261 --fb 11520x2160 --output DP-2 --primary --pos 3840x0 --panning 3840x2160+3840+0 --output DP-0.1 --scale 2x2 --pos 0x0 --panning 3840x2160+0+0 --output DP-0.2 --scale 2x2 --pos 7680x0 --panning 3840x2160+7680+0
    fi
  '';
}
