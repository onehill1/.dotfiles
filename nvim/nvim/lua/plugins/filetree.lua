-- Neotree: https://github.com/nvim-neo-tree/neo-tree.nvim

-- For all defaults for neo-tree, see
-- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/lua/neo-tree/defaults.lua

local function nnoremap(input, output, options)
  vim.keymap.set('n', input, output, options)
end


local opts = {
  use_default_mappings = false,
  close_if_last_window = true,
  enable_diagnostics = false,

  sources = {
    "filesystem",
    "buffers",
    "git_status",
    -- "document_symbols",
  },

  window = {
    position = "right",
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ["?"] = "show_help",
      ["<cr>"] = "open",
      ["q"] = "close_window",
      ["<esc>"] = "close_window",
      ["P"] = { "toggle_preview", config = { use_float = false } },
      ["h"] = function(state)
        local node = state.tree:get_node()
        local is_root = node:get_id() == state.tree:get_nodes()[1]:get_id()
        if is_root and not node:is_expanded() and state.commands.navigate_up then
          state.commands.navigate_up(state)
        elseif (node.type == "directory" or node:has_children()) and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          state.commands.close_node(state)
        end
      end,
      ["l"] = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" or node:has_children() then
          if not node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state,
              node:get_child_ids()[1])
          end
        else
          require("neo-tree.sources.filesystem.commands").open(state)
        end
      end,
      ["w"] = "open_with_window_picker",
      ["S"] = "split_with_window_picker",  -- ["S"] = "open_split"
      ["s"] = "vsplit_with_window_picker", -- ["s"] = "open_vsplit"
      ["t"] = "open_tabnew",
      ['c'] = 'close_all_subnodes',
      ["z"] = "close_all_nodes", -- ["z"] = "close_all_nodes  -- bugged, doesn't obey `nowait`.
      ["Z"] = "expand_all_nodes",
      ["a"] = {
        "add",
        config = { show_path = "relative" } -- "none", "relative", "absolute"
      },
      ["n"] = "add_directory",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["m"] = "move",
      ["R"] = "refresh",
      ["i"] = { "show_file_details", nowait = true },
      ["<"] = "prev_source",
      [">"] = "next_source",
    }
  },

  filesystem = {
    filtered_items = {
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_hidden = true, -- only works on Windows for hidden files/directories
      hide_by_name = {
        "lazy-lock.json",
        "__pycache__",
      },
      hide_by_pattern = {},
      always_show = { -- remains visible even if other settings would normally hide it
        ".gitignore",
        ".dockerignore",
        ".env",
        ".env.example",
        ".env.production",
      },
      never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
        ".DS_Store",
        "__pycache__"
      },
      never_show_by_pattern = {},
    },
    hijack_netrw_behavior = "open_default",
    window = {
      mappings = {
        ["."] = "set_root",
        ["o"] = "set_root",
        ["!"] = "toggle_hidden",
        ["/"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
      },
      fuzzy_finder_mappings = {
        ["<down>"] = "move_cursor_down",
        ["<C-n>"] = "move_cursor_down",
        ["<up>"] = "move_cursor_up",
        ["<C-p>"] = "move_cursor_up",
      },
    }
  },

  git_status = {
    window = {
      mappings = {
        ["A"]  = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      }
    }
  },

  event_handlers = {
    { -- Close neo-tree after a file is opened
      event = "file_opened",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end
    },
  },
}


local setup = function(_, opts)
  nnoremap('<leader>e', "<cmd>Neotree toggle<cr>", { desc = "[e]xplorer toggle (cwd)", silent = true })
  nnoremap('<leader>E', "<cmd>Neotree position=current toggle<cr>",
    { desc = "[E]xplorer toggle (current window)", silent = true })
  nnoremap('<leader>be', "<cmd>Neotree source=buffers toggle<cr>", { desc = "[b]uffer [e]xplorer", silent = true })
  nnoremap('<leader>bE', "<cmd>Neotree source=buffers position=current toggle<cr>",
    { desc = "[b]uffer [E]xplorer (current window)", silent = true })
  nnoremap('<leader>ge', "<cmd>Neotree source=git_status toggle<cr>", { desc = "[g]it [e]xplorer", silent = true, })
  nnoremap('<leader>gE', "<cmd>Neotree source=git_status position=current toggle<cr>",
    { desc = "[g]it [E]xplorer (current window)", silent = true, })

  nnoremap('<leader>vd', '<cmd>cd ~/.dotfiles<cr><cmd>Neotree position=current<cr>')


  -- See https://github.com/folke/snacks.nvim/blob/main/docs/rename.md
  local snacks = require("snacks")

  local function on_move(data)
    snacks.rename.on_rename_file(data.source, data.destination)
  end
  local events = require("neo-tree.events")
  opts.event_handlers = opts.event_handlers or {}
  vim.list_extend(opts.event_handlers, {
    { event = events.FILE_MOVED,   handler = on_move },
    { event = events.FILE_RENAMED, handler = on_move },
  })

  require("neo-tree").setup(opts)
end


-- https://github.com/s1n7ax/nvim-window-picker

local wp_opts = {
  hint = 'floating-big-letter',
  filter_rules = {
    include_current_win = false,
    autoselect_one = true,
    bo = {
      filetype = { 'neo-tree', "neo-tree-popup", "notify" },
      buftype = { 'terminal', "quickfix" },
    },
  },
}


return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "main",
  dependencies = {
    "folke/snacks.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      's1n7ax/nvim-window-picker',
      opts = wp_opts,
    },
  },
  opts = opts,
  config = setup,
  cond = true,
}
