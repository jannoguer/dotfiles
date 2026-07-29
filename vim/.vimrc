set clipboard=unnamedplus " syncs Vim clipboard with system clipboard
set cursorline " highlights the entire line your cursor is currently on
set expandtab " converts tabs into spaces when you press the Tab key
set hlsearch " keeps matches highlighted after pressing Enter
set ignorecase " makes searches case-insensitive
set incsearch " highlights matches as you type
set number " shows absolute current line number
set path+=** " lets :find search the whole tree below the working directory
set relativenumber " turns the line number column into a distance map
set scrolloff=8 " keeps 8 lines of context when scrolling
set shiftwidth=4 " sets the number of spaces used for auto-indentation
set smartcase " makes searches case-sensitive if you type a capital letter
set smartindent " automatically indents new lines smartly based on standard code structures
set tabstop=4 " sets the visual width of an actual tab character to 4 spaces
set timeoutlen=200 " how long Vim waits for the rest of a mapping like jk or a leader chord
set ttimeoutlen=200 " how long Vim waits for a terminal key code, kills the Esc lag
set virtualedit=onemore " allows the cursor to move one space past the end of the line

" this makes Vim regex behave like standard regex
nnoremap / /\v

let mapleader = " " " sets the leader key to the spacebar

" escape insert mode without leaving home row
inoremap jk <Esc>

" Move between windows with Ctrl+<direction>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" keep search results centered on screen
nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap <leader>h :set hlsearch!<CR>

set t_Co=256

" cursor shape per mode, all blinking, even numbers are the steady variants
let &t_EI = "\e[1 q" " normal: blinking block
let &t_SI = "\e[5 q" " insert: blinking line
let &t_SR = "\e[3 q" " replace: blinking underline

" terminals expose no cursor code for visual mode, so drive that one from mode changes
if exists('##ModeChanged') && exists('*echoraw')
    augroup CursorShape
        autocmd!
        autocmd ModeChanged *:[vV\x16]* call echoraw(&t_SI) " any mode into visual, charwise or linewise or block
        autocmd ModeChanged *:n call echoraw(&t_EI) " any mode back into normal
        autocmd VimEnter * call echoraw(&t_EI) " Vim does not emit the normal shape on startup
        autocmd VimLeave * call echoraw("\e[0 q") " hand the terminal default back to the shell
    augroup END
endif

if has('termguicolors')
    set termguicolors
endif

colorscheme vscode-dark-modern

" --- LEARNING MODE: force hjkl and keyboard-only navigation ---
set mouse= " disables mouse click and scroll entirely

nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
vnoremap <Up> <Nop>
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>
