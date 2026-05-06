" Vim color file - Visual Studio Code Dark Modern
" Replicates the "Dark Modern" theme shipped with VS Code.
" Editor palette and TextMate token scopes mapped onto Vim highlight groups.

set background=dark
if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

set t_Co=256
let g:colors_name = "VSCode Dark Modern"

hi Normal guifg=#CCCCCC guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=252 ctermbg=234 cterm=NONE
hi Cursor guifg=#1F1F1F guibg=#AEAFAD guisp=#AEAFAD gui=NONE ctermfg=234 ctermbg=248 cterm=NONE
hi cursorim guifg=#1F1F1F guibg=#569CD6 guisp=#569CD6 gui=NONE ctermfg=234 ctermbg=75 cterm=NONE
hi CursorLine guifg=NONE guibg=#2A2D2E guisp=#2A2D2E gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
hi CursorColumn guifg=NONE guibg=#2A2D2E guisp=#2A2D2E gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
hi ColorColumn guifg=NONE guibg=#2A2D2E guisp=#2A2D2E gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
hi LineNr guifg=#6E7681 guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=243 ctermbg=234 cterm=NONE
hi CursorLineNr guifg=#CCCCCC guibg=#2A2D2E guisp=NONE gui=NONE ctermfg=252 ctermbg=235 cterm=NONE
hi SignColumn guifg=#6E7681 guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=243 ctermbg=234 cterm=NONE
hi NonText guifg=#404040 guibg=NONE guisp=NONE gui=NONE ctermfg=238 ctermbg=NONE cterm=NONE
hi SpecialKey guifg=#404040 guibg=NONE guisp=NONE gui=NONE ctermfg=238 ctermbg=NONE cterm=NONE
hi Conceal guifg=#6E7681 guibg=NONE guisp=NONE gui=NONE ctermfg=243 ctermbg=NONE cterm=NONE
hi Visual guifg=NONE guibg=#264F78 guisp=#264F78 gui=NONE ctermfg=NONE ctermbg=24 cterm=NONE
hi VisualNOS guifg=NONE guibg=#264F78 guisp=#264F78 gui=NONE ctermfg=NONE ctermbg=24 cterm=NONE
hi Search guifg=NONE guibg=#9E6A03 guisp=#9E6A03 gui=NONE ctermfg=NONE ctermbg=130 cterm=NONE
hi IncSearch guifg=#1F1F1F guibg=#A8AC94 guisp=#A8AC94 gui=NONE ctermfg=234 ctermbg=144 cterm=NONE
hi MatchParen guifg=NONE guibg=#43464F guisp=#888888 gui=underline ctermfg=NONE ctermbg=238 cterm=underline
hi Folded guifg=#A0A0A0 guibg=#202020 guisp=NONE gui=italic ctermfg=247 ctermbg=234 cterm=NONE
hi FoldColumn guifg=#6E7681 guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=243 ctermbg=234 cterm=NONE
hi StatusLine guifg=#CCCCCC guibg=#181818 guisp=NONE gui=NONE ctermfg=252 ctermbg=233 cterm=NONE
hi StatusLineNC guifg=#7F7F7F guibg=#181818 guisp=NONE gui=NONE ctermfg=242 ctermbg=233 cterm=NONE
hi VertSplit guifg=#2B2B2B guibg=NONE guisp=NONE gui=NONE ctermfg=235 ctermbg=NONE cterm=NONE
hi WinSeparator guifg=#2B2B2B guibg=NONE guisp=NONE gui=NONE ctermfg=235 ctermbg=NONE cterm=NONE
hi TabLine guifg=#9D9D9D guibg=#181818 guisp=NONE gui=NONE ctermfg=246 ctermbg=233 cterm=NONE
hi TabLineSel guifg=#FFFFFF guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=255 ctermbg=234 cterm=NONE
hi TabLineFill guifg=NONE guibg=#181818 guisp=NONE gui=NONE ctermfg=NONE ctermbg=233 cterm=NONE
hi Pmenu guifg=#CCCCCC guibg=#202020 guisp=NONE gui=NONE ctermfg=252 ctermbg=234 cterm=NONE
hi PmenuSel guifg=#FFFFFF guibg=#04395E guisp=NONE gui=NONE ctermfg=255 ctermbg=23 cterm=NONE
hi PmenuSbar guifg=NONE guibg=#3E3E42 guisp=NONE gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
hi PmenuThumb guifg=NONE guibg=#686868 guisp=NONE gui=NONE ctermfg=NONE ctermbg=242 cterm=NONE
hi WildMenu guifg=#FFFFFF guibg=#04395E guisp=NONE gui=NONE ctermfg=255 ctermbg=23 cterm=NONE
hi ErrorMsg guifg=#F85149 guibg=NONE guisp=NONE gui=NONE ctermfg=203 ctermbg=NONE cterm=NONE
hi WarningMsg guifg=#CCA700 guibg=NONE guisp=NONE gui=NONE ctermfg=178 ctermbg=NONE cterm=NONE
hi ModeMsg guifg=#CCCCCC guibg=NONE guisp=NONE gui=bold ctermfg=252 ctermbg=NONE cterm=bold
hi MoreMsg guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Question guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Title guifg=#569CD6 guibg=NONE guisp=NONE gui=bold ctermfg=75 ctermbg=NONE cterm=bold
hi Directory guifg=#4DAAFC guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Underlined guifg=#4DAAFC guibg=NONE guisp=NONE gui=underline ctermfg=75 ctermbg=NONE cterm=underline
hi DiffAdd guifg=NONE guibg=#1B3A1F guisp=NONE gui=NONE ctermfg=NONE ctermbg=22 cterm=NONE
hi DiffChange guifg=NONE guibg=#2D2D33 guisp=NONE gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
hi DiffDelete guifg=#5A1D1D guibg=#3F1F1F guisp=NONE gui=NONE ctermfg=52 ctermbg=52 cterm=NONE
hi DiffText guifg=NONE guibg=#3D5A3D guisp=NONE gui=NONE ctermfg=NONE ctermbg=58 cterm=NONE
hi SpellBad guifg=NONE guibg=NONE guisp=#F44747 gui=undercurl ctermfg=203 ctermbg=NONE cterm=underline
hi SpellCap guifg=NONE guibg=NONE guisp=#569CD6 gui=undercurl ctermfg=75 ctermbg=NONE cterm=underline
hi SpellRare guifg=NONE guibg=NONE guisp=#C586C0 gui=undercurl ctermfg=176 ctermbg=NONE cterm=underline
hi SpellLocal guifg=NONE guibg=NONE guisp=#4EC9B0 gui=undercurl ctermfg=79 ctermbg=NONE cterm=underline
hi Comment guifg=#6A9955 guibg=NONE guisp=NONE gui=italic ctermfg=71 ctermbg=NONE cterm=NONE
hi SpecialComment guifg=#6A9955 guibg=NONE guisp=NONE gui=italic ctermfg=71 ctermbg=NONE cterm=NONE
hi Todo guifg=#1F1F1F guibg=#DCDCAA guisp=#DCDCAA gui=bold ctermfg=234 ctermbg=187 cterm=bold
hi Constant guifg=#4FC1FF guibg=NONE guisp=NONE gui=NONE ctermfg=81 ctermbg=NONE cterm=NONE
hi String guifg=#CE9178 guibg=NONE guisp=NONE gui=NONE ctermfg=174 ctermbg=NONE cterm=NONE
hi Character guifg=#CE9178 guibg=NONE guisp=NONE gui=NONE ctermfg=174 ctermbg=NONE cterm=NONE
hi Number guifg=#B5CEA8 guibg=NONE guisp=NONE gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Float guifg=#B5CEA8 guibg=NONE guisp=NONE gui=NONE ctermfg=151 ctermbg=NONE cterm=NONE
hi Boolean guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Identifier guifg=#9CDCFE guibg=NONE guisp=NONE gui=NONE ctermfg=117 ctermbg=NONE cterm=NONE
hi Function guifg=#DCDCAA guibg=NONE guisp=NONE gui=NONE ctermfg=187 ctermbg=NONE cterm=NONE
hi Statement guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Conditional guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Repeat guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Label guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Operator guifg=#D4D4D4 guibg=NONE guisp=NONE gui=NONE ctermfg=252 ctermbg=NONE cterm=NONE
hi Keyword guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Exception guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi PreProc guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Include guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Define guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Macro guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi PreCondit guifg=#C586C0 guibg=NONE guisp=NONE gui=NONE ctermfg=176 ctermbg=NONE cterm=NONE
hi Type guifg=#4EC9B0 guibg=NONE guisp=NONE gui=NONE ctermfg=79 ctermbg=NONE cterm=NONE
hi StorageClass guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Structure guifg=#4EC9B0 guibg=NONE guisp=NONE gui=NONE ctermfg=79 ctermbg=NONE cterm=NONE
hi Typedef guifg=#4EC9B0 guibg=NONE guisp=NONE gui=NONE ctermfg=79 ctermbg=NONE cterm=NONE
hi Special guifg=#D7BA7D guibg=NONE guisp=NONE gui=NONE ctermfg=180 ctermbg=NONE cterm=NONE
hi SpecialChar guifg=#D7BA7D guibg=NONE guisp=NONE gui=NONE ctermfg=180 ctermbg=NONE cterm=NONE
hi Tag guifg=#569CD6 guibg=NONE guisp=NONE gui=NONE ctermfg=75 ctermbg=NONE cterm=NONE
hi Delimiter guifg=#CCCCCC guibg=NONE guisp=NONE gui=NONE ctermfg=252 ctermbg=NONE cterm=NONE
hi Debug guifg=#F44747 guibg=NONE guisp=NONE gui=NONE ctermfg=203 ctermbg=NONE cterm=NONE
hi Error guifg=#F44747 guibg=NONE guisp=NONE gui=NONE ctermfg=203 ctermbg=NONE cterm=NONE

