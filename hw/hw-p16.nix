{
  self,
  config,
  ...
}: {
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

    # ACPI GPE storm on USB-C/Thunderbolt DP-alt monitors: gpe46 + gpe6E flood
    # the SCI handler (irq/9-acpi + a kacpid kworker peg a core, fan spins up).
    # Experienced on an older Blackwell driver.  Kept in case of re-occurrence.
    #
    # If a hot-plug or another event does trigger a storm, mask at runtime
    # (reversible with "enable"); watch which GPE climbs with:
    #   watch -n1 'grep -H . /sys/firmware/acpi/interrupts/* | grep -vE ":\s*0\b" | sort -t: -k2 -rn | head'
    #   echo disable | sudo tee /sys/firmware/acpi/interrupts/gpe46
    #   echo disable | sudo tee /sys/firmware/acpi/interrupts/gpe6E
    # Uncomment to mask from boot if the storm becomes a nuisance:
    # kernelParams = ["acpi_mask_gpe=0x46" "acpi_mask_gpe=0x6E"];

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
      open = true;

      # nixos-26.05's newest nvidia driver is 595.71.05 (production == stable;
      # its `beta`/`latest` are actually OLDER), and this Blackwell GPU keeps
      # faulting on it (Xid 13 FECS, Xid 13 shader, Xid 31 MMU -> reboot
      # required). Pull the 610.43.03 new_feature-branch driver from nixpkgs
      # master by version+hashes and build it against the local kernel via
      # mkDriver. A whole series newer, so much more mature Blackwell support.
      # Hashes from nixpkgs master at:
      # pkgs/os-specific/linux/nvidia-x11/default.nix (new_feature block).
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.43.03";
        sha256_64bit = "sha256-ReLUwTSiPDXlDyU6SqY+fl6NF+PRhdSgfIpY6WEu05I=";
        sha256_aarch64 = "sha256-jSdlXo60ilXLKWKvZfgbBnVqVYuw6zhnGuiDgwxYz94=";
        openSha256 = "sha256-QCXmqo2xNyIwjGv0da2MUC8ex641Mmc5DUI+uRFVwgE=";
        settingsSha256 = "sha256-z/t+SdEQdVJPwjKIRHO02d264Kt47eWiOwwsaxmh4xQ=";
        persistencedSha256 = "sha256-sOKUsAFHh0/COH+nNgbH9+7hWgivOzq4YmTuk9MOFfI=";
      };

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
