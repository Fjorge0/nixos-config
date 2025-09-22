-- Tie vim clipboard to system
vim.opt.clipboard = "unnamedplus"

-- Cosmetic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = {
	tab = '→─',
	space = '·',
	nbsp = '␣',
	trail = '•',
	precedes = '«',
	extends = '»'
}

-- Tab and indent widths
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Scroll line padding
vim.opt.scrolloff = 2

-- Allows < and > for indenting
vim.keymap.set("v", ">", ">gv", { noremap = true })
vim.keymap.set("v", "<", "<gv", { noremap = true })

-- Stop d from copying to clipboard
vim.keymap.set({"x", "n"}, "<leader>d", "_d", { noremap = true })
--vim.keymap.set({"v", "n"}, "D", "_D", { noremap = true })

-- Use .. for clearing highlights
--[[vim.keymap.del('n', '.')
vim.keymap.set("n", "..", ":noh<CR><CR>", { noremap = true })]]--

-- Colorscheme settings
vim.opt.termguicolors = true
vim.g.onedark_config = {
	style = 'warmer'
}
vim.cmd('colorscheme onedark')

-- Lines marking cursor position
vim.opt.cursorcolumn = true
vim.opt.cursorline = true

--[[vim.api.nvim_create_augroup('cursorline', )
augroup cursorline
	au!
	au ColorScheme * hi clear CursorLine
	\ | hi link CursorLine CursorColumn
augroup END]]--

-- Reset cursor on exit
vim.api.nvim_create_autocmd('VimLeave', {
	pattern = '*',
	command = 'call nvim_cursor_set_shape("vertical-bar")'
})


--[[        PLUGINS        ]]--
-- Configure COQ border
vim.g.coq_settings = {
	auto_start = 'shut-up',
	display = {
		preview = {
			border = {
				{"", "NormalFloat"},
				{"", "NormalFloat"},
				{"", "NormalFloat"},
				{" ", "NormalFloat"},
				{"", "NormalFloat"},
				{"", "NormalFloat"},
				{"", "NormalFloat"},
				{" ", "NormalFloat"}
			}
		}
	}
}

-- Setup certain plugins
require'colorizer'.setup()
require('guess-indent').setup {}

-- Set vimtex compiler
vim.g.vimtex_compiler_method = 'pdflatex'

local todoCommentsConfig = require("todo-comments.config")

require("todo-comments").setup({
	highlight = {
		keyword = "fg",
		after = "",
	},
	keywords = {
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning" },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = "󰅒 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = "󰆈 ", color = "hint", alt = { "INFO" } },
		TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
		REM  = { icon = "󰅍 ", color = "hint", alt = { "REQUIRES", "EFFECTS", "MODIFIES" } },
	},
})

local lsp = require("lspconfig")
local configs = require("lspconfig.configs")
local util = require("lspconfig.util")
local coq = require("coq")

local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false } }

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.CR = function()
	if vim.fn.pumvisible() ~= 0 then
		if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
			return npairs.esc('<c-y>')
		else
			return npairs.esc('<c-e>') .. npairs.autopairs_cr()
		end
	else
		return npairs.autopairs_cr()
	end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
	if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
		return npairs.esc('<c-e>') .. npairs.autopairs_bs()
	else
		return npairs.autopairs_bs()
	end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

-- LSP setup
lsp.nil_ls.setup(coq.lsp_ensure_capabilities())

lsp.pyright.setup(coq.lsp_ensure_capabilities({
	settings = {
		python = {
			linting = {
				pylintEnabled = true
			}
		}
	}
}))

lsp.clangd.setup(coq.lsp_ensure_capabilities({
	cmd = {
		"clangd",
		"--background-index",
		"--completion-style=detailed",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--all-scopes-completion=true",
		"--function-arg-placeholders",
		"--header-insertion-decorators",
		"--suggest-missing-includes",
		"--fallback-style=llvm",
		"-j=4",
	},
	init_options = {
		clangdFileStatus = true,
		completeUnimported = true,
		usePlaceholders = true,
		clangdSemanticHighlighting = true,
		fallbackFlags = { "-Wall", "-Wpedantic", "-std=c++20" },
	},
}))

require("clangd_extensions.inlay_hints").setup_autocmd()
require("clangd_extensions.inlay_hints").set_inlay_hints()

if not configs.ruby_lsp then
	local enabled_features = {
		"documentHighlights",
		"documentSymbols",
		"foldingRanges",
		"selectionRanges",
		"semanticHighlighting",
		"formatting",
		"codeActions",
	}

	configs.ruby_lsp = {
		default_config = {
			cmd = { "bundle", "exec", "ruby-lsp" },
			filetypes = { "ruby" },
			root_dir = util.root_pattern("Gemfile", ".git"),
			init_options = {
				enabledFeatures = enabled_features,
			},
			settings = {},
		},
		commands = {
			FormatRuby = {
				function()
					vim.lsp.buf.format({
					name = "ruby_lsp",
					async = true,
				})
				end,
				description = "Format using ruby-lsp",
			},
		},
	}
end

lsp.ruby_lsp.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach, capabilities = capabilities }))

lsp.verible.setup(coq.lsp_ensure_capabilities({
	cmd = {'verible-verilog-ls', '--rules_config_search'},
}))

require'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all" (the listed parsers MUST always be installed)
	--ensure_installed = { "c", "cpp", "python", "javascript", "markdown", "markdown_inline", "yaml", "json", "html", "make", "css", "html", "latex" },

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = false,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

-- Indent lines
require("ibl").setup({
	indent = {
		highlight = { "Whitespace" },
		char = "▎",
		tab_char = "▎",
	},
	scope = {
		highlight = { "MoreMsg" },
	},
})

-- LSP messages on a separate line
require("lsp_lines").setup()
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = true,
})
