-- =============================================================================
-- Kickstart.nvim-based Neovim Configuration
-- Full IDE setup for Python, TypeScript, and SQL development
-- =============================================================================

-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Dedicated Python provider for Neovim remote plugins (molten, etc.)
vim.g.python3_host_prog = vim.fn.expand("~/.config/nvim/.venv/bin/python")

-- =============================================================================
-- Options
-- =============================================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- =============================================================================
-- Basic Keymaps
-- =============================================================================

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostic navigation and display
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostic message" })

-- Buffer management
vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", function()
	require("mini.bufremove").delete(0, true)
end, { desc = "Force delete buffer" })
vim.keymap.set("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) == 1 then
			require("mini.bufremove").delete(buf, false)
		end
	end
end, { desc = "Close other buffers" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- =============================================================================
-- Autocommands
-- =============================================================================

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Python-specific settings (4 spaces per PEP 8)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.colorcolumn = "100"
	end,
})

-- TypeScript/JavaScript settings (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

-- SQL settings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

-- =============================================================================
-- Plugin Manager (lazy.nvim)
-- =============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Plugins
-- =============================================================================

require("lazy").setup({
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {},
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- Git integration (gutter signs)
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- Fugitive (Git commands)
	{
		"tpope/vim-fugitive",
		cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "GBrowse" },
		keys = {
			{ "<leader>gs", "<cmd>G<cr>", desc = "[G]it [S]tatus" },
			{ "<leader>gb", "<cmd>G blame<cr>", desc = "[G]it [B]lame" },
			{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "[G]it [D]iff (vertical)" },
			{ "<leader>gl", "<cmd>G log --oneline<cr>", desc = "[G]it [L]og" },
			{ "<leader>gL", "<cmd>G log -p %<cr>", desc = "[G]it [L]og (current file)" },
			{ "<leader>gp", "<cmd>G push<cr>", desc = "[G]it [P]ush" },
			{ "<leader>gP", "<cmd>G pull<cr>", desc = "[G]it [P]ull" },
		},
	},

	-- Which-key for keybinding help
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>b", group = "[B]uffer" },
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>d", group = "[D]ebug" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>j", group = "[J]upyter" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>f", group = "[F]ind" },
				{ "<leader>t", group = "[T]est" },
				{ "<leader>v", group = "[V]env" },
				{ "<leader>o", group = "[O]verseer" },
				{ "<leader>x", group = "Trouble" },
			})
		end,
	},

	-- Telescope (fuzzy finder)
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			-- Core finders
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep project" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Open buffers" })
			vim.keymap.set("n", "<leader>f.", builtin.resume, { desc = "Resume last search" })

			-- Targeted finders
			vim.keymap.set("n", "<leader>f*", builtin.grep_string, { desc = "Grep word under cursor" })
			vim.keymap.set("n", "<leader>f/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "Search in buffer" })
			vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_workspace_symbols, { desc = "Symbols" })

			-- Extras
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>fn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Neovim config" })
		end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Highlight references under cursor
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Inlay hints toggle
					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Python virtualenv detection for pyright
			local function get_python_path()
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					return venv_path .. "/bin/python"
				end

				for _, venv_name in ipairs({ ".venv", "venv" }) do
					local path = vim.fn.getcwd() .. "/" .. venv_name .. "/bin/python"
					if vim.fn.executable(path) == 1 then
						return path
					end
				end

				return "python"
			end

			-- LSP Server configurations
			local servers = {
				pyright = {
					before_init = function(_, config)
						config.settings.python.pythonPath = get_python_path()
					end,
					settings = {
						python = {
							analysis = {
								autoImportCompletions = true,
								typeCheckingMode = "basic",
								diagnosticMode = "workspace",
							},
						},
					},
				},
				ruff = {},
				ts_ls = {},
				eslint = {},
				sqlls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								disable = { "missing-fields" },
							},
						},
					},
				},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
				"prettier",
				"sql-formatter",
				"debugpy",
				"js-debug-adapter",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "vim-dadbod-completion" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Database
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		init = function()
			vim.g.db_ui_use_nerd_font_icons = 1
		end,
		keys = {
			{ "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
		},
	},

	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd.hi("Comment gui=none")
		end,
	},
	{
		"nyoom-engineering/oxocarbon.nvim",
	},

	-- Todo comments highlighting
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- oil.nvim (edit filesystem like a buffer)
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				-- Show hidden files
				view_options = {
					show_hidden = true,
				},
				-- Keymaps within oil buffer
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-s>"] = "actions.select_vsplit",
					["<C-h>"] = "actions.select_split",
					["<C-t>"] = "actions.select_tab",
					["<C-p>"] = "actions.preview",
					["<C-c>"] = "actions.close",
					["<C-l>"] = "actions.refresh",
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = "actions.tcd",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
				},
				-- Skip confirmation for simple operations
				skip_confirm_for_simple_edits = true,
			})

			-- Press `-` to open parent directory from any buffer
			vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory (Oil)" })
		end,
	},

	-- neo-tree.nvim (project sidebar explorer)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file [E]xplorer" },
			{ "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in [E]xplorer" },
		},
		config = function()
			-- Disable netrw (Vim's built-in explorer) since we have oil + neo-tree
			vim.g.loaded_netrwPlugin = 1
			vim.g.loaded_netrw = 1

			require("neo-tree").setup({
				close_if_last_window = true,
				popup_border_style = "rounded",
				filesystem = {
					follow_current_file = {
						enabled = true,
					},
					use_libuv_file_watcher = true,
					filtered_items = {
						visible = true,
						hide_dotfiles = false,
						hide_gitignored = false,
					},
				},
				window = {
					width = 35,
					mappings = {
						["<space>"] = "none", -- Don't conflict with leader
						["-"] = "none", -- Let oil handle this globally
					},
				},
				default_component_configs = {
					git_status = {
						symbols = {
							added = "+",
							modified = "~",
							deleted = "✖",
							renamed = "➜",
							untracked = "?",
							ignored = "◌",
							unstaged = "○",
							staged = "●",
							conflict = "",
						},
					},
				},
			})
		end,
	},

	-- Mini.nvim collection
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			require("mini.bufremove").setup()
			require("mini.bracketed").setup({
				jump = { suffix = "" }, -- disable [j/]j to preserve Jupyter cell keymaps
			})
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-- Bufferline (visual buffer tabs)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true,
					},
				},
				always_show_bufferline = false,
				show_close_icon = false,
			},
		},
		keys = {
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
			{ "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
			{ "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
			{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
			{ "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close non-pinned" },
			{ "<leader>bs", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
			{ "<leader>bS", "<cmd>BufferLinePickClose<cr>", desc = "Pick to close" },
		},
	},

	-- Treesitter (syntax highlighting and parser management)
	-- Note: Neovim 0.11+ has built-in treesitter highlighting enabled by default
	-- This plugin manages parser installation and updates
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ensure = {
				"bash",
				"css",
				"dockerfile",
				"gitignore",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"sql",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}
			local installed = require("nvim-treesitter.config").get_installed()
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, ensure)
			if #missing > 0 then
				require("nvim-treesitter.install").install(missing)
			end
		end,
	},

	-- otter.nvim (LSP features for embedded languages)
	{
		"jmbuhr/otter.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = "python",
		config = function()
			require("otter").setup({
				lsp = {
					diagnostic_update_events = { "BufWritePost" },
				},
				buffers = {
					set_filetype = true,
					write_to_disk = false,
				},
				handle_leading_whitespace = true,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				group = vim.api.nvim_create_augroup("otter-sql-activate", { clear = true }),
				callback = function()
					vim.schedule(function()
						require("otter").activate({ "sql" }, true, true)
					end)
				end,
			})
		end,
	},

	-- Conform (formatting)
	{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>fm",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]or[m]at buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
			formatters_by_ft = {
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				sql = { "sql_formatter" },
				lua = { "stylua" },
			},
		},
	},

	-- =========================================================================
	-- Additional IDE Plugins
	-- =========================================================================

	-- jupytext.nvim (edit .ipynb files as plain Python scripts)
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "percent",
			output_extension = "auto",
			force_ft = "python",
		},
	},

	-- Molten.nvim (Jupyter kernel integration with inline output)
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		keys = {
			{ "<leader>ji", "<cmd>MoltenInit<cr>", desc = "[J]upyter [I]nit kernel" },
			{
				"<leader>je",
				"<cmd>MoltenEvaluateOperator<cr>",
				desc = "[J]upyter [E]valuate (operator)",
			},
			{ "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "[J]upyter evaluate [L]ine" },
			{ "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "[J]upyter [R]e-evaluate cell" },
			{ "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "[J]upyter [D]elete output" },
			{ "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "[J]upyter show [O]utput" },
			{ "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "[J]upyter [H]ide output" },
			{
				"<leader>jv",
				":<C-u>MoltenEvaluateVisual<cr>",
				mode = "v",
				desc = "[J]upyter evaluate [V]isual",
			},
			{ "]j", "/# %%<cr>:nohlsearch<cr>", desc = "Next Jupyter cell" },
			{ "[j", "?# %%<cr>:nohlsearch<cr>", desc = "Previous Jupyter cell" },
		},
	},

	-- Trouble.nvim (better diagnostics panel)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
		},
	},

	-- nvim-ts-autotag (auto-close JSX/HTML tags)
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},

	-- symbols-outline.nvim (code structure view)
	{
		"simrat39/symbols-outline.nvim",
		keys = {
			{ "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "[C]ode [S]ymbols outline" },
		},
		opts = {},
	},

	-- Neotest (test runner)
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/nvim-nio",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		keys = {
			{
				"<leader>tt",
				function()
					require("neotest").run.run()
				end,
				desc = "[T]est nearest",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[T]est [F]ile",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[T]est [S]ummary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "[T]est [O]utput",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "[T]est Output Panel",
			},
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
						runner = "pytest",
					}),
				},
			})
		end,
	},

	-- venv-selector.nvim (Python virtualenv picker)
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		branch = "regexp",
		keys = {
			{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "[V]env [S]elect" },
		},
		opts = {},
	},

	-- nvim-dap (Debug Adapter Protocol)
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("mason-nvim-dap").setup({
				automatic_installation = true,
				handlers = {},
				ensure_installed = {
					"debugpy",
					"js-debug-adapter",
				},
			})

			-- Debugging keymaps
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug: Toggle [B]reakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "[D]ebug: Conditional [B]reakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[D]ebug: Open [R]EPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[D]ebug: Run [L]ast" })

			-- DAP UI setup
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
			})

			-- Auto open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			-- Python debugging setup
			require("dap-python").setup("python")
			require("dap-python").test_runner = "pytest"

			-- JavaScript/TypeScript debugging
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}

			for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Comment.nvim for easy commenting
	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	-- indent-blankline for visual indentation
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- overseer.nvim (task runner)
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle", "OverseerRunCmd" },
		keys = {
			{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "[O]verseer [T]oggle task list" },
			{ "<leader>or", "<cmd>OverseerRun<cr>", desc = "[O]verseer [R]un task" },
			{ "<leader>oa", "<cmd>OverseerQuickAction<cr>", desc = "[O]verseer Quick [A]ction" },
			{ "<leader>oc", "<cmd>OverseerRunCmd<cr>", desc = "[O]verseer Run [C]md" },
			{ "<leader>ol", "<cmd>OverseerRestartLast<cr>", desc = "[O]verseer Restart [L]ast" },
		},
		config = function()
			require("overseer").setup({
				task_list = {
					direction = "right",
					default_detail = 1,
				},
				templates = { "builtin" },
			})
		end,
	},

	-- toggleterm.nvim (quick terminal access)
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<C-\>]],
				hide_numbers = true,
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
				direction = "float",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved",
					winblend = 0,
				},
			})

			-- Numbered terminals with <leader>1, <leader>2, etc.
			local Terminal = require("toggleterm.terminal").Terminal

			for i = 1, 3 do
				vim.keymap.set({ "n", "t" }, "<leader>" .. i, function()
					Terminal:new({ id = i, direction = "float" }):toggle()
				end, { desc = "Terminal " .. i })
			end

			-- Horizontal terminal
			vim.keymap.set(
				"n",
				"<leader>th",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				{ desc = "[T]erminal [H]orizontal" }
			)

			-- Vertical terminal
			vim.keymap.set(
				"n",
				"<leader>tv",
				"<cmd>ToggleTerm direction=vertical<cr>",
				{ desc = "[T]erminal [V]ertical" }
			)

			-- Better terminal navigation (escape to normal mode, then navigate)
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")
		end,
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et
