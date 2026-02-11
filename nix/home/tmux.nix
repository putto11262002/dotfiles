{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-b";
    baseIndex = 1;
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      nord
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];

    extraConfig = ''
      # Vi-style status keys
      set -g status-keys vi

      # Window/tab names: show current directory basename
      set -g allow-rename off
      set -g automatic-rename on
      set -g automatic-rename-format "#{b:pane_current_path}"

      # New windows/panes open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Move windows left/right
      bind-key -n S-Left swap-window -t -1\; select-window -t -1
      bind-key -n S-Right swap-window -t +1\; select-window -t +1

      # Nord theme (no patched font)
      set -g @nord_tmux_no_patched_font "1"

      # True color support
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
