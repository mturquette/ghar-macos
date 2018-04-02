#!/usr/bin/env fish

# store stdin from alot into $msgid
read msgid

# get patch state from cmdline
set state $argv

switch $state
	case 'New'
		set tag 'pw/new'
	case 'Under Review'
		set tag 'pw/under review'
	case 'Accepted'
		set tag 'pw/accepted'
	case 'Rejected'
		set tag 'pw/rejected'
	case 'RFC'
		set tag 'pw/rfc'
	case 'Not Applicable'
		set tag 'pw/not applicable'
	case 'Changes Requested'
		set tag 'pw/changes requested'
	case 'Awaiting Upstream'
		set tag 'pw/awaiting upstream'
	case 'Superseded'
		set tag 'pw/superseded'
	case 'Deferred'
		set tag 'pw/deferred'
end

# change into same directory as this script
cd (dirname (status filename))

# determine old state tag
set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

# update local notmuch tag
# this is sugar; we always overwrite local tags when syncing patwork state
if [ "$old_state" = '' ]
	notmuch tag +$tag -- id:$msgid
else if [ "$old_state" != "$tag" ]
	notmuch tag -$old_state +$tag -- id:$msgid
end

# derive patchwork id from message-id
set id (./pwclient list -a no -f '%{id} %{msgid} %{state}' -m "<$msgid>" | cut -d' ' -f1)

# update patchwork state
#eval $pwpath/pwclient update -s "'$state'" $id
./pwclient update -s $state $id
