-- Settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Ignore cases
vim.o.ignorecase = true
vim.o.smartcase = true
-- don't highlight
vim.o.hlsearch = false
-- persistent undos
vim.o.undofile = true
-- Number
vim.o.number = true
-- No mouse
vim.o.mouse = ''
-- Mouse support for resizing is completely broken since neovim unfortunately
-- Splits
vim.o.splitbelow = true
vim.o.splitright = true
-- 80 columns
vim.o.colorcolumn = '80'
-- no screwing with buffers
vim.o.switchbuf = 'useopen' -- is "uselast" also correct?
-- wildmode completion
vim.o.wildmode = 'list:longest'
-- ignore junk
vim.o.wildignore =
table.concat({
  '*.o,*.a,**/.git/*,**/.scm/*,*~,*.pyc,*.out,*.tar,*.gz',
  '*.jpg,*.png,*.gif,*.pdf,*.swp,**/.hg/*,**/_build/*,**/.cm/*',
  '.merlin,setup.data,setup.log,**/node_modules/*,*.cmi,*.cmo,*.cmj,*.cmt',
}, ',')
-- leave 1 line
vim.o.scrolloff = 1
-- no folds
vim.o.foldmethod = 'manual'
vim.o.foldenable = false
-- Default indentation
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

-- Keymaps
-- infinite repeat
vim.keymap.set('n', '1', '11111')
-- shift keyboard commands
vim.keymap.set('n', '2', '@')
vim.keymap.set('n', '3', '#')
vim.keymap.set('n', '4', '$')
vim.keymap.set('n', '5', '%')
vim.keymap.set('n', '6', '^')
vim.keymap.set('n', '8', '*')
-- Quick insert blank line
vim.keymap.set('n', '<C-j>', 'o<Esc>S<Esc>k')
vim.keymap.set('n', '<C-k>', 'O<Esc>S<Esc>j')
-- Sane mappings for window width
vim.keymap.set('n', '<C-h>', '<C-w><')
vim.keymap.set('n', '<C-l>', '<C-w>>')
-- Command line mode recall ergonomics
vim.keymap.set('c', '<C-j>', '<C-n>')
vim.keymap.set('c', '<C-k>', '<C-p>')
-- Stop arrow keys to avoid breaking repeat behavior
vim.keymap.set('', '<Up>', "<Cmd>echo 'Nope'<CR>")
vim.keymap.set('', '<Down>', "<Cmd>echo 'Nope'<CR>")
vim.keymap.set('', '<Left>', "<Cmd>echo 'Nope'<CR>")
vim.keymap.set('', '<Right>', "<Cmd>echo 'Nope'<CR>")
-- Visual search
vim.keymap.set('x', '8', '*', { remap = true });
vim.keymap.set('x', '3', '#', { remap = true });
-- Clear/Redraw screen
vim.keymap.set('n', '<leader>l', '<C-l>');
vim.keymap.set('n', '<leader><leader>', '<C-^>');
-- + register for interfacing
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y');
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p');
-- Quickfix List
vim.keymap.set('n', '<leader>q',
function()
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      vim.cmd "cclose"
      return
    end
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd "copen"
  end
end);
vim.keymap.set('n', '<leader>j', '<Cmd>cnext<CR>');
vim.keymap.set('n', '<leader>k', '<Cmd>cprev<CR>');
-- Split windows
vim.keymap.set('n', '<leader>v', '<Cmd>vnew<CR>');
vim.keymap.set('n', '<leader>w', '<Cmd>new<CR>');
-- %% curdir magic
vim.keymap.set('c', '%%',
  "getcmdtype() == ':' ? expand('%:h').'/' : '%%'",
  { expr = true }
);


-- Plugins
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable", lazyrepo, lazypath 
  })
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
    { 
      'nvim-telescope/telescope-fzf-native.nvim',
      lazy = false,
      build = 'make'
     },
    {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-fzf-native.nvim'
      },
      keys = {
        { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
        -- TODO replace grep stuff
      },
      config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            -- Rely on ripgrep to do ignores, saner
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
        indent = {
          enable = true,
        },
      },
    },
    -- New Quickfix
    {
      'kevinhwang91/nvim-bqf',
      lazy = false,
      opts = {
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
    -- Completion
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/vim-vsnip',
        'hrsh7th/cmp-vsnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
      },
      config = function()
        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local feedkey = function(key, mode)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
        end

        local cmp = require('cmp')
        cmp.setup({
          snippet = {
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            end,
          },
          mapping = {
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
              elseif has_words_before() then
                cmp.complete()
              else
                fallback() -- The fallback function sends a already mapped key.
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_prev_item()
              elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
              end
            end, { "i", "s" }),
            -- Insert mode completion ergonomics
            ['<C-j>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { "i", "s" }),
            ['<C-n>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { "i", "s" }),
            ['<C-k>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { "i", "s" }),
            ['<C-p>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { "i", "s" }),
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
          }, {
            { name = 'buffer' },
          })
        })
      end
    },
    -- Language Specific
    -- LSP Data
    {
      'neovim/nvim-lspconfig', tag = 'v2.1.0',
      config = function()
        vim.lsp.enable('texlab')
        vim.lsp.enable('coq-lsp') -- Integration is super cursed at the moment
      end
    },

    -- LaTeX
    {
      "lervag/vimtex",
      lazy = false,
      tag = "v2.15",
      init = function()
        vim.g.vimtex_view_method = "zathura"
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "tex",
          callback = function(event)
            vim.keymap.set("n", "<Leader>m",
            "<Plug>(vimtex-compile)",
            { buffer = event.buf })
          end,
        })
      end
    },
    -- Coq
    {
      "whonore/Coqtail",
      init = function()
        vim.g.coqtail_nomap = 1
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "coq",
          callback = function(event)
            vim.keymap.set("n", "<C-c>",
            "<Plug>CoqInterrupt",
            { buffer = event.buf })

            vim.keymap.set("n", "<Leader>j",
            "<Plug>CoqNext",
            { buffer = event.buf })

            vim.keymap.set("n", "<Leader>k",
            "<Plug>CoqUndo",
            { buffer = event.buf })

            vim.keymap.set("n", "<Leader>l",
            "<Plug>CoqToLine",
            { buffer = event.buf })

            vim.keymap.set("n", "[g",
            "<Plug>CoqGotoGoalPrevStart",
            { buffer = event.buf })

            vim.keymap.set("n", "]g",
            "<Plug>CoqGotoGoalNextStart",
            { buffer = event.buf })

            vim.keymap.set("n", "<Leader>c",
            "<Plug>CoqCheck",
            { buffer = event.buf })

            vim.keymap.set("n", "<Leader>p",
            "<Plug>CoqPrint",
            { buffer = event.buf })
          end,
        })
      end
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  install = {
    colorscheme = { "catppuccin" },
  },
  -- Do not notification spam.
  checker = { enabled = false },
})
