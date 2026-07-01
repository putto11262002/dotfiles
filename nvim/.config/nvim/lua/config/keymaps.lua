-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Buffer Management Keymaps ]]
-- Refined buffer operations with your specifications

-- List all buffers with telescope
vim.keymap.set('n', '<leader>bb', '<cmd>Telescope buffers<cr>', { desc = '[B]uffers [B]rowse' })

-- Close current buffer (without closing window)
-- vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bd', ':bp<bar>sp<bar>bn<bar>bd<CR>', { noremap = true, silent = true, desc = '[B]uffer [D]elete' })

-- Close all buffers except current
vim.keymap.set('n', '<leader>bo', '<cmd>%bdelete|edit#|bdelete#<cr>', { desc = '[B]uffer [O]thers' })

-- Close all buffers to the right of current
vim.keymap.set('n', '<leader>br', '<cmd>+,$bdelete<cr>', { desc = '[B]uffer [R]ight' })

-- Close all buffers to the left of current
vim.keymap.set('n', '<leader>bl', '<cmd>1,-bdelete<cr>', { desc = '[B]uffer [L]eft' })

-- Move to next buffer
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<C-n>', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })

-- Move to previous buffer
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<C-p>', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]revious' })

-- Save current buffer (updated as requested)
vim.keymap.set('n', '<leader>bw', '<cmd>write<cr>', { desc = '[B]uffer [W]rite' })
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Buffer [W]rite' })

-- Save all buffers (updated as requested)
vim.keymap.set('n', '<leader>aw', '<cmd>wall<cr>', { desc = '[A]ll [W]rite' })

-- Force close buffer (discard changes)
vim.keymap.set('n', '<leader>bD', '<cmd>bdelete!<cr>', { desc = '[B]uffer [D]elete force' })
