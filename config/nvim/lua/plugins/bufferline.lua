return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- Required for bufferline.nvim to work
    vim.opt.termguicolors = true
    require('bufferline').setup {
      options = {
        numbers = function(opts)
          return string.format('%s', opts.ordinal)
        end,
      },
    }
  end,
}
