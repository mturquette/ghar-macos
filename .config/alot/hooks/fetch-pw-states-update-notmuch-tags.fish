#!/usr/bin/env fish

# change into same directory as this script
cd (dirname (status filename))

# iterate through unarchived patches, syncing patch status as a notmuch tag
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

	# sometimes we hit msgid's that patchwork knows about, but notmuch does
	# not, for whatever reason. skip these msgid's and continue the loop if
	# this happens.
	set thread (notmuch search --output=threads id:$msgid)
	if [ "$thread" = '' ]
		continue
	end

	set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

	if [ "$old_state" = '' ]
		notmuch tag +$tag -"pw/archived" -- id:$msgid
		notmuch tag +pw-clk -needs-review -- $thread
		#notmuch tag +pw-clk -- thread:(notmuch search --output=threads id:"$msgid" | sed s/thread://)
	else if [ "$old_state" != "$tag" ]
		notmuch tag -$old_state +$tag -"pw/archived" -- id:$msgid
		notmuch tag +pw-clk -needs-review -- $thread
	end

end

# iterate through archived patches, syncing patch status as a notmuch tag as
# well as tagging the message as pw/archived
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

	# sometimes we hit msgid's that patchwork knows about, but notmuch does
	# not, for whatever reason. skip these msgid's and continue the loop if
	# this happens.
	set thread (notmuch search --output=threads id:$msgid)
	if [ "$thread" = '' ]
		continue
	end

	set old_state (notmuch search --output=tags id:$msgid | grep "^pw/")

	if [ "$old_state" = '' ]
		notmuch tag +$tag +"pw/archived" -- id:$msgid
		notmuch tag +pw-clk -- $thread
	else if [ "$old_state" != "$tag" ]
		notmuch tag -$old_state +$tag +"pw/archived" -- id:$msgid
		notmuch tag +pw-clk -- $thread
	end
end

exit 0
