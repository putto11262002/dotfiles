return {
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  -- 'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --init
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {},

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        astro = { 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },

  -- { -- Autocompletion
  --   'saghen/blink.cmp',
  --   event = 'VimEnter',
  --   version = '1.*',
  --   dependencies = {
  --     -- Snippet Engine
  --     {
  --       'L3MON4D3/LuaSnip',
  --       version = '2.*',
  --       build = (function()
  --         -- Build Step is needed for regex support in snippets.
  --         -- This step is not supported in many windows environments.
  --         -- Remove the below condition to re-enable on windows.
  --         if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
  --           return
  --         end
  --         return 'make install_jsregexp'
  --       end)(),
  --       dependencies = {
  --         -- `friendly-snippets` contains a variety of premade snippets.
  --         --    See the README about individual language/framework/plugin snippets:
  --         --    https://github.com/rafamadriz/friendly-snippets
  --         -- {
  --         --   'rafamadriz/friendly-snippets',
  --         --   config = function()
  --         --     require('luasnip.loaders.from_vscode').lazy_load()
  --         --   end,
  --         -- },
  --       },
  --       opts = {},
  --     },
  --     'folke/lazydev.nvim',
  --     'rafamadriz/friendly-snippets',
  --   },
  --   --- @module 'blink.cmp'
  --   --- @type blink.cmp.Config
  --   opts = {
  --     keymap = {
  --       -- 'default' (recommended) for mappings similar to built-in completions
  --       --   <c-y> to accept ([y]es) the completion.
  --       --    This will auto-import if your LSP supports it.
  --       --    This will expand snippets if the LSP sent a snippet.
  --       -- 'super-tab' for tab to accept
  --       -- 'enter' for enter to accept
  --       -- 'none' for no mappings
  --       --
  --       -- For an understanding of why the 'default' preset is recommended,
  --       -- you will need to read `:help ins-completion`
  --       --
  --       -- No, but seriously. Please read `:help ins-completion`, it is really good!
  --       --
  --       -- All presets have the following mappings:
  --       -- <tab>/<s-tab>: move to right/left of your snippet expansion
  --       -- <c-space>: Open menu or open docs if already open
  --       -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
  --       -- <c-e>: Hide menu
  --       -- <c-k>: Toggle signature help
  --       --
  --       -- See :h blink-cmp-config-keymap for defining your own keymap
  --       preset = 'default',
  --
  --       -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
  --       --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  --     },
  --
  --     appearance = {
  --       -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
  --       -- Adjusts spacing to ensure icons are aligned
  --       nerd_font_variant = 'mono',
  --     },
  --
  --     completion = {
  --       -- By default, you may press `<c-space>` to show the documentation.
  --       -- Optionally, set `auto_show = true` to show the documentation after a delay.
  --       documentation = { auto_show = true, auto_show_delay_ms = 200 },
  --     },
  --
  --     sources = {
  --       default = { 'lsp', 'path', 'snippets', 'lazydev' },
  --       providers = {
  --         lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
  --       },
  --     },
  --
  --     snippets = { preset = 'luasnip' },
  --
  --     -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
  --     -- which automatically downloads a prebuilt binary when enabled.
  --     --
  --     -- By default, we use the Lua implementation instead, but you may enable
  --     -- the rust implementation via `'prefer_rust_with_warning'`
  --     --
  --     -- See :h blink-cmp-config-fuzzy for more information
  --     fuzzy = { implementation = 'lua' },
  --
  --     -- Shows a signature help window while you type arguments for a function
  --     signature = { enabled = true },
  --   },
  -- },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'ellisonleao/gruvbox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require('gruvbox').setup {
        transparent_mode = true,
      }
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  -- {
  --   'nvim-tree/nvim-tree.lua',
  --   version = '*',
  --   lazy = false,
  --   dependencies = {
  --     'nvim-tree/nvim-web-devicons',
  --   },
  --   config = function()
  --     require('nvim-tree').setup {
  --       view = {
  --         width = 30,
  --       },
  --       renderer = {},
  --       filters = {
  --         dotfiles = false,
  --       },
  --     }
  --     -- Keymaps for nvim-tree
  --     vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = '[E]xplorer (NvimTree) Toggle', nowait = true })
  --     vim.keymap.set('n', '<leader>ef', '<cmd>NvimTreeFocus<CR>', { desc = '[E]xplorer (NvimTree) [F]ocus' })
  --     vim.keymap.set('n', '<leader>eF', '<cmd>NvimTreeFindFile<CR>', { desc = '[E]xplorer (NvimTree) [F]ind File' })
  --     vim.keymap.set('n', '<C-n>', '<cmd>NvimTreeToggle<CR>', { desc = '[E]xplorer (NvimTree) Toggle' })
  --   end,
  -- },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter').setup {
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        auto_install = true,
      }
      -- Enable treesitter-based highlighting
      vim.treesitter.start = (function(wrapped)
        return function(bufnr, lang)
          lang = lang or vim.fn.getbufvar(bufnr or 0, '&filetype')
          pcall(wrapped, bufnr, lang)
        end
      end)(vim.treesitter.start)
    end,
  },
  -- {
  --   'obsidian-nvim/obsidian.nvim',
  --   version = '*', -- recommended, use latest release instead of latest commit
  --   lazy = true,
  --   ft = 'markdown',
  --   -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  --   -- event = {
  --   --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   --   -- refer to `:h file-pattern` for more examples
  --   --   "BufReadPre path/to/my-vault/*.md",
  --   --   "BufNewFile path/to/my-vault/*.md",
  --   -- },
  --   ---@module 'obsidian'
  --   ---@type obsidian.config
  --   opts = {
  --     completion = {
  --       blink = true,
  --     },
  --     workspaces = {
  --       {
  --         name = 'notes',
  --         path = '~/notes/',
  --       },
  --     },
  --   },
  --   config = function()
  --     vim.opt_local.conceallevel = 2
  --   end,
  -- },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}
