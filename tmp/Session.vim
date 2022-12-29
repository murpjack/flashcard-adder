let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Development/j/flashcard-adder
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +1 ~/.bashrc
badd +1 ~/.tmux.conf
badd +270 ~/.config/nvim/init.vim
badd +317 src/Main.elm
badd +56 tests/Tests.elm
badd +215 src/Card.elm
badd +1 term://~/Development/j/flashcard-adder//17199:/bin/bash
badd +8 term://~/Development/j/flashcard-adder//9119:/bin/bash
badd +71 src/Ports.elm
badd +25 src/index.js
badd +1 src/Flags.elm
badd +9 README.md
badd +52 src/styles/main.scss
badd +5 ~/.config/nvim/coc-settings.json
argglobal
%argdel
edit src/styles/main.scss
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 70 + 106) / 213)
exe 'vert 2resize ' . ((&columns * 71 + 106) / 213)
exe '3resize ' . ((&lines * 27 + 28) / 56)
exe 'vert 3resize ' . ((&columns * 70 + 106) / 213)
exe '4resize ' . ((&lines * 26 + 28) / 56)
exe 'vert 4resize ' . ((&columns * 70 + 106) / 213)
argglobal
balt src/index.js
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 52 - ((38 * winheight(0) + 27) / 54)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 52
normal! 021|
wincmd w
argglobal
if bufexists(fnamemodify("src/Main.elm", ":p")) | buffer src/Main.elm | else | edit src/Main.elm | endif
if &buftype ==# 'terminal'
  silent file src/Main.elm
endif
balt ~/.config/nvim/coc-settings.json
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 317 - ((26 * winheight(0) + 27) / 54)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 317
normal! 0
lcd ~/Development/j/flashcard-adder
wincmd w
argglobal
if bufexists(fnamemodify("term://~/Development/j/flashcard-adder//9119:/bin/bash", ":p")) | buffer term://~/Development/j/flashcard-adder//9119:/bin/bash | else | edit term://~/Development/j/flashcard-adder//9119:/bin/bash | endif
if &buftype ==# 'terminal'
  silent file term://~/Development/j/flashcard-adder//9119:/bin/bash
endif
balt term://~/Development/j/flashcard-adder//17199:/bin/bash
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 15 - ((14 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 15
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("term://~/Development/j/flashcard-adder//17199:/bin/bash", ":p")) | buffer term://~/Development/j/flashcard-adder//17199:/bin/bash | else | edit term://~/Development/j/flashcard-adder//17199:/bin/bash | endif
if &buftype ==# 'terminal'
  silent file term://~/Development/j/flashcard-adder//17199:/bin/bash
endif
balt ~/Development/j/flashcard-adder/tests/Tests.elm
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 1390 - ((25 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1390
normal! 0
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 70 + 106) / 213)
exe 'vert 2resize ' . ((&columns * 71 + 106) / 213)
exe '3resize ' . ((&lines * 27 + 28) / 56)
exe 'vert 3resize ' . ((&columns * 70 + 106) / 213)
exe '4resize ' . ((&lines * 26 + 28) / 56)
exe 'vert 4resize ' . ((&columns * 70 + 106) / 213)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
