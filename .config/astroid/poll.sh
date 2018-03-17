#!/usr/bin/env fish

# prefix lines with 'and' to exit script on first command failure
# a `set -e` equivalent would be nice, but fish is still working on it:
# https://github.com/fish-shell/fish-shell/issues/805

cd ~/.mail/baylibre/
and gmi pull
and ~/.config/alot/hooks/fetch-pw-states-update-notmuch-tags.fish
and gmi push
