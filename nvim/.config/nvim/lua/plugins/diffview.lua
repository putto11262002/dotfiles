-- diffview.nvim — diff + merge browser, file-history panel, branch compare.
-- Reads diffs (lazygit handles actions). Open with :DiffviewOpen (current changes)
-- or :DiffviewFileHistory.
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [d]iffview: open (unstaged)' },
    { '<leader>gD', '<cmd>DiffviewClose<cr>', desc = '[G]it [d]iffview: close' },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it [f]ile history (current file)' },
    { '<leader>gF', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it [F]ile history (repo)' },
    { '<leader>gtf', '<cmd>DiffviewToggleFiles<cr>', desc = '[G]it [t]oggle [f]ile panel' },
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    enhanced_diff_hl = true, -- word-level diff highlights
  },
}
