let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/j/flashcard-adder
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
badd +29 ~/.config/nvim/init.vim
badd +121 src/Main.elm
badd +44 src/Route.elm
badd +32 src/CardEdit.elm
badd +133 src/CardList.elm
badd +87 src/Card.elm
badd +4 src/Flags.elm
badd +14 src/Ports.elm
badd +130 src/Card/Data.elm
badd +9 elm.json
badd +47 .git/hooks/pre-commit.sample
badd +8 scripts/install-hooks.bash
badd +4 scripts/pre-commit.bash
badd +64 tests/Tests.elm
badd +0 term://~/j/flashcard-adder//11277:/bin/bash
badd +5 .gitignore
argglobal
%argdel
edit tests/Tests.elm
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
wincmd =
argglobal
balt .gitignore
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
let s:l = 64 - ((27 * winheight(0) + 24) / 48)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 64
normal! 018|
wincmd w
argglobal
if bufexists(fnamemodify("tests/Tests.elm", ":p")) | buffer tests/Tests.elm | else | edit tests/Tests.elm | endif
if &buftype ==# 'terminal'
  silent file tests/Tests.elm
endif
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
let s:l = 50 - ((23 * winheight(0) + 24) / 48)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 50
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("term://~/j/flashcard-adder//11277:/bin/bash", ":p")) | buffer term://~/j/flashcard-adder//11277:/bin/bash | else | edit term://~/j/flashcard-adder//11277:/bin/bash | endif
if &buftype ==# 'terminal'
  silent file term://~/j/flashcard-adder//11277:/bin/bash
endif
balt src/CardList.elm
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 104 - ((23 * winheight(0) + 12) / 24)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 104
normal! 059|
wincmd w
argglobal
if bufexists(fnamemodify("src/CardList.elm", ":p")) | buffer src/CardList.elm | else | edit src/CardList.elm | endif
if &buftype ==# 'terminal'
  silent file src/CardList.elm
endif
balt ~/.config/nvim/init.vim
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
let s:l = 133 - ((8 * winheight(0) + 11) / 23)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 133
let s:c = 7 - ((0 * winwidth(0) + 25) / 50)
if s:c > 0
  exe 'normal! ' . s:c . '|zs' . 7 . '|'
else
  normal! 07|
endif
wincmd w
wincmd =
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
