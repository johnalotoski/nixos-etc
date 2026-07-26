{self, ...}: {
  imports = [
    (self.inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
    (self.inputs.disko.nixosModules.disko)
    (import ./disko-config-p16.nix {})
  ];

  boot = {
    # Reconciled against the nixos-generate-config output from the install.
    # That scan additionally found rtsx_pci_sdmmc (Realtek SD reader) and did
    # not list usbhid; usbhid is kept anyway so an external USB keyboard can
    # enter the ZFS passphrase in initrd, matching hw-p71.nix.
    initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];

    # Single ESP for now. When the second NVMe is added and converted to a
    # mirror, add a second entry (disk-zroot2-recovery -> /recovery), matching
    # the p71 config.
    loader.grub.mirroredBoots = [
      {
        devices = ["/dev/disk/by-partlabel/disk-zroot1-esp"];
        path = "/boot";
      }
    ];
  };

  hardware = {
    # Arrow Lake-HX NPU, as detected by nixos-generate-config. Loads the
    # intel_vpu driver; nothing uses it yet.
    cpu.intel.npu.enable = true;

    nvidia = {
      # Blackwell (RTX PRO 1000, GB207GLM) requires the open kernel modules.
      # If the nixos-26.05 default driver does not probe the GPU (machine drops
      # to Intel-only / simpledrm), pin a newer package here, e.g.
      #   package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = true;

      # NOTE: sync is an X11 mechanism -- NixOS implements it via Xorg config
      # and xrandr provider commands in the display manager's setupCommands,
      # none of which a Plasma Wayland session runs. On the internal panel it
      # is confirmed inert: nvidia-smi reports Disp.A Off, 2 MiB of VRAM in
      # use, no kwin_wayland process and 9 W at P4, i.e. the iGPU composites
      # and the card idles. Left as sync pending the external-output test,
      # since those may be muxed to the dGPU; if they are not, this should
      # become prime.offload to say what it actually does.
      prime = {
        sync.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
}
