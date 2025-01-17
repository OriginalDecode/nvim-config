-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo(
      {
        {"Failed to clone lazy.nvim:\n", "ErrorMsg"},
        {out, "WarningMsg"},
        {"\nPress any key to exit..."}
      },
      true,
      {}
    )
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- theme
    {
        "catppuccin/nvim", 
        name = "catpuccin", 
        priority = 1000
    },
  "nvim-lualine/lualine.nvim",
  "kyazdani42/nvim-web-devicons",
  "ctrlpvim/ctrlp.vim",
  
  "ahmedkhalf/project.nvim",
  "romgrk/barbar.nvim",
  "akinsho/bufferline.nvim",
  "ibhagwan/fzf-lua",
  "yuki-yano/fzf-preview.vim",
  "nvim-lua/plenary.nvim", -- required for telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    keys = {
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end
        },
      }
    },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = {enabled = true},
      dashboard = {
        sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            { section = "startup" },
        }
      },
      picker = {enabled = true},
      indent = {enabled = true},
      input = {enabled = true},
      notifier = {
        enabled = true,
        timeout = 3000
      },
      quickfile = {enabled = true},
      scroll = {enabled = true},
      statuscolumn = {enabled = true},
      words = {enabled = true},
      styles = {
        notification = {}
      }
    },
    keys = {
      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode"
      },
      {
        "<leader>Z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom"
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer"
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer"
      },
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History"
      },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer"
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File"
      },
      {
        "<leader>gB",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Browse",
        mode = {"n", "v"}
      },
      {
        "<leader>gb",
        function()
          Snacks.git.blame_line()
        end,
        desc = "Git Blame Line"
      },
      {
        "<leader>gf",
        function()
          Snacks.lazygit.log_file()
        end,
        desc = "Lazygit Current File History"
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit"
      },
      {
        "<leader>gl",
        function()
          Snacks.lazygit.log()
        end,
        desc = "Lazygit Log (cwd)"
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications"
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle Terminal"
      },
      {
        "<c-_>",
        function()
          Snacks.terminal()
        end,
        desc = "which_key_ignore"
      },
      {
        "]]",
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = {"n", "t"}
      },
      {
        "[[",
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = {"n", "t"}
      },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win(
            {
              file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = "yes",
                statuscolumn = " ",
                conceallevel = 3
              }
            }
          )
        end
      },
      { "<leader>qp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files" },
    },
    init = function()
      vim.api.nvim_create_autocmd(
        "User",
        {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            Snacks.toggle.option("spell", {name = "Spelling"}):map("<leader>us")
            Snacks.toggle.option("wrap", {name = "Wrap"}):map("<leader>uw")
            Snacks.toggle.option("relativenumber", {name = "Relative Number"}):map("<leader>uL")
            Snacks.toggle.diagnostics():map("<leader>ud")
            Snacks.toggle.line_number():map("<leader>ul")
            Snacks.toggle.option("conceallevel", {off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2}):map(
              "<leader>uc"
            )
            Snacks.toggle.treesitter():map("<leader>uT")
            Snacks.toggle.option("background", {off = "light", on = "dark", name = "Dark Background"}):map("<leader>ub")
            Snacks.toggle.inlay_hints():map("<leader>uh")
            Snacks.toggle.indent():map("<leader>ug")
            Snacks.toggle.dim():map("<leader>uD")
          end
        }
      )
    end
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify"
    }
  },
  -- Language services
  "williamboman/mason.nvim", -- lsp installer
  "nvim-treesitter/nvim-treesitter", -- syntax highlighting
  -- Debugger stuff
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  -- Code tools
  "github/copilot.vim",
  -- "neoclide/coc.nvim", -- use lsp instead
  -- Utils
  "folke/which-key.nvim",
  "editorconfig/editorconfig-vim",
  "mhinz/vim-signify",
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim",
  "sindrets/diffview.nvim"
}

local opts = {}

require("lazy").setup(plugins, opts)
