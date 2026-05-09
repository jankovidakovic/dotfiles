- files in `plugin/` get sourced automatically
- files in `lua/` do not get sourced automatically (need to be sourced manually by `require`)
- per-filetype config is sourced automatically from `ftplugin/<filetype>.lua`

## Nuke and reinstall

Remove all generated nvim data to start fresh (config is preserved):

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
``

Then open nvim and let lazy.nvim reinstall plugins. Run `:TSInstall` for your languages afterward.