hi EndOfBuffer guifg=#1F1F1F guibg=#1F1F1F guisp=NONE gui=NONE ctermfg=234 ctermbg=234 cterm=NONE
hi QuickFixLine guifg=NONE guibg=#04395E guisp=NONE gui=NONE ctermfg=NONE ctermbg=23 cterm=NONE
hi CurSearch guifg=#1F1F1F guibg=#9E6A03 guisp=#9E6A03 gui=bold ctermfg=234 ctermbg=130 cterm=bold
hi lCursor guifg=#1F1F1F guibg=#AEAFAD guisp=#AEAFAD gui=NONE ctermfg=234 ctermbg=248 cterm=NONE
hi Ignore guifg=#1F1F1F guibg=NONE guisp=NONE gui=NONE ctermfg=234 ctermbg=NONE cterm=NONE

hi markdownH1 guifg=#569CD6 guibg=NONE gui=bold cterm=bold ctermfg=75 ctermbg=NONE
hi markdownH2 guifg=#569CD6 guibg=NONE gui=bold cterm=bold ctermfg=75 ctermbg=NONE
hi markdownCode guifg=#CE9178 guibg=NONE gui=NONE cterm=NONE ctermfg=174 ctermbg=NONE
hi markdownLink guifg=#4DAAFC guibg=NONE gui=underline cterm=underline ctermfg=75 ctermbg=NONE
hi gitcommitSummary guifg=#CCCCCC guibg=NONE gui=NONE cterm=NONE ctermfg=252 ctermbg=NONE
