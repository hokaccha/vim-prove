" prove.vim - prove for vim plugin.
"
" Author:  Kazuhito Hokamura <http://webtech-walker.com/>
" Version: 0.0.1
" License: MIT License <http://www.opensource.org/licenses/mit-license.php>


function! prove#run_cmd(test_file)
  if a:test_file == ''
    let test_path = expand('%:p')
    if !filereadable(test_path)
      let test_path = tempname() . expand('%:e')
      let original_bufname = bufname('')
      let original_modified = &l:modified
        silent keepalt write `=test_path`
        if original_bufname == ''
          silent 0 file
        endif
      let &l:modified = original_modified
    endif
  else
    let test_path = fnamemodify(a:test_file, ':p')
    if !filereadable(test_path) && !isdirectory(test_path)
      call s:error('no such file or directory')
      return
    endif
  endif

  let lib_dirs = ''
  if exists('b:perl_project_libs')
    for lib_dir in b:perl_project_libs
      let lib_dirs .= ' -I' . lib_dir
    endfor
  endif

  let command = ''
  if exists('b:perl_project_home')
    let command = printf('cd %s;', b:perl_project_home)
  endif
  let command .= printf('prove -vr %s %s', lib_dirs, test_path)

  call s:open_window('[prove] test', 'prove', command, 'rightbelow')
endfunction 

function! s:gsub(str, pat, rep)
  return substitute(a:str, '\v'.a:pat, a:rep, 'g')
endfunction

function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
endfunction

function! s:open_window(bufname, filetype, command, win_pos)
  if !bufexists(a:bufname)
    execute a:win_pos . ' new'
    setlocal bufhidden=unload
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal noswapfile
    execute 'setlocal filetype=' . a:filetype
    silent file `=a:bufname`
    nnoremap <buffer> <silent> q <C-w>c
  else
    let bufnr = bufnr(a:bufname)
    let winnr = bufwinnr(bufnr)
    if winnr == -1
      execute a:win_pos . ' split'
      execute bufnr 'buffer'
      execute 'setlocal filetype=' . a:filetype
    else
      execute winnr 'wincmd w'
    endif
  endif

  silent % delete _
  call append(0, 'now loading...')
  redraw
  silent % delete _
  call append(0, '')
  execute 'silent! read !' a:command
  1
endfunction

function! s:get_module_name(module)
  if a:module == ''
    return s:get_cursor_module_name()
  else
    return a:module
  endif
endfunction

function! s:get_cursor_module_name()
  let regex = '[a-zA-Z0-9:_]\+'
  let orig_pos = getpos('.')[1:2]

  let start_col = searchpos('[a-zA-Z0-9:_]\+', 'bW')[1]
  let end_col   = searchpos('[a-zA-Z0-9:_]\+', 'ceW')[1]

  let module_name = strpart(getline('.'),
  \                        start_col - 1,
  \                        end_col - start_col + 1)

  call cursor(orig_pos)

  return module_name
endfunction

function! s:get_module_path(module)
  let lib_dirs = []
  if exists('b:perl_project_libs')
    let lib_dirs += b:perl_project_libs
  endif
  let lib_dirs += split(system('perl -e "print join \":\", @INC"'), ':')

  for dir in lib_dirs
    let module_path = dir . '/' . s:gsub(a:module, '::', '/') . '.pm'
    if filereadable(module_path)
      return module_path
    endif
  endfor
endfunction

" __END__
" vim:tw=78:sts=2:sw=2:ts=2:fdm=marker:
