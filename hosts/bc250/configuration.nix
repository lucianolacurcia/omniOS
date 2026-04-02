{ config, pkgs, niri, cyan-skillfish-governor, ... }:

{
  networking.hostName = "bc250";

  # Bootloader (UEFI, CSM disabled in BIOS)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel: pin 6.18 (avoid 6.15.0-6.15.6 and 6.17.8-6.17.10, amdgpu broken)
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # BC-250 kernel params
  boot.kernelParams = [
    "amd_iommu=off"                  # IOMMU is broken on this board
    "amdgpu.sg_display=0"            # scatter-gather display fix
    "amdgpu.ppfeaturemask=0xffffffff" # enable all power management features
    "amdgpu.gttsize=14750"           # full 16GB GDDR6 access
    "ttm.pages_limit=3959290"
    "ttm.page_pool_size=3959290"
    "processor.ignore_ppc=1"         # ignore BIOS frequency limits
    "usbcore.autosuspend=-1"         # disable USB autosuspend
  ];

  # AMDGPU + Cyan Skillfish firmware
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Graphics (Vulkan RADV)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Cyan Skillfish GPU governor
  _module.args.self = cyan-skillfish-governor;
  services.cyan-skillfish-governor.enable = true;

  # Temperature sensors (NCT6686 SuperIO)
  boot.kernelModules = [ "nct6683" ];
  boot.extraModprobeConfig = ''
    options nct6683 force=true
  '';

  # GPU environment
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    RADV_DEBUG = "nohiz";            # fix z-buffer glitches
    RUSTICL_ENABLE = "radeonsi";     # OpenCL via rusticl
  };

  # WiFi (TP-Link TX10UB, RTL8821CU)
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu ];
  hardware.usb-modeswitch.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -KW -v 0bda -p 1a2b"
  '';

  # Networking (RTL8111H, r8169 driver)
  networking.networkmanager.enable = true;

  # Niri (binario precompilado via niri-flake cache)
  programs.niri.enable = true;
  programs.niri.package = niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;

  # Login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
      user = "greeter";
    };
  };

  # Firefox
  programs.firefox.enable = true;

  # Steam
  programs.steam.enable = true;

  # Servicios para Noctalia
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Audio (pipewire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Locale & keyboard
  time.timeZone = "America/Montevideo";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };
  console.keyMap = "us-acentos";

  # Wayland env vars
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.jetbrains-mono
  ];

  # Usuario
  users.users.luciano = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "networkmanager" "libvirtd" ];
  };

  # Virtualización
  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
  programs.virt-manager.enable = true;

  # Sudo sin contraseña para wheel
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
