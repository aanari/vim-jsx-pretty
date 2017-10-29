"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim indent file
"
" Language: typescript.tsx
" Maintainer: aanari <ali@anari.io>
" Depends: leafgarland/typescript-vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


if exists('b:did_indent')
  let s:did_indent = b:did_indent
  unlet b:did_indent
endif

runtime! indent/xml.vim

let s:keepcpo = &cpo
set cpo&vim

if exists('s:did_indent')
  let b:did_indent = s:did_indent
endif

setlocal indentexpr=GetTsxIndent()
setlocal indentkeys=0{,0},0),0],0\,,!^F,o,O,e,*<Return>,<>>,<<>,/

if exists('*shiftwidth')
  function! s:sw()
    return shiftwidth()
  endfunction
else
  function! s:sw()
    return &sw
  endfunction
endif

let s:starttag = '^\s*<'
let s:endtag = '^\s*\/\?>\s*;\='
let s:real_endtag = '\s*<\/\+[A-Za-z]*>'

let s:has_vim_typescript = exists('*GetTypescriptIndent')

let s:true = !0
let s:false = 0

function! s:syn_sol(lnum)
  return map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")')
endfunction

function! s:syn_eol(lnum)
  let lnum = prevnonblank(a:lnum)
  let col = strlen(getline(lnum))
  return map(synstack(lnum, col), 'synIDattr(v:val, "name")')
endfunction

function! s:syn_attr_tsx(synattr)
  return a:synattr =~ "^tsx"
endfunction

function! s:syn_xmlish(syns)
  return s:syn_attr_tsx(get(a:syns, -1))
endfunction

function! s:syn_tsx_block_end(syns)
  return get(a:syns, -1) =~ '\%(ts\|typescript\)Braces' ||
      \  s:syn_attr_tsx(get(a:syns, -2))
endfunction

function! s:syn_tsx_region(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxRegion"'))
endfunction

function! s:syn_tsx_close_tag(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxCloseTag"'))
endfunction

function! s:syn_tsx_escapets(syns)
  return len(filter(copy(a:syns), 'v:val ==# "tsxEscapeTs"'))
endfunction

function! s:syn_tsx_continues(cursyn, prevsyn)
  let curdepth = s:syn_tsx_region(a:cursyn)
  let prevdepth = s:syn_tsx_region(a:prevsyn)

  return prevdepth == curdepth ||
      \ (prevdepth == curdepth + 1 && get(a:cursyn, -1) ==# 'tsxRegion')
endfunction

function! GetTsxIndent()
  let cursyn  = s:syn_sol(v:lnum)
  let prevsyn = s:syn_eol(v:lnum - 1)
  let nextsyn = s:syn_eol(v:lnum + 1)

  if (s:syn_xmlish(prevsyn) || s:syn_tsx_block_end(prevsyn)) &&
        \ s:syn_tsx_continues(cursyn, prevsyn)
    let ind = XmlIndentGet(v:lnum, 0)

    if getline(v:lnum) =~? s:endtag
      let ind = ind - s:sw()
    endif

    if getline(v:lnum - 1) =~? s:endtag
      let ind = ind + s:sw()
    endif

    " <div           | <div
    "   hoge={       |   hoge={
    "   <div></div>  |   ##<div></div>
    if s:syn_tsx_escapets(prevsyn) && !(getline(v:lnum - 1) =~? '}')
          \&& getline(v:lnum - 1) =~? '{'
      let ind = ind + s:sw()
    endif

    if getline(v:lnum) =~? s:starttag
          \&& !getline(v:lnum) =~? '}' && getline(v:lnum) =~? '{'
      let ind = ind + s:sw()
    endif

    " <div            | <div
    "   hoge={        |   hoge={
    "     <div></div> |     <div></div>
    "     }           |   }##
    if s:syn_tsx_escapets(cursyn) && getline(v:lnum) =~? '}'
          \&& !(getline(v:lnum) =~? '{')
      let ind = ind - s:sw()
    endif

    " return ( | return (
    "   <div>  |   <div>
    "   </div> |   </div>
    " ##);     | ); <--
    if getline(v:lnum) =~? ');\?' && s:syn_tsx_close_tag(prevsyn)
      let ind = ind - s:sw()
    endif

    if (s:syn_tsx_else_block(cursyn) || s:syn_ts_repeat_braces(cursyn))
          \&& s:syn_tsx_close_tag(prevsyn)
      let ind = ind - s:sw()
    endif
  else
    if s:has_vim_typescript ==# s:true
      let ind = GetTypescriptIndent()
    else
      let ind = cindent(v:lnum)
    endif
  endif

  return ind
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
