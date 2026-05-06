" Vim color file - High Contrast 16
" Pure 16-color palette (ANSI 0-15) for maximum legibility on any terminal.

set background=dark
if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

let g:colors_name = "High contrast 16"

hi Normal ctermfg=White ctermbg=Black cterm=NONE
hi Cursor ctermfg=Black ctermbg=White cterm=NONE
hi cursorim ctermfg=Black ctermbg=Cyan cterm=NONE
hi CursorLine ctermfg=NONE ctermbg=NONE cterm=NONE
hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
hi ColorColumn ctermfg=NONE ctermbg=DarkRed cterm=NONE
hi LineNr ctermfg=DarkGrey ctermbg=Black cterm=NONE
hi CursorLineNr ctermfg=Yellow ctermbg=Black cterm=bold
hi SignColumn ctermfg=DarkGrey ctermbg=Black cterm=NONE
hi NonText ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi SpecialKey ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi Conceal ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi Visual ctermfg=Black ctermbg=Yellow cterm=NONE
hi VisualNOS ctermfg=Black ctermbg=Yellow cterm=NONE
hi Search ctermfg=Black ctermbg=Yellow cterm=NONE
hi IncSearch ctermfg=Black ctermbg=White cterm=NONE
hi MatchParen ctermfg=Black ctermbg=Cyan cterm=bold
hi Folded ctermfg=Grey ctermbg=Black cterm=NONE
hi FoldColumn ctermfg=DarkGrey ctermbg=Black cterm=NONE
hi StatusLine ctermfg=Black ctermbg=White cterm=bold
hi StatusLineNC ctermfg=Black ctermbg=Grey cterm=NONE
hi VertSplit ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi WinSeparator ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi TabLine ctermfg=Grey ctermbg=Black cterm=NONE
hi TabLineSel ctermfg=Black ctermbg=White cterm=bold
hi TabLineFill ctermfg=NONE ctermbg=Black cterm=NONE
hi Pmenu ctermfg=White ctermbg=DarkBlue cterm=NONE
hi PmenuSel ctermfg=Black ctermbg=Cyan cterm=bold
hi PmenuSbar ctermfg=NONE ctermbg=DarkGrey cterm=NONE
hi PmenuThumb ctermfg=NONE ctermbg=White cterm=NONE
hi WildMenu ctermfg=Black ctermbg=Cyan cterm=bold
hi ErrorMsg ctermfg=White ctermbg=Red cterm=bold
hi WarningMsg ctermfg=Yellow ctermbg=NONE cterm=bold
hi ModeMsg ctermfg=White ctermbg=NONE cterm=bold
hi MoreMsg ctermfg=Cyan ctermbg=NONE cterm=NONE
hi Question ctermfg=Cyan ctermbg=NONE cterm=NONE
hi Title ctermfg=Yellow ctermbg=NONE cterm=bold
hi Directory ctermfg=Cyan ctermbg=NONE cterm=bold
hi Underlined ctermfg=Cyan ctermbg=NONE cterm=underline
hi DiffAdd ctermfg=White ctermbg=DarkGreen cterm=NONE
hi DiffChange ctermfg=White ctermbg=DarkBlue cterm=NONE
hi DiffDelete ctermfg=White ctermbg=DarkRed cterm=NONE
hi DiffText ctermfg=Black ctermbg=Green cterm=bold
hi SpellBad ctermfg=Red ctermbg=NONE cterm=underline
hi SpellCap ctermfg=Cyan ctermbg=NONE cterm=underline
hi SpellRare ctermfg=Magenta ctermbg=NONE cterm=underline
hi SpellLocal ctermfg=Green ctermbg=NONE cterm=underline
hi Comment ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi SpecialComment ctermfg=DarkGrey ctermbg=NONE cterm=NONE
hi Todo ctermfg=Black ctermbg=Yellow cterm=bold
hi Constant ctermfg=Magenta ctermbg=NONE cterm=NONE
hi String ctermfg=Green ctermbg=NONE cterm=NONE
hi Character ctermfg=Green ctermbg=NONE cterm=NONE
hi Number ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Float ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Boolean ctermfg=Red ctermbg=NONE cterm=bold
hi Identifier ctermfg=White ctermbg=NONE cterm=NONE
hi Function ctermfg=Yellow ctermbg=NONE cterm=bold
hi Statement ctermfg=Magenta ctermbg=NONE cterm=bold
hi Conditional ctermfg=Magenta ctermbg=NONE cterm=bold
hi Repeat ctermfg=Magenta ctermbg=NONE cterm=bold
hi Label ctermfg=Magenta ctermbg=NONE cterm=bold
hi Operator ctermfg=White ctermbg=NONE cterm=NONE
hi Keyword ctermfg=Cyan ctermbg=NONE cterm=bold
hi Exception ctermfg=Red ctermbg=NONE cterm=bold
hi PreProc ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Include ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Define ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Macro ctermfg=Magenta ctermbg=NONE cterm=NONE
hi PreCondit ctermfg=Magenta ctermbg=NONE cterm=NONE
hi Type ctermfg=Cyan ctermbg=NONE cterm=NONE
hi StorageClass ctermfg=Cyan ctermbg=NONE cterm=bold
hi Structure ctermfg=Cyan ctermbg=NONE cterm=NONE
hi Typedef ctermfg=Cyan ctermbg=NONE cterm=NONE
hi Special ctermfg=Yellow ctermbg=NONE cterm=NONE
hi SpecialChar ctermfg=Yellow ctermbg=NONE cterm=NONE
hi Tag ctermfg=Cyan ctermbg=NONE cterm=NONE
hi Delimiter ctermfg=White ctermbg=NONE cterm=NONE
hi Debug ctermfg=Red ctermbg=NONE cterm=bold
hi Error ctermfg=White ctermbg=Red cterm=bold

hi EndOfBuffer ctermfg=Black ctermbg=Black cterm=NONE
hi QuickFixLine ctermfg=Black ctermbg=Yellow cterm=bold
hi CurSearch ctermfg=Black ctermbg=Green cterm=bold
hi lCursor ctermfg=Black ctermbg=White cterm=NONE
hi Ignore ctermfg=Black ctermbg=NONE cterm=NONE

hi markdownH1 ctermfg=Yellow ctermbg=NONE cterm=bold
hi markdownH2 ctermfg=Cyan ctermbg=NONE cterm=bold
hi markdownCode ctermfg=Green ctermbg=NONE cterm=NONE
hi markdownLink ctermfg=Cyan ctermbg=NONE cterm=underline
hi gitcommitSummary ctermfg=White ctermbg=NONE cterm=bold
