{ config, pkgs, ... }:

{
  # Hostname
  networking.hostName = "thinkpad";

  # Bootloader (ajustar si usas BIOS en vez de UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  # WiFi: conectar post-install con `nmtui` (SSID: UP_5GHz)
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/Montevideo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };
  console.keyMap = "us-acentos";

  # Niri como window manager (binario precompilado via niri-flake cache)
  programs.niri.enable = true;

  # Login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
      user = "greeter";
    };
  };

  # Servicios necesarios para Noctalia
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Audio (pipewire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

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

  # Touchpad
  services.libinput.enable = true;

  # Laptop power & brightness
  services.thermald.enable = true;
  environment.systemPackages = with pkgs; [
    git
    brightnessctl
  ];

  # Usuario
  users.users.luciano = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" "video" "input" "networkmanager" ];
  };

  # Permitir unfree (para algunos paquetes)
  nixpkgs.config.allowUnfree = true;

  # Flakes & binary caches
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-substituters = [
    "https://noctalia.cachix.org"
    "https://claude-code.cachix.org"
    "https://niri.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  ];

  system.stateVersion = "25.05";
}
