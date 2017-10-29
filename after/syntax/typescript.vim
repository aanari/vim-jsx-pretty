"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim syntax file
"
" Language: typescript.tsx
" Maintainer: aanari <ali@anari.io>
" Depends: leafgarland/typescript-vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:tsx_cpo = &cpo
set cpo&vim

syntax case match

if exists('b:current_syntax')
  let s:current_syntax = b:current_syntax
  unlet b:current_syntax
endif

if exists('s:current_syntax')
  let b:current_syntax = s:current_syntax
endif

" <tag id="sample">
" s~~~~~~~~~~~~~~~e
" and self close tag
" <tag id="sample"   />
" s~~~~~~~~~~~~~~~~~e
syntax region tsxTag
      \ start=+<\([^/!?<>="':]\+\)\@=+
      \ skip=+</[^ /!?<>"']\+>+
      \ end=+/\@<!>+
      \ end=+\(/>\)\@=+
      \ contained
      \ contains=tsxTag,tsxError,tsxTagName,tsxAttrib,tsxEqual,tsxString,tsxEscapeTs,
                \tsxCloseString
      \ keepend
      \ extend


" <tag></tag>
" s~~~~~~~~~e
" and self close tag
" <tag/>
" s~~~~e
" A big start regexp borrowed from https://git.io/vDyxc
syntax region tsxRegion
      \ start=+\(\((\|{\|}\|\[\|,\|&&\|||\|?\|:\|=\|=>\|\Wreturn\|^return\|\Wdefault\|^\|>\)\_s*\)\@<=<\_s*\z([_\$a-zA-Z]\(\.\?[\$0-9a-zA-Z]\+\)*\)+
      \ skip=+<!--\_.\{-}-->+
      \ end=+</\_s*\z1>+
      \ end=+/>+
      \ fold
      \ contains=tsxRegion,tsxCloseString,tsxCloseTag,tsxTag,tsxComment,typescriptFuncBlock,
                \@Spell
      \ keepend
      \ extend

" </tag>
" ~~~~~~
syntax match tsxCloseTag
      \ +</\_s*[^/!?<>"']\+>+
      \ contained
      \ contains=tsxNamespace

syntax match tsxCloseString
      \ +/>+
      \ contained

" <!-- -->
" ~~~~~~~~
syntax match tsxComment /<!--\_.\{-}-->/ display

syntax match tsxEntity "&[^; \t]*;" contains=tsxEntityPunct
syntax match tsxEntityPunct contained "[&.;]"

" <tag key={this.props.key}>
"  ~~~
syntax match tsxTagName
    \ +<\_s*\zs[^/!?<>"']\++
    \ contained
    \ display

" <tag key={this.props.key}>
"      ~~~
syntax match tsxAttrib
    \ +\(\(<\_s*\)\@<!\_s\)\@<=\<[a-zA-Z_][-0-9a-zA-Z_]*\>\(\_s\+\|\_s*[=/>]\)\@=+
    \ contained
    \ display

" <tag id="sample">
"        ~
" syntax match tsxEqual +=+ display

" <tag id="sample">
"         s~~~~~~e
syntax region tsxString contained start=+"+ end=+"+ contains=tsxEntity,@Spell display

" <tag id='sample'>
"         s~~~~~~e
syntax region tsxString contained start=+'+ end=+'+ contains=tsxEntity,@Spell display

" <tag key={this.props.key}>
"          s~~~~~~~~~~~~~~e
syntax region tsxEscapeTs
    \ contained
    \ contains=typescriptBlock,tsxRegion
    \ start=+{+
    \ end=++
    \ extend

syntax match tsxIfOperator +?+
syntax match tsxElseOperator +:+

syntax cluster typescriptExpression add=tsxRegion

let s:vim_tsx_pretty_enable_tsx_highlight = get(g:, 'vim_tsx_pretty_enable_tsx_highlight', 1)

if s:vim_tsx_pretty_enable_tsx_highlight == 1
  highlight def link tsxTag Function
  highlight def link tsxTagName Function
  highlight def link tsxString String
  highlight def link tsxNameSpace Function
  highlight def link tsxComment Error
  highlight def link tsxAttrib Type
  highlight def link tsxEscapeTs tsxEscapeTs
  highlight def link tsxCloseTag Identifier
  highlight def link tsxCloseString Identifier
endif

let b:current_syntax = 'typescript.tsx'

let &cpo = s:tsx_cpo
unlet s:tsx_cpo

