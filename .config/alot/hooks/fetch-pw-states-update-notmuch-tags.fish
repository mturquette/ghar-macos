#!/usr/bin/env fish

# change into same directory as this script
cd (dirname (status filename))

# iterate through unarchived patches, syncing patchwork state as notmuch tags
for patch in (./pwclient list -a no -f '%{id} %{msgid} %{state}')
	# parse patchwork id and msgid and save them
	set id (echo $patch | cut -d' ' -f1)
	set msgid (echo $patch | cut -d' ' -f2 | sed -e 's/<//' -e 's/>//' )

	# parse patchwork state and generate new notmuch tag
	switch $patch
		case '*New'
			set tag 'pw/new'
		case '*Under Review'
			set tag 'pw/under review'
		case '*Accepted'
			set tag 'pw/accepted'
		case '*Rejected'
			set tag 'pw/rejected'
		case '*RFC'
			set tag 'pw/rfc'
		case '*Not Applicable'
			set tag 'pw/not applicable'
		case '*Changes Requested'
			set tag 'pw/changes requested'
		case '*Awaiting Upstream'
			set tag 'pw/awaiting upstream'
		case '*Superseded'
			set tag 'pw/superseded'
		case '*Deferred'
			set tag 'pw/deferred'
	end

	set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

	if [ "$old_state" = '' ]
		notmuch tag +$tag $review -"pw/archived" -- id:$msgid
		notmuch tag +pw-clk (notmuch search --output=threads id:$msgid)"
	else if [ "$old_state" != "$tag" ]
		notmuch tag -$old_state +$tag $review -"pw/archived" -- id:$msgid
		notmuch tag +pw-clk (notmuch search --output=threads id:$msgid)"
	end

end

# iterate through archived patches, marking with the pw/archived tag
# i guess we could sync final pw state here but who cares...
for patch in (./pwclient list -a yes -f '%{id} %{msgid} %{state}')
	# parse patchwork id and msgid and save them
	set id (echo $patch | cut -d' ' -f1)
	set msgid (echo $patch | cut -d' ' -f2 | sed -e 's/<//' -e 's/>//' )

	# sync pw state for comnpleteness. we really care about archived state
	# though...
	switch $patch
		case '*New'
			set tag 'pw/new'
		case '*Under Review'
			set tag 'pw/under review'
		case '*Accepted'
			set tag 'pw/accepted'
		case '*Rejected'
			set tag 'pw/rejected'
		case '*RFC'
			set tag 'pw/rfc'
		case '*Not Applicable'
			set tag 'pw/not applicable'
		case '*Changes Requested'
			set tag 'pw/changes requested'
		case '*Awaiting Upstream'
			set tag 'pw/awaiting upstream'
		case '*Superseded'
			set tag 'pw/superseded'
		case '*Deferred'
			set tag 'pw/deferred'
	end

	set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

	if [ "$old_state" = '' ]
		notmuch tag +$tag +"pw/archived" -- id:$msgid
		notmuch tag +pw-clk (notmuch search --output=threads id:$msgid)"
	else if [ "$old_state" != "$tag" ]
		notmuch tag -$old_state +$tag +"pw/archived" -- id:$msgid
		notmuch tag +pw-clk (notmuch search --output=threads id:$msgid)"
	end
end

exit 0
