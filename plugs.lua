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

require('lazy').setup({
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    }
  },
  'neovim/nvim-lspconfig',
  'williamboman/mason-lspconfig.nvim',
  'williamboman/mason.nvim',
  'nvim-treesitter/nvim-treesitter',
  'navarasu/onedark.nvim',

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  'onsails/lspkind.nvim',
  'nvim-lualine/lualine.nvim',
  'HiPhish/nvim-ts-rainbow2',

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end
  },

  'nvimdev/lspsaga.nvim',
  { "catppuccin/nvim", name = "catppuccin" },
  { "folke/tokyonight.nvim", lazy = false },
  { "Shatur/neovim-ayu", lazy = false },
  { "dasupradyumna/midnight.nvim", lazy = false },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  }
})

-- neo-tree
require('neo-tree').setup({
  window = {
    width = 30,
  },
})

-- all lsp related

local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local lspconfig = require('lspconfig')
local luasnip = require('luasnip')

mason.setup()
mason_lspconfig.setup()

local function lspKeybind(mapbuf)
  local opt = { silent = true, noremap = true }

  -- mapbuf('n', '<leader>rn', ':lua vim.lsp.buf.rename()<cr>', opt)
  -- mapbuf('n', '<leader>qf', ':lua vim.lsp.buf.code_action()<cr>', opt)
  -- mapbuf('n', 'gd', ':lua vim.lsp.buf.definition()<cr>', opt)
  -- mapbuf('n', 'gD', ':lua vim.lsp.buf.declaration()<cr>', opt)
  -- mapbuf('n', 'gy', ':lua vim.lsp.buf.type_definition()<cr>', opt)
  -- mapbuf('n', 'gi', ':lua vim.lsp.buf.implementation()<cr>', opt)
  -- mapbuf('n', 'K', ':lua vim.lsp.buf.hover()<cr>', opt)
  mapbuf('n', '<leader>e', 'lua vim.lsp.diagnostic.show_line_diagnostics()', opt)
  mapbuf('n', '<leader>ft', ':lua vim.lsp.buf.format { async = true }<cr>', opt)
  mapbuf("n", "gf", ":Lspsaga finder<CR>", opt)
  mapbuf("n", "<leader>ca", ":Lspsaga code_action<CR>", opt)
  mapbuf("n", "<leader>qf", ":Lspsaga code_action<CR>", opt)
  mapbuf('n', 'K', ':Lspsaga hover_doc<cr>', opt)
  mapbuf('n', 'gpd', ':Lspsaga peek_definition<cr>', opt)
  mapbuf('n', 'gpy', ':Lspsaga peek_type_definition<cr>', opt)
  mapbuf('n', 'gd', ':Lspsaga goto_definition<cr>', opt)
  mapbuf('n', 'gy', ':Lspsaga goto_type_definition<cr>', opt)
  mapbuf('n', '[g', ':Lspsaga diagnostic_jump_prev<cr>', opt)
  mapbuf('n', ']g', ':Lspsaga diagnostic_jump_next<cr>', opt)
  mapbuf('n', '<leader>ol', ':Lspsaga outline<cr>', opt)
  mapbuf('n', '<leader>rn', ':Lspsaga rename<cr>', opt)
end

local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<M-b>'] = cmp.mapping.scroll_docs(-4),
    ['<M-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-.>'] = cmp.mapping.complete(),
    ['<M-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(
    function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(
    function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
    { "i", "s" })
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})
require("cmp_git").setup() ]]-- 

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspsetupopt = {
  on_attach = function(_, bufnr)
    lspKeybind(function(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end)
  end,
  capabilities = capabilities,
}

lspconfig.clangd.setup(lspsetupopt)
lspconfig.pyright.setup(lspsetupopt)
lspconfig.vimls.setup(lspsetupopt)
lspconfig.lua_ls.setup(lspsetupopt)

local lspkind = require('lspkind')
cmp.setup {
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = {
        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- can also be a function to dynamically calculate max width such as
        -- menu = function() return math.floor(0.45 * vim.o.columns) end,
        menu = 50, -- leading text (labelDetails)
        abbr = 50, -- actual suggestion item
      },
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function (_, vim_item)
        -- ...
        return vim_item
      end
    })
  }
}

-- lspsaga
require('lspsaga').setup()

-- nvim-treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'c', 'cpp', 'python', 'vim', 'lua', 'markdown', 'vimdoc', },
  auto_install = true,

  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<cr>',
      node_incremental = '<cr>',
      scope_incremental = '<tab>',
      node_decremental = '<bs>',
    },
  },
  indent = {
    enable = false,
  },
}

-- one-dark
require('onedark').setup{}

-- lualine
require('lualine').setup{}

-- catppuccin
require('catppuccin').setup()

-- tokyonight
require('tokyonight').setup()

vim.diagnostic.config({ virtual_text = false, })
