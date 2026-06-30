-- mini.icons — uniform filetype icon set.
-- mock_nvim_web_devicons() reroutes web-devicons calls (incl. neo-tree's icon
-- provider) through mini.icons, so plugins get consistent glyphs with no changes.
return {
  'echasnovski/mini.icons',
  lazy = true,
  opts = {},
  config = function(_, opts)
    require('mini.icons').setup(opts)
    require('mini.icons').mock_nvim_web_devicons()
  end,
}
