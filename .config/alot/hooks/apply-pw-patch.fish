#!/usr/bin/env fish

# store stdin from alot into $msgid
read msgid

# change into same directory as this script
cd (dirname (status filename))
set pwpath (pwd)

# derive Patch ID from message-id
set id (./pwclient list -a no -f '%{id} %{msgid} %{state}' -m "<$msgid>" | cut -d' ' -f1)

cd /Volumes/Workspace/linux
#eval $pwpath/pwclient git-am -s $id
#and git filter-branch -f --msg-filter "cat - && echo 'Link: lkml.kernel.org/r/$msgid'" HEAD^..HEAD

# hack to get Series ID from Patch ID since pwclient doesn't know about Series
set series (git-pw patch show $id | grep Series | cut -d' ' -f8)

git-pw series apply $series

exit 0
