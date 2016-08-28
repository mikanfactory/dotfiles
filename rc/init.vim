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

inoremap <C-e> <END>
inoremap <C-a> <HOME>
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

augroup filetypes
  au BufRead,BufNewFile *.go           setl ft=go
  au BufRead,BufNewFile *.py           setl ft=python
  au BufRead,BufNewFile *.rb           setl ft=ruby
  au BufRead,BufNewFile *.css          setl ft=css
  au BufRead,BufNewFile *.tpl          setl ft=gohtmltmpl
  au BufRead,BufNewFile *.scss         setl ft=scss
  au BufRead,BufNewFile *.html         setl ft=html
  au BufRead,BufNewFile *.toml         setl ft=toml
  au BufRead,BufNewFile .zshrc         setl ft=zsh
  au BufRead,BufNewFile *.js,*.jsx     setl ft=javascript
  au BufRead,BufNewFile *.vim,.vimrc   setl ft=vim
  au BufRead,BufNewFile *.md,.markdown setl ft=markdown
augroup END

"---------------------------------------------------------------------
" Start dein Settings.
"---------------------------------------------------------------------
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " dein
  call dein#add('Shougo/dein.vim')

  " color scheme
  call dein#add('jpo/vim-railscasts-theme')
  call dein#add('itchyny/lightline.vim')

  " util
  call dein#add('Align')
  call dein#add('grep.vim')
  call dein#add('tpope/vim-dispatch')
  call dein#add('tpope/vim-surround')
  call dein#add('tmhedberg/matchit')
  call dein#add('Shougo/vimproc.vim')
  call dein#add('thinca/vim-quickrun')
  call dein#add('tommcdo/vim-exchange')
  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-textobj-entire')
  call dein#add('glidenote/memolist.vim')
  call dein#add('kien/rainbow_parentheses.vim')
  call dein#add('bronson/vim-visual-star-search')

  " auto complete
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neosnippet')
  call dein#add('Shougo/neosnippet-snippets')

  " unite
  call dein#add('Shougo/vimfiler')
  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/unite.vim')
  call dein#add('thinca/vim-unite-history')
  call dein#add('kmnk/vim-unite-giti')

  " syntax and language
  call dein#add('neomake/neomake')

  " go
  call dein#add('fatih/vim-go')

  " python
  call dein#add('zchee/deoplete-jedi')
  call dein#add('davidhalter/jedi-vim')

  " javascript
  call dein#add('carlitux/deoplete-ternjs')

  " toml
  call dein#add('cespare/vim-toml')

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
" color scheme
"--------------------------------------------------------------------
" lightline
let g:lightline = { 
\   'colorscheme': 'wombat'
\ }


"---------------------------------------------------------------------
" util
"---------------------------------------------------------------------
" matchit
runtime macros/matchit.vim

" quickrun.vim
nnoremap <silent> ,qr :QuickRun -outputter/buffer/split 
      \ ":botright 8sp" -hook/time/enable 1<CR>

" vim-exchange
xmap gx <Plug>(Exchange)

" memolist-vim
let g:memolist_path = "$HOME/Dropbox/1writer"
let g:memolist_memo_date = "%Y-%m-%d %H:%M"
let g:memolist_memo_date = "epoch"
let g:memolist_memo_date = "%D %T"
let g:memolist_prompt_tags = 1
let g:memolist_prompt_categories = 1
let g:memolist_qfixgrep = 1
let g:memolist_vimfiler = 1
let g:memolist_template_dir_path = "$HOME/Dropbox/1writer"

" rainbow_parentheses.vim
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare


"---------------------------------------------------------------------
" auto complete
"---------------------------------------------------------------------
" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_delay = 0
let g:deoplete#auto_complete_start_length = 1
let g:deoplete#enable_camel_case = 1
let g:deoplete#file#enable_buffer_path = 1
let g:deoplete#max_list = 1000

call deoplete#custom#set('_', 'converters',
      \ ['converter_auto_paren', 'converter_remove_overlap'])
call deoplete#custom#set('_', 'matchers', ['matcher_fuzzy'])

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

" neosnippet
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

inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()


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
let g:unite_source_grep_command = 'ag'
let g:unite_source_grep_default_opts = '--nocolor --nogroup'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_max_candidates = 200
let s:unite_ignore_file_rec_patterns=
      \ ''
      \ .'vendor/bundle\|.bundle/\|\.sass-cache/\|'
      \ .'node_modules/\|bower_components/\|'
      \ .'venv/\|'
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

nnoremap <silent> ,b :<C-u>Unite file_mru buffer<CR>
nnoremap <silent> ,r :<C-u>Unite file_mru buffer<CR>
nnoremap <silent> ,f :<C-u>call DispatchUniteFileRecAsyncOrGit()<CR>
nnoremap <silent> ,y :<C-u>Unite history/yank<CR>
nnoremap <silent> ,s :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>


"--------------------------------------------------------------------
" syntax and language
"---------------------------------------------------------------------
" neomake
let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_javascript_enabled_makers = ['eslint_d']
augroup neomake_run
  autocmd! BufWritePost,BufEnter * Neomake
  autocmd! InsertLeave *.js,*jsx Neomake
  autocmd! VimLeave *.js,*jsx !eslint_d stop
augroup END

" go
au FileType go nmap ,gi <Plug>(go-imports)

" python
let g:jedi#auto_initialization = 0
let g:jedi#use_splits_not_buffers = 'winwidth'
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#documentation_command = "K"
let g:jedi#force_py_version = 3
let g:jedi#max_doc_height = 150
let g:jedi#popup_select_first = 0
let g:jedi#show_call_signatures = 0
let g:jedi#smart_auto_mappings = 0
