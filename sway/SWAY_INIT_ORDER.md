# Sway initialization order

entrypoint is the `config` file, which is currently ~/dotfiles/sway/config

## theme definitions

$theme = /usr/share/sway/themes/matcha-green
- definitions = $theme/definitions
-> this seems to be the colorscheme only

## sourcing etc definitions

etc definitions -- default definitions that make sure the sway is configured even if user definitions are missing
- can be overriden by user definitions

definitions = defines variables that are later used by sway to run stuff

- keybindings for up and down (and mod key)
- bindsym with --to_code
- set $term, $bluetooth, #brightness and such variables
- include /etc/sway/autostart -> okay lets look at that

## /etc/sway/autostart

- it was missing, as I imported it into .config/sway/etc/autostart
    - changed the path in definitions -- still nothing

- autostart just defines other things, nothing useful there

- the rest of definitions also just defines stuff

## sourcing user-space definitions -- .config/sway/definitions.d
- also just definitions

# sourcing modes -- /etc/sway/modes

-- this is what actually binds keystrokes to defined variables

okay, found the bug -- $term was set to `footclient`, but `footclient` doesnt exist actually
- set this to `foot` and we're good
