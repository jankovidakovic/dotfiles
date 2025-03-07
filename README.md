# Dotfiles using dotbot

## Installation

```bash
git clone git@github.com:jankovidakovic/dotfiles.git
cd dotfiles
./install
```

## Packages

- `npm` -- needed for `pyright` to work
- `ghcup` -- needed to install `haskell-language-server`
- `rg` and `fd` -- needed for better telescope

- need to find a way how to _optionally_ install language servers
- probably some kind of a lazy install? e.g. install when the filetype is first opened in neovim
    - lazy.nvim can probably do this
