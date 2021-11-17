{ config, pkgs, lib, ...}:

with lib;

let
  # notPython = pkgs.writeScript "notPython" ''
  #   #!${pkgs.stdenv.shell}
  #   shift
  #   shift
  #   shift
  #   wakatime "$@"
  # '';
  myVim = with pkgs; (vim_configurable.override { python = python3; }).customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        syntax on

        " Security
        set nomodeline

        " Maps
        inoremap jk <ESC>
        map <space> <leader>
        map <F7> :tabp<CR>
        map <F8> :tabn<CR>
        nnoremap <leader>f 1z=
        nnoremap <leader>s :set spell!<CR>
        nmap <F3> :!nix-build -A default<CR>
        vnoremap . :norm.<CR>

        " Sets
        set autoindent
        set background=dark
        set backspace=indent,eol,start
        set expandtab
        set foldmethod=syntax
        set hlsearch
        set incsearch
        set laststatus=2
        set listchars=tab:->
        set list
        set nu
        set shiftwidth=2
        set nospell spelllang=en_us
        set softtabstop=2

        " Set status line
        set statusline=%f\ %h%w%m%r
        set statusline+=\ %#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*
        set statusline+=%=%(%l,%c%V\ %=\ %P%)

        " Remove trailing whitespace upon save
        au BufWritePre * %s/\s\+$//e

        " Highlight all trailing whitespace
        highlight ExtraWhitespace ctermbg=red guibg=red
        au ColorScheme * highlight ExtraWhitespace guibg=red
        au BufEnter * match ExtraWhitespace /\s\+$/
        au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
        au InsertLeave * match ExtraWhiteSpace /\s\+$/

        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 1
        let g:syntastic_check_on_wq = 0
        let g:syntastic_python_python_exec = 'python3'
        let g:syntastic_python_checkers = ['flake8']
        let g:syntastic_python_flake8_post_args='--ignore=E203,E501,W503'

        " let g:wakatime_PythonBinary = ' ''${notPython}'
        autocmd Filetype haskell set foldmethod=indent foldcolumn=2 softtabstop=2 shiftwidth=2
      '';
      plug.plugins = with pkgs.vimPlugins; [ vim-cue ];
      vam.pluginDictionaries = [
        {
          names = [
            "fugitive"
            "splice-vim"
            "vim-nix"
            "Syntastic"
            # "vim-wakatime"
          ] ++ optional config.programs.vim.fat "YouCompleteMe";
        }
      ];
    };
  };
in
{
  options = {
    programs.vim.fat = mkOption {
      type = types.bool;
      default = true;
      description = "Include vim modules that consume a lot of disk space";
    };
  };
  config = {
    environment.systemPackages = [ myVim ];
    environment.shellAliases.vi = "vim";
    environment.variables.EDITOR = "vim";
    programs.bash.shellAliases = {
      vi = "vim";
    };
  };
}
