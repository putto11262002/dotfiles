-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-reload buffers when the file changes on disk (git pull, format-on-save from another tool, etc.)
vim.o.autoread = true
local autoread_group = vim.api.nvim_create_augroup('auto-reload', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  desc = 'Check if the file changed on disk and reload',
  group = autoread_group,
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.bo.buftype == '' then
      vim.cmd 'checktime'
    end
  end,
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  desc = 'Notify when a buffer was reloaded from disk',
  group = autoread_group,
  callback = function()
    vim.notify('File changed on disk — buffer reloaded', vim.log.levels.WARN)
  end,
})
