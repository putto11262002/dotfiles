-- octo.nvim — GitHub PRs / issues / reviews inside nvim.
-- Requires the `gh` CLI installed and authed (`gh auth login`).
return {
  'pwntester/octo.nvim',
  cmd = { 'Octo' },
  keys = {
    { '<leader>go', '<cmd>Octo<cr>', desc = '[G]it [o]cto: menu' },
    { '<leader>gpr', '<cmd>Octo pr list<cr>', desc = '[G]it [pr] list' },
    { '<leader>gprc', '<cmd>Octo pr create<cr>', desc = '[G]it [pr] create' },
    { '<leader>gprv', '<cmd>Octo review start<cr>', desc = '[G]it [pr] review start' },
    { '<leader>gis', '<cmd>Octo issue list<cr>', desc = '[G]it [is]sue list' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    picker = 'telescope', -- you have telescope installed
    enable_builtin = true, -- bare :Octo opens a command picker
    default_merge_method = 'squash',
  },
}
