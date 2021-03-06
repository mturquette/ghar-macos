#!/usr/bin/env fish

echo >> /tmp/gmailieer_patchwork_notmuch.log
echo >> /tmp/gmailieer_patchwork_notmuch.log

set PATH ~/.config/alot/hooks $PATH
#set PATH ~/.config/alot/hooks ~/src/gmailieer $PATH

#set -e
cd ~/.mail/baylibre/

date >> /tmp/gmailieer_patchwork_notmuch.log
gmi pull >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
set ret $status; if test $ret -ne 0; exit $ret; end

# fetch patwork patch status and convert into notmuch tags
date >> /tmp/gmailieer_patchwork_notmuch.log
fetch-pw-states-update-notmuch-tags.fish >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
set ret $status; if test $ret -ne 0; exit $ret; end

# tag whole thread with pw-clk if a single message has that tag
date >> /tmp/gmailieer_patchwork_notmuch.log
for thread in (notmuch search --output=threads tag:new);
	if notmuch search --output=tags $thread | grep pw-clk > /dev/null
		echo "found pw-clk in $thread" >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
		notmuch tag +pw-clk -- $thread
	else
		echo "did not find pw-clk in $thread" >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
	end
end

#notmuch tag +pw-clk $(notmuch search --output=threads tag:$tag)
#notmuch tag +needs-review -- tag:new and tag:linux-clk and not tag:pw-clk >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

date >> /tmp/gmailieer_patchwork_notmuch.log
gmi push >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
set ret $status; if test $ret -ne 0; exit $ret; end

notmuch tag -new -- tag:new >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
