{ pkgs, config, nixvim, noctalia, claude-code, nur, ... }:

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

  # Firefox con extensiones
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      extensions.packages = with nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons; [
        ublock-origin
      ];
    };
  };

  # Noctalia shell (Wayland desktop shell - bar, widgets, notifications)
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;  # Auto-start via systemd user service
  };

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

  # Niri window manager (declarative config via niri-flake)
  programs.niri.settings = let
    actions = config.lib.niri.actions;
  in {
    input = {
      keyboard.xkb = {};
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
    };

    layout = {
      gaps = 16;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 1.0 / 3; }
        { proportion = 1.0 / 2; }
        { proportion = 2.0 / 3; }
      ];
      default-column-width.proportion = 0.5;
      focus-ring = {
        width = 4;
        active.color = "#7fc8ff";
        inactive.color = "#505050";
      };
    };

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    binds = {
      "Mod+Shift+Slash".action = actions.show-hotkey-overlay;

      # Applications
      "Mod+T".action.spawn = "alacritty";
      "Mod+D".action.spawn = ["noctalia-shell" "ipc" "call" "launcher" "toggle"];
      "Super+Alt+L".action.spawn = "swaylock";

      # Screen reader toggle
      "Super+Alt+S" = {
        allow-when-locked = true;
        action.spawn-sh = "pkill orca || exec orca";
      };

      # Volume
      "XF86AudioRaiseVolume" = { allow-when-locked = true; action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"]; };
      "XF86AudioLowerVolume" = { allow-when-locked = true; action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"]; };
      "XF86AudioMute"        = { allow-when-locked = true; action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
      "XF86AudioMicMute"     = { allow-when-locked = true; action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };

      # Brightness
      "XF86MonBrightnessUp"   = { allow-when-locked = true; action.spawn = ["brightnessctl" "--class=backlight" "set" "+10%"]; };
      "XF86MonBrightnessDown" = { allow-when-locked = true; action.spawn = ["brightnessctl" "--class=backlight" "set" "10%-"]; };

      # Overview
      "Mod+O" = { repeat = false; action = actions.toggle-overview; };

      # Window management
      "Mod+Q" = { repeat = false; action = actions.close-window; };

      "Mod+Left".action  = actions.focus-column-left;
      "Mod+Down".action  = actions.focus-window-down;
      "Mod+Up".action    = actions.focus-window-up;
      "Mod+Right".action = actions.focus-column-right;
      "Mod+H".action     = actions.focus-column-left;
      "Mod+J".action     = actions.focus-window-down;
      "Mod+K".action     = actions.focus-window-up;
      "Mod+L".action     = actions.focus-column-right;

      "Mod+Ctrl+Left".action  = actions.move-column-left;
      "Mod+Ctrl+Down".action  = actions.move-window-down;
      "Mod+Ctrl+Up".action    = actions.move-window-up;
      "Mod+Ctrl+Right".action = actions.move-column-right;
      "Mod+Ctrl+H".action     = actions.move-column-left;
      "Mod+Ctrl+J".action     = actions.move-window-down;
      "Mod+Ctrl+K".action     = actions.move-window-up;
      "Mod+Ctrl+L".action     = actions.move-column-right;

      "Mod+Home".action      = actions.focus-column-first;
      "Mod+End".action       = actions.focus-column-last;
      "Mod+Ctrl+Home".action = actions.move-column-to-first;
      "Mod+Ctrl+End".action  = actions.move-column-to-last;

      # Monitor focus
      "Mod+Shift+Left".action  = actions.focus-monitor-left;
      "Mod+Shift+Down".action  = actions.focus-monitor-down;
      "Mod+Shift+Up".action    = actions.focus-monitor-up;
      "Mod+Shift+Right".action = actions.focus-monitor-right;
      "Mod+Shift+H".action     = actions.focus-monitor-left;
      "Mod+Shift+J".action     = actions.focus-monitor-down;
      "Mod+Shift+K".action     = actions.focus-monitor-up;
      "Mod+Shift+L".action     = actions.focus-monitor-right;

      # Move to monitor
      "Mod+Shift+Ctrl+Left".action  = actions.move-column-to-monitor-left;
      "Mod+Shift+Ctrl+Down".action  = actions.move-column-to-monitor-down;
      "Mod+Shift+Ctrl+Up".action    = actions.move-column-to-monitor-up;
      "Mod+Shift+Ctrl+Right".action = actions.move-column-to-monitor-right;
      "Mod+Shift+Ctrl+H".action     = actions.move-column-to-monitor-left;
      "Mod+Shift+Ctrl+J".action     = actions.move-column-to-monitor-down;
      "Mod+Shift+Ctrl+K".action     = actions.move-column-to-monitor-up;
      "Mod+Shift+Ctrl+L".action     = actions.move-column-to-monitor-right;

      # Columns by index (Mod+number = focus column, Mod+Ctrl+number = move to column)
      "Mod+1".action = actions.focus-column 1;
      "Mod+2".action = actions.focus-column 2;
      "Mod+3".action = actions.focus-column 3;
      "Mod+4".action = actions.focus-column 4;
      "Mod+5".action = actions.focus-column 5;
      "Mod+6".action = actions.focus-column 6;
      "Mod+7".action = actions.focus-column 7;
      "Mod+8".action = actions.focus-column 8;
      "Mod+9".action = actions.focus-column 9;
      "Mod+Ctrl+1".action = actions.move-column-to-index 1;
      "Mod+Ctrl+2".action = actions.move-column-to-index 2;
      "Mod+Ctrl+3".action = actions.move-column-to-index 3;
      "Mod+Ctrl+4".action = actions.move-column-to-index 4;
      "Mod+Ctrl+5".action = actions.move-column-to-index 5;
      "Mod+Ctrl+6".action = actions.move-column-to-index 6;
      "Mod+Ctrl+7".action = actions.move-column-to-index 7;
      "Mod+Ctrl+8".action = actions.move-column-to-index 8;
      "Mod+Ctrl+9".action = actions.move-column-to-index 9;

      # Workspaces
      "Mod+Page_Down".action      = actions.focus-workspace-down;
      "Mod+Page_Up".action        = actions.focus-workspace-up;
      "Mod+U".action              = actions.focus-workspace-down;
      "Mod+I".action              = actions.focus-workspace-up;
      "Mod+Ctrl+Page_Down".action = actions.move-column-to-workspace-down;
      "Mod+Ctrl+Page_Up".action   = actions.move-column-to-workspace-up;
      "Mod+Ctrl+U".action         = actions.move-column-to-workspace-down;
      "Mod+Ctrl+I".action         = actions.move-column-to-workspace-up;

      "Mod+Shift+Page_Down".action = actions.move-workspace-down;
      "Mod+Shift+Page_Up".action   = actions.move-workspace-up;
      "Mod+Shift+U".action         = actions.move-workspace-down;
      "Mod+Shift+I".action         = actions.move-workspace-up;

      # Scroll workspaces
      "Mod+WheelScrollDown"      = { cooldown-ms = 150; action = actions.focus-workspace-down; };
      "Mod+WheelScrollUp"        = { cooldown-ms = 150; action = actions.focus-workspace-up; };
      "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action = actions.move-column-to-workspace-down; };
      "Mod+Ctrl+WheelScrollUp"   = { cooldown-ms = 150; action = actions.move-column-to-workspace-up; };

      "Mod+WheelScrollRight".action      = actions.focus-column-right;
      "Mod+WheelScrollLeft".action       = actions.focus-column-left;
      "Mod+Ctrl+WheelScrollRight".action = actions.move-column-right;
      "Mod+Ctrl+WheelScrollLeft".action  = actions.move-column-left;

      "Mod+Shift+WheelScrollDown".action      = actions.focus-column-right;
      "Mod+Shift+WheelScrollUp".action        = actions.focus-column-left;
      "Mod+Ctrl+Shift+WheelScrollDown".action = actions.move-column-right;
      "Mod+Ctrl+Shift+WheelScrollUp".action   = actions.move-column-left;

      # Column/window layout
      "Mod+BracketLeft".action  = actions.consume-or-expel-window-left;
      "Mod+BracketRight".action = actions.consume-or-expel-window-right;
      "Mod+Comma".action  = actions.consume-window-into-column;
      "Mod+Period".action = actions.expel-window-from-column;

      "Mod+R".action       = actions.switch-preset-column-width;
      "Mod+Shift+R".action = actions.switch-preset-window-height;
      "Mod+Ctrl+R".action  = actions.reset-window-height;
      "Mod+F".action       = actions.maximize-column;
      "Mod+Shift+F".action = actions.fullscreen-window;
      "Mod+Ctrl+F".action  = actions.expand-column-to-available-width;
      "Mod+C".action       = actions.center-column;
      "Mod+Ctrl+C".action  = actions.center-visible-columns;

      # Resize
      "Mod+Minus".action       = actions.set-column-width "-10%";
      "Mod+Equal".action       = actions.set-column-width "+10%";
      "Mod+Shift+Minus".action = actions.set-window-height "-10%";
      "Mod+Shift+Equal".action = actions.set-window-height "+10%";

      # Floating
      "Mod+V".action       = actions.toggle-window-floating;
      "Mod+Shift+V".action = actions.switch-focus-between-floating-and-tiling;

      # Tabs
      "Mod+W".action = actions.toggle-column-tabbed-display;

      # Screenshots
      "Print".action.screenshot = {};
      "Ctrl+Print".action.screenshot-screen = {};
      "Alt+Print".action.screenshot-window = {};

      # Session
      "Mod+Escape" = { allow-inhibiting = false; action = actions.toggle-keyboard-shortcuts-inhibit; };
      "Mod+Shift+E".action = actions.quit;
      "Ctrl+Alt+Delete".action = actions.quit;
      "Mod+Shift+P".action = actions.power-off-monitors;
    };

    window-rules = [
      {
        matches = [{ app-id = "^org\\.wezfurlong\\.wezterm$"; }];
        default-column-width = {};
      }
      {
        matches = [{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }];
        open-floating = true;
      }
    ];
  };

  home.stateVersion = "25.05";
}
