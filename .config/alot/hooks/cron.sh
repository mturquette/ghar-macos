#!/bin/bash

PATH=~/.config/alot/hooks:~/src/gmailieer:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

set -e
cd ~/.mail/baylibre/
gmi pull >> /tmp/gmailieer_patchwork_notmuch.log 2>&1 &
fetch-pw-states-update-notmuch-tags.fish >> /tmp/gmailieer_patchwork_notmuch.log 2>&1 &
gmi push >> /tmp/gmailieer_patchwork_notmuch.log 2>&1 &
notmuch tag -new -- tag:new >> /tmp/gmailieer_patchwork_notmuch.log 2>&1 &
