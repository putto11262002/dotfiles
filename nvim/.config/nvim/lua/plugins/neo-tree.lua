return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  lazy = false, -- neo-tree will lazily load itself
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      filtered_items = {
        visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      -- filtered_items = {
      --   hide_dotfiles = false,
      --   visible = true,
      --   -- hide_gitignored = false,
      --   -- hide_by_name = {
      --   --   '.git',
      --   --   'node_modules',
      --   --   'dist',
      --   --   'build',
      --   --   'vendor',
      --   --   'target',
      --   --   'coverage',
      --   --   'vendor',
      --   -- },
      -- },
    },
    default_component_configs = {
      icon = {
        folder_closed = '',
        folder_open = '',
        folder_empty = '󰜌',
        provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
          if node.type == 'file' or node.type == 'terminal' then
            local success, web_devicons = pcall(require, 'nvim-web-devicons')
            local name = node.type == 'terminal' and 'terminal' or node.name
            if success then
              local devicon, hl = web_devicons.get_icon(name)
              icon.text = devicon or icon.text
              icon.highlight = hl or icon.highlight
            end
          end
        end,
        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
        -- then these will never be used.
        default = '*',
        highlight = 'NeoTreeFileIcon',
      },
    },
  },
  config = function()
    neo_tree_command = require 'neo-tree.command'
    vim.keymap.set('n', '<leader>ef', function()
      neo_tree_command.execute {
        action = 'focus',
        source = 'filesystem',
        position = 'left',
        reveal = true,
        toggle = true,
        dir = vim.fn.getcwd(),
      }
    end, { desc = '[E]xplorer [F]iles' })
    vim.keymap.set('n', '<leader>ec', function()
      neo_tree_command.execute {
        action = 'focus',
        source = 'filesystem',
        position = 'float',
        reveal = true,
        toggle = true,
        dir = vim.fn.stdpath 'config',
      }
    end, { desc = '[E]xplorer [C]onfig' })
  end,
}
