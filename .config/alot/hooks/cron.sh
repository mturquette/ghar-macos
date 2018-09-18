#!/usr/bin/env fish

echo >> /tmp/gmailieer_patchwork_notmuch.log
echo >> /tmp/gmailieer_patchwork_notmuch.log

echo $PATH >> /tmp/gmailieer_patchwork_notmuch.log
#set PATH ~/.config/alot/hooks:~/src/gmailieer:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
set PATH ~/.config/alot/hooks ~/src/gmailieer $PATH
echo $PATH >> /tmp/gmailieer_patchwork_notmuch.log

#set -e
cd ~/.mail/baylibre/

and date >> /tmp/gmailieer_patchwork_notmuch.log
gmi pull >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

# fetch patwork patch status and convert into notmuch tags
and date >> /tmp/gmailieer_patchwork_notmuch.log
fetch-pw-states-update-notmuch-tags.fish >> /tmp/gmailieer_patchwork_notmuch.log 2>&1

# tag whole thread with pw-clk if a single message has that tag
and date >> /tmp/gmailieer_patchwork_notmuch.log
for thread in (notmuch search --output=threads tag:new);
	if notmuch search --output=tags $thread | grep pw-clk
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

notmuch tag -new -- tag:new >> /tmp/gmailieer_patchwork_notmuch.log 2>&1
