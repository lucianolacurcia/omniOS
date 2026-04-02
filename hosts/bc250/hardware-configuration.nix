# Placeholder - reemplazar con el generado por nixos-generate-config
# al instalar NixOS en la BC-250.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # AMD BC-250 (Zen 2 APU, Cyan Skillfish GPU)
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];

  # Display: solo DisplayPort 1.4 (para HDMI usar adaptador pasivo)
  # Red: Realtek RTL8111H (r8169)
  # Storage: M.2 2280 (NVMe PCIe 2.0 x2 o SATA III)

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
