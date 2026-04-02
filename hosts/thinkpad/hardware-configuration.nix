# Placeholder - reemplazar con el generado por nixos-generate-config
# al instalar NixOS en el thinkpad.
#
# Ese comando genera este archivo con:
# - Filesystem mounts
# - Kernel modules para tu hardware
# - CPU microcode
# - etc.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Estos valores se auto-generan al instalar NixOS.
  # Por ahora dejamos lo minimo para que el flake evalúe.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

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
