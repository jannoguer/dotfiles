set cursorline " highlights the entire line your cursor is currently on
set virtualedit=onemore " allows the cursor to move one space past the end of the line

set tabstop=4 " sets the visual width of an actual tab character to 4 spaces
set shiftwidth=4 " sets the number of spaces used for auto-indentation
set expandtab " converts tabs into spaces when you press the Tab key
set smartindent " automatically indents new lines smartly based on standard code structures

nnoremap / /\v " makes Vim regex behave like standard regex

set t_Co=256

if has('termguicolors')
    set termguicolors
endif

colorscheme vscode-dark-modern