{ config, pkgs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Let Lazy.nvim manage plugins (your kickstart config uses Lazy)
    # Nix just provides Neovim + dependencies
  };

  # Symlink config files from dotfiles/config/
  xdg.configFile = {
    # Neovim - symlink the entire config directory
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";

    # Aerospace - symlink the config file
    "aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/aerospace.toml";
  };

  # Also symlink .aerospace.toml to home directory (aerospace looks there too)
  home.file.".aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/aerospace.toml";
}
