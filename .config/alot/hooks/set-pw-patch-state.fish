#!/usr/bin/env fish

# store stdin from alot into $msgid
read msgid

# get patch state from cmdline
set state $argv

switch "$state"
	case 'New'
		set tag 'pw/new'
		set review '+needs-review'
	case 'Under Review'
		set tag 'pw/under review'
		set review '+needs-review'
	case 'Accepted'
		set tag 'pw/accepted'
		set review '-needs-review'
	case 'Rejected'
		set tag 'pw/rejected'
		set review '-needs-review'
	case 'RFC'
		set tag 'pw/rfc'
		set review '-needs-review'
	case 'Not Applicable'
		set tag 'pw/not applicable'
		set review '-needs-review'
	case 'Changes Requested'
		set tag 'pw/changes requested'
		set review '-needs-review'
	case 'Awaiting Upstream'
		set tag 'pw/awaiting upstream'
		set review '-needs-review'
	case 'Superseded'
		set tag 'pw/superseded'
		set review '-needs-review'
	case 'Deferred'
		set tag 'pw/deferred'
		set review '-needs-review'
end

# change into same directory as this script
cd (dirname (status filename))

# determine old state tag
set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

# update local notmuch tag
# this is sugar; we always overwrite local tags when syncing patwork state
if [ "$old_state" = '' ]
	notmuch tag +$tag $review -- id:$msgid
else if [ "$old_state" != "$tag" ]
	notmuch tag -$old_state +$tag $review -- id:$msgid
end

# derive patchwork id from message-id
set id (./pwclient list -a no -f '%{id} %{msgid} %{state}' -m "<$msgid>" | cut -d' ' -f1)

# update patchwork state
#eval $pwpath/pwclient update -s "'$state'" $id
./pwclient update -s "$state" $id
