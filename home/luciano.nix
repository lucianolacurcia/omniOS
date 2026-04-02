{ pkgs, nixvim, noctalia, claude-code, ... }:

{
  imports = [
    nixvim.homeModules.nixvim
    noctalia.homeModules.default
  ];

  home.username = "luciano";
  home.homeDirectory = "/home/luciano";

  # Paquetes de usuario
  home.packages = with pkgs; [
    tmux
    sioyek
    musescore
    alacritty
    claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Firefox (gestionado a nivel sistema en configuration.nix)

  # Noctalia shell
  programs.noctalia-shell.enable = true;

  # Neovim via nixvim
  programs.nixvim = {
    enable = true;
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      clipboard = "unnamedplus";
    };
  };

  # Git
  programs.git = {
    enable = true;
    settings.user.name = "Luciano Lacurcia";
    settings.user.email = "lucho.lacurcia@gmail.com";
  };

  # Default browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "application/pdf" = "sioyek.desktop";
    };
  };

  home.stateVersion = "25.05";
}
