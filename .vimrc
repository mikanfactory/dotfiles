colorscheme railscasts
syntax enable

lang C
set number
set cursorline
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set hls is
set nrformats=
imap <C-t> <nop>
set pastetoggle=<F2>
scriptencoding utf-8
set encoding=utf-8
set lazyredraw
set clipboard=unnamed,autoselect
set t_BE=

inoremap  <C-e> <END>
inoremap  <C-a> <HOME>
inoremap <silent> <C-b> <Left>
inoremap <silent> <C-f> <Right>
inoremap <silent> <C-h> <C-g>u<C-h>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

hi Pmenu ctermbg=255 ctermfg=0 guifg=#000000 guibg=#999999
hi PmenuSel ctermbg=blue ctermfg=black
hi PmenuSbar ctermbg=0 ctermfg=9
hi PmenuSbar ctermbg=255 ctermfg=0 guifg=#000000 guibg=#FFFFFF
au BufRead,BufNewFile *.tpl setl ft=gohtmltmpl

"---------------------------------------------------------------------
" Start dein Settings.
"---------------------------------------------------------------------
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &compatible
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " dein
  call dein#add('Shougo/dein.vim')

  " color scheme
  call dein#add('jpo/vim-railscasts-theme')
  call dein#add('itchyny/lightline.vim')

  " util
  call dein#add('vim-scripts/Align')
  call dein#add('vim-scripts/grep.vim')
  call dein#add('tpope/vim-dispatch')
  call dein#add('tpope/vim-surround')
  call dein#add('tmhedberg/matchit')

  call dein#add('Shougo/vimproc.vim', {
      \ 'build': {
      \     'windows' : 'tools\\update-dll-mingw',
      \     'cygwin'  : 'make -f make_cygwin.mak',
      \     'mac'     : 'make -f make_mac.mak',
      \     'linux'   : 'make',
      \     'unix'    : 'gmake',
      \    },
      \ })

  call dein#add('thinca/vim-quickrun')
  call dein#add('tommcdo/vim-exchange')
  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-textobj-entire')
  call dein#add('glidenote/memolist.vim')
  call dein#add('kien/rainbow_parentheses.vim')
  call dein#add('bronson/vim-visual-star-search')

  " auto complete
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('roxma/nvim-yarp')
  call dein#add('roxma/vim-hug-neovim-rpc')
  call dein#add('Shougo/neosnippet')
  call dein#add('Shougo/neosnippet-snippets')

  " unite
  call dein#add('Shougo/vimfiler')
  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/unite.vim')
  call dein#add('thinca/vim-unite-history')
  call dein#add('kmnk/vim-unite-giti')

  " syntax and language
  call dein#add('w0rp/ale')

  " go
  call dein#add('fatih/vim-go')

  " python
  call dein#add('zchee/deoplete-jedi')
  call dein#add('davidhalter/jedi-vim')

  " javascript
  call dein#add('carlitux/deoplete-ternjs')

  " toml
  call dein#add('cespare/vim-toml')

  " whitespace
  call dein#add('bronson/vim-trailing-whitespace')

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

"---------------------------------------------------------------------
" End dein Settings.
"---------------------------------------------------------------------

"--------------------------------------------------------------------
" matchit
"---------------------------------------------------------------------
if !exists('loaded_machit')
  runtime macros/matchit.vim
endif

"--------------------------------------------------------------------
" quickrun.vim
"--------------------------------------------------------------------
nnoremap <silent> ,qr :QuickRun -outputter/buffer/split 
      \ ":botright 8sp" -hook/time/enable 1<CR>


"--------------------------------------------------------------------
" rainbow_parentheses.vim
"--------------------------------------------------------------------
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare

"---------------------------------------------------------------------
" deoplete
"---------------------------------------------------------------------
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_delay = 0
let g:deoplete#auto_complete_start_length = 1
let g:deoplete#enable_camel_case = 1
let g:deoplete#file#enable_buffer_path = 1
let g:deoplete#max_list = 1000

" profiling
let g:deoplete#enable_profile = 0

" omnifunc
let g:deoplete#omni#input_patterns = {}

" ignore_source
let g:deoplete#ignore_sources = {}

