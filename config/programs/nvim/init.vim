set clipboard+=unnamedplus

set number
set relativenumber
set list
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,precedes:«,extends:»

set tabstop=4
set shiftwidth=4

set scrolloff=2

vnoremap > >gv
vnoremap < <gv

nnoremap <leader>d "_d
xnoremap <leader>d "_d

nnoremap <CR> :noh<CR><CR>

let g:onedark_config = {
\ 'style': 'warmer',
\}
colorscheme onedark

set cursorcolumn
set cursorline

augroup cursorline
	au!
	au ColorScheme * hi clear CursorLine
	\ | hi link CursorLine CursorColumn
augroup END

let g:vimtex_compiler_method = 'pdflatex'

au VimLeave * call nvim_cursor_set_shape("vertical-bar")

let g:coq_settings = {
	\"auto_start": 'shut-up',
	\"display": {
	\"preview": {
	\"border": [
		\["", "NormalFloat"],
		\["", "NormalFloat"],
		\["", "NormalFloat"],
		\[" ", "NormalFloat"],
		\["", "NormalFloat"],
		\["", "NormalFloat"],
		\["", "NormalFloat"],
		\[" ", "NormalFloat"] ]}}}

lua require'colorizer'.setup()

lua << EOF
require('guess-indent').setup {}
require("lsp_lines").setup()

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
  virtual_text = false,
})

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
		fallbackFlags = { "-Wall", "-Wpedantic" },
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
EOF
