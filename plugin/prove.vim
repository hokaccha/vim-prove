" prove.vim - prove for vim plugin.
"
" Author:  Kazuhito Hokamura <http://webtech-walker.com/>
" Version: 0.0.1
" License: MIT License <http://www.opensource.org/licenses/mit-license.php>

if exists('g:loaded_prove')
    finish
endif
let g:loaded_prove = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -complete=file Prove :call prove#run_cmd(<q-args>)

let &cpo = s:save_cpo
