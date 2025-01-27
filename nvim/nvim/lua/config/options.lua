-- See also, :options
local set = vim.opt

-- Tabs and indentation
-- vim-sleuth will often change these settings automatically
set.expandtab = true
set.shiftwidth = 4
set.softtabstop = -1 -- same value as shiftwidth
set.shiftround = true
set.autoindent = true

-- Colourscheme
set.termguicolors = true
set.background = 'light' -- 'light' or 'dark'

-- Set cursor to blink in insert mode
set.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-blinkon500,r-cr-o:hor20"

-- Add line numbers and sign column
set.number = true
set.hlsearch = false
set.signcolumn = 'yes'
set.scrolloff = 3
set.laststatus = 2
set.cursorline = true

-- Remove a couple types of annoying messages
set.shortmess:append('cs')

-- Default behaviour for opening new split
set.splitbelow = true
set.splitright = true

-- Wrapped lines will still obey indentation
set.wrap = false
set.breakindent = true

-- Sync clipboard between OS and Neovim.
set.clipboard = 'unnamedplus'

-- Enable mouse support
set.mouse = 'a'

-- Spelling
set.spell = false
set.spelllang = 'en_ca'

-- Case insensitive searching UNLESS /C or capital in search
set.ignorecase = true
set.smartcase = true

-- Save undo history
set.undofile = true
set.undolevels = 20000

-- Update times
set.updatetime = 2000
set.timeout = true
set.timeoutlen = 2000

-- Make K work for manual
set.keywordprg = ':help'

-- Set completeopt to have a better completion experience
set.completeopt = 'menu,menuone,noselect,preview'


--------------------------------------------------------------------------------
--- Neovim Diagnostic Options
--------------------------------------------------------------------------------


local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = ' ',
  [vim.diagnostic.severity.WARN] = ' ',
  [vim.diagnostic.severity.INFO] = ' ',
  [vim.diagnostic.severity.HINT] = ' ',

}

-- :help vim.diagnostic.Opts
vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = {
    text = diagnostic_signs,
  },
  float = {
    prefix = function(diagnostic, i, _) return i .. ". [" .. diagnostic.source .. "] ", "" end,
    border = "double",
  },
  update_in_insert = false,
  severity_sort = true,
})

-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
