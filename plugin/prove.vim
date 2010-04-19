" prove.vim - description
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

" plugin code here

let &cpo = s:save_cpo
