#!/bin/bash

PATH=~/.config/alot/hooks:~/src/gmailieer:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

echo >> /tmp/gmailieer_patchwork_notmuch.log
echo >> /tmp/gmailieer_patchwork_notmuch.log

set -e
cd ~/.mail/baylibre/

date >> /tmp/gmailieer_patchwork_notmuch.log
gmi pull >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

date >> /tmp/gmailieer_patchwork_notmuch.log
fetch-pw-states-update-notmuch-tags.fish >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

date >> /tmp/gmailieer_patchwork_notmuch.log
gmi push >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

notmuch tag -new -- tag:new >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