" python
let g:deoplete#ignore_sources.python =
      \ ['buffer', 'dictionary', 'tag', 'syntax', 'neosnippet']
let g:deoplete#sources#jedi#statement_length = 0
let g:deoplete#sources#jedi#enable_cache = 1
let g:deoplete#sources#jedi#short_types = 1
let g:deoplete#sources#jedi#show_docstring = 0
let g:deoplete#sources#jedi#debug_enabled = 0

"---------------------------------------------------------------------
" neosnippet
"---------------------------------------------------------------------
let s:my_snippet = '~/dotfiles/snippets'
let g:neosnippet#snippets_directory = s:my_snippet
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
imap <expr><Tab> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><Tab> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: "\<Tab>"
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

"---------------------------------------------------------------------
" vimfiler
"---------------------------------------------------------------------
let g:vimfiler_as_default_explorer=1
let g:vimfiler_safe_mode_by_default = 0
nnoremap <silent> ,d :<c-u>VimFilerBufferDir<cr>

"---------------------------------------------------------------------
" unite
"---------------------------------------------------------------------
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
let g:gitgutter_system_function       = 'vimproc#system'
let g:gitgutter_system_error_function = 'vimproc#get_last_status'
let g:gitgutter_shellescape_function  = 'vimproc#shellescape'
let g:unite_source_grep_command = 'rg'
let g:unite_source_grep_default_opts = '-n --no-heading --color never'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_max_candidates = 200
let s:unite_ignore_file_rec_patterns=
      \ ''
      \ .'vendor/bundle\|.bundle/\|\.sass-cache/\|'
      \ .'node_modules/\|bower_components/\|'
      \ .'venv/\|'
      \ .'env/\|'
      \ .'\.mypy_cache/\|'
      \ .'\.\(bmp\|gif\|jpe\?g\|png\|webp\|ai\|psd\)\?$'

call unite#custom#source(
      \ 'file_rec/async,file_rec/git',
      \ 'ignore_pattern',
      \ s:unite_ignore_file_rec_patterns)

function! DispatchUniteFileRecAsyncOrGit()
  if isdirectory(getcwd()."/.git")
    Unite file_rec/git
  else
    Unite file_rec/async
  endif
endfunction

nnoremap <silent> ,b :<c-u>Unite file_mru buffer<cr>
nnoremap <silent> ,r :<C-u>Unite file_mru buffer<CR>
nnoremap <silent> ,f :<C-u>call DispatchUniteFileRecAsyncOrGit()<CR>
nnoremap <silent> ,y :<C-u>Unite history/yank<CR>
nnoremap <silent> ,s :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
nnoremap <silent> ,c :<C-u>Unite -default-action=lcd directory_mru<CR>

"---------------------------------------------------------------------
" vim-exchange
"---------------------------------------------------------------------
xmap gx <Plug>(Exchange)

"--------------------------------------------------------------------
" ale
"---------------------------------------------------------------------
let g:ale_fixers = {
\   'python': ['autopep8', 'flake8', 'mypy']
\}

"--------------------------------------------------------------------
" jedi
"---------------------------------------------------------------------
autocmd FileType python setlocal completeopt-=preview
let g:jedi#goto_definitions_command = ",g"

"---------------------------------------------------------------------
" vim-go
"---------------------------------------------------------------------
au FileType go nmap ,gi <Plug>(go-imports)

"-------------------------------------------------------------------
" memolist-vim
"--------------------------------------------------------------------
let g:memolist_path = "$HOME/Documents/memolist"
let g:memolist_memo_date = "%Y-%m-%d %H:%M"
let g:memolist_memo_date = "epoch"
let g:memolist_memo_date = "%D %T"
let g:memolist_prompt_tags = 1
let g:memolist_prompt_categories = 1
let g:memolist_qfixgrep = 1
let g:memolist_vimfiler = 1
let g:memolist_template_dir_path = "$HOME/Documents/memolist"

"--------------------------------------------------------------------
" lightline
"---------------------------------------------------------------------
set laststatus=2
set t_Co=256
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'mode_map': {'c': 'NORMAL'},
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'modified': 'MyModified',
      \   'readonly': 'MyReadonly',
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode'
      \ }
      \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      return fugitive#head()
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction
