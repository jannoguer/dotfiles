set number " shows absolute current line number
set relativenumber " turns the line number column into a distance map
set cursorline " highlights the entire line your cursor is currently on
set virtualedit=onemore " allows the cursor to move one space past the end of the line
set scrolloff=8 " keeps 8 lines of context when scrolling

set tabstop=4 " sets the visual width of an actual tab character to 4 spaces
set shiftwidth=4 " sets the number of spaces used for auto-indentation
set expandtab " converts tabs into spaces when you press the Tab key
set smartindent " automatically indents new lines smartly based on standard code structures

" this makes Vim regex behave like standard regex
nnoremap / /\v

set ignorecase " makes searches case-insensitive
set smartcase " makes searches case-sensitive if you type a capital letter
set incsearch " highlights matches as you type
set hlsearch " keeps matches highlighted after pressing Enter

set clipboard=unnamedplus " syncs Vim clipboard with system clipboard
let mapleader = " " " sets the leader key to the spacebar

set t_Co=256

if has('termguicolors')
    set termguicolors
endif

colorscheme vscode-dark-modern
