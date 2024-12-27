-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- True color support
vim.opt.termguicolors = true

-- enable mouse
vim.opt.mouse = "a"

-- Already in the status line
vim.opt.showmode = false

-- Sync clipboard between nvim and OS.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Indents
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.breakindent = true
vim.opt.shiftround = true -- Round indent
vim.opt.smartindent = true

-- Save undo history
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- Case insensitive searching unless using capital letters in search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on
vim.opt.signcolumn = "yes"

-- Decrease times
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

-- new splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Whitespace preview
vim.opt.list = true
vim.opt.listchars = { tab = "· ", trail = "·", nbsp = "␣" }

--  substitutions Live Preview
vim.opt.inccommand = "nosplit"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Enable line wrap
vim.opt.wrap = true
vim.opt.smoothscroll = true

-- Customize completions
vim.opt.completeopt = "menu,menuone,noselect"

-- Use nushell
vim.opt.sh = "nu"
vim.opt.shelltemp = false
vim.opt.shellredir = "out+err> %s"
vim.opt.shellcmdflag = "--stdin --no-newline -c"
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""
vim.opt.shellquote = ""
-- NOTE: `ansi strip` removes all ansi coloring from nushell errors
vim.opt.shellpipe =
	"| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"

-- From lazyvim
vim.opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
vim.opt.foldlevel = 99
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.ruler = false -- Disable the default ruler
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.splitkeep = "screen"
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth = 5 -- Minimum window width
vim.opt.foldmethod = "expr"
vim.opt.foldtext = ""

vim.opt.foldexpr = "v:lua.MNvim.foldexpr()"
vim.opt.formatexpr = "v:lua.MNvim.formatexpr()"
