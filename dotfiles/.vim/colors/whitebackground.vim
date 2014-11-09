" Vim color file
" Maintainer:	Emmanuel Bernard
" Last Change:	2014-10-27

" Based on mustang and adjusted

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set background=light

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  " syntax reset
endif

let colors_name = "whitebackground"

" hi Cursor 		guifg=NONE    guibg=#626262 gui=none ctermbg=241
" dark blue normal color = 18
" 18-20: dark blue
" 236: dark grey
" 231: bright white
" 255: white
" 28: green
" 90: violet
" 196: red
" 202: orange
" 218: pink
hi Normal 		guifg=#e2e2e5 guibg=#202020 gui=none ctermfg=20 ctermbg=231
hi SpecialKey 		guifg=#e2e2e5 guibg=#202020 gui=none ctermfg=39 ctermbg=255
hi SpellBad cterm=underline ctermbg=231 ctermfg=196
hi SpellCap ctermbg=218
hi Comment 		guifg=#e2e2e5 guibg=#202020 gui=none ctermfg=31 ctermbg=231
hi Macro term=underline ctermfg=202 guifg=#faf4c6
hi Title term=bold cterm=bold ctermfg=18
hi Special term=bold ctermfg=208 guifg=#ff9800
hi NonText 		guifg=#808080 guibg=#303030 gui=none ctermfg=28 ctermbg=231
hi LineNr 		guifg=#808080 guibg=#000000 gui=none ctermfg=28 ctermbg=252
hi StatusLine 	guifg=#d3d3d5 guibg=#444444 gui=italic ctermfg=90 ctermbg=231 cterm=italic
hi StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=97 ctermbg=251
hi VertSplit 	guifg=#444444 guibg=#444444 gui=none ctermfg=97 ctermbg=251
" Folded
" hi Visual		guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=122 ctermbg=4
hi Directory ctermfg=90 ctermbg=231

" vim: sw=2
