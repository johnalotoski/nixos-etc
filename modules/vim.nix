{
  self,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (self.inputs.neovim-flake.packages.x86_64-linux) neovim;

  vimPkgs = import self.inputs.nixpkgs {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  myVim = pkgs.vim_configurable.customize {
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
        let g:syntastic_go_checkers = ['go', 'golint', 'errcheck']
        let g:syntastic_mode_map = { "mode": "active", "passive_filetypes": ['go'] }
        let g:syntastic_python_python_exec = 'python3'
        let g:syntastic_python_checkers = ['flake8']
        let g:syntastic_python_flake8_post_args='--ignore=E203,E501,W503'

        let g:go_fmt_command = "goimports"
        let g:go_highlight_functions = 1
        let g:go_highlight_methods = 1
        let g:go_highlight_structs = 1
        let g:go_highlight_operators = 1
        let g:go_highlight_build_constraints = 1
        let g:go_list_type = "quickfix"

        autocmd Filetype haskell set foldmethod=indent foldcolumn=2 softtabstop=2 shiftwidth=2
      '';
      plug.plugins = with vimPkgs.vimPlugins; [
        splice-vim
        syntastic
        vim-cue
        vim-fugitive
        vim-go
        vim-nix
        YouCompleteMe
      ];
    };
  };

  golines = pkgs.buildGoModule rec {
    pname = "golines";
    version = "0.9.0";

    src = pkgs.fetchFromGitHub {
      owner = "segmentio";
      repo = "golines";
      rev = "v${version}";
      sha256 = "sha256-BUXEg+4r9L/gqe4DhTlhN55P3jWt7ZyWFQycO6QePrw=";
    };

    vendorHash = "sha256-sEzWUeVk5GB0H41wrp12P8sBWRjg0FHUX6ABDEEBqK8=";

    nativeBuildInputs = [pkgs.installShellFiles];
  };
in {
  environment.systemPackages = with vimPkgs; [
    go_1_21
    golint
    gopls
    golines
    errcheck
    gotags
    gotools
    myVim
    neovim
    watchexec
  ];
  environment.shellAliases.vi = "vim";
  environment.variables.EDITOR = "vim";
  programs.bash.shellAliases = {
    vi = "vim";
  };
}
