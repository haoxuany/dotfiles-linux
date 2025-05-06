-- Settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Colorscheme
    {
      "catppuccin/nvim",
      lazy = false,
      priority = 1000,
      opts = {
        flavour = 'macchiato',
      },
      config = function()
        vim.cmd.colorscheme "catppuccin"
      end
    },
    -- Find files
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' , 'nvim-telescope/telescope-fzf-native.nvim' },
      keys = {
        { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
        -- TODO replace grep stuff
      },
      config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            mappings =  {
              i = {
                ["<C-u>"] = false,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-d>"] = actions.delete_buffer + actions.move_to_bottom,
		["<Esc>"] = actions.close,
              },
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = 'smart_case',
            },
          },
        })
      end
    },
    -- Parser
    {
      'nvim-treesitter/nvim-treesitter',
      opts = {
        ensure_installed = {
          "c", "lua", "vim", "vimdoc",
          "markdown",
          "agda", "ocaml", "haskell",
          "latex", "bibtex",
          "json", "bash", "fish", "html", "yaml",
        },
        highlight = {
          enable = true,
        },
      },
    },
    -- tpope
    {
      'tpope/vim-sleuth',
    },
    {
      'tpope/vim-surround',
    },
    {
      'tpope/vim-commentary',
    },
    {
      'tpope/vim-unimpaired',
    },
    -- Status line (for border contrast lel)
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        icons_enabled = true,
        theme = 'bubbles',
      },
    },
    -- LSP Data
    -- {
    --   'neovim/nvim-lspconfig', tag = 'v1.8.0',
    -- },
  },
  -- Configure any other settings here. See the documentation for more details.
  install = {
    colorscheme = { "catppuccin" },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
