{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
  ];

  # Home Manager settings
  home = {
    username = "putsuthisrisinlpa";
    homeDirectory = "/Users/putsuthisrisinlpa";
    stateVersion = "24.05";

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG directories
  xdg.enable = true;
}
