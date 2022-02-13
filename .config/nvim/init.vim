colorscheme hybrid
syntax enable

lang en_US.UTF-8
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
  au BufRead,BufNewFile *.sql              setl ft=sql
  au BufRead,BufNewFile *.go               setl ft=go
  au BufRead,BufNewFile *.py               setl ft=python
  au BufRead,BufNewFile *.rb               setl ft=ruby
  au BufRead,BufNewFile *.js,              setl ft=javascript
  au BufRead,BufNewFile *.css              setl ft=css
  au BufRead,BufNewFile *.tpl              setl ft=gohtmltmpl
  au BufRead,BufNewFile *.json             setl ft=json
  au BufRead,BufNewFile *.scss             setl ft=scss
  au BufRead,BufNewFile *.html             setl ft=html
  au BufRead,BufNewFile *.toml             setl ft=toml
  au BufRead,BufNewFile .zshrc,.zshenv     setl ft=zsh
  au BufRead,BufNewFile *.sh               setl ft=zsh
  au BufRead,BufNewFile *.vim,.vimrc       setl ft=vim
  au BufRead,BufNewFile *.md,.markdown     setl ft=markdown
  au BufRead,BufNewFile makefile,Makefile  setl ft=make noexpandtab
  au BufRead,BufNewFile *.mk               setl ft=make noexpandtab
  au BufRead,BufNewFile .tmux.conf         setl ft=tmux noexpandtab
augroup END

" trim whitespace
autocmd BufWritePre * :%s/\s\+$//ge

let mapleader = ","

" clipboard
set clipboard+=unnamedplus

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
  call dein#add('roxma/nvim-yarp')
  call dein#add('roxma/vim-hug-neovim-rpc')

  " color scheme
  call dein#add('jpo/vim-railscasts-theme')
  call dein#add('itchyny/lightline.vim')

  " util
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
  call dein#add('Shougo/defx.nvim')
  " call dein#add('Shougo/vimfiler')
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
  " call dein#add('carlitux/deoplete-ternjs')

  " toml
  call dein#add('cespare/vim-toml')

  " auto pair
  " call dein#add('jiangmiao/auto-pairs')


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
let g:lightline = { 'colorscheme': 'wombat' }


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
" defx
"---------------------------------------------------------------------
" autocmd VimEnter * execute 'Defx'
nnoremap <silent> <Leader>f :<C-u> Defx <CR>

autocmd FileType defx call s:defx_my_settings()

function! s:defx_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
   \ defx#do_action('drop')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('drop')
  nnoremap <silent><buffer><expr> t
  \ defx#do_action('open','tabnew')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('drop', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('drop', 'pedit')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_or_close_tree')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction

call defx#custom#option('_', {
      \ 'winwidth': 30,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'show_ignored_files': 1,
      \ })

"--------------------------------------------------------------------
" syntax and language
"---------------------------------------------------------------------
" neomake
let g:neomake_python_enabled_makers = ['flake8']
augroup neomake_run
  autocmd! BufWritePost,BufEnter * Neomake
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

