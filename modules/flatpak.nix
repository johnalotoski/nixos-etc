{ pkgs, ... }:
{
  services.flatpak.enable = true;
  services.flatpak.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  # For NVIDIA GPUs, the following flatpaks may also be required:
  # flatpak install flathub org.freedesktop.Platform.GL.nvidia-XXX-XX
  # flatpak install flathub org.freedesktop.Platform.GL32.nvidia-XXX-XX
}
