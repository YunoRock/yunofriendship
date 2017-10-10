#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

json = require "json"

Friend = require("friend")

-- FIXME
cachePath = "/tmp"

require "friendutil"

line = io.stdin\read "*line"
while line

	-- -- FIXME: DEBUG
	-- io.stderr\write line, "\n"
	-- io.stdout\flush!

	if line\match "\"let's be friends, I'm .*\""
		-- is this person a (true) friend?
		-- read friends file

		name = string.gmatch(line, "\"let's be friends, I'm (%w+)\"")
		friendname = name!
		-- print "my friend ", friendname

		-- search for a friend
		friendPath = "#{cachePath}/friend_#{friendname}.moon"
		myfriend = friendutil.importFriends friendPath

		if myfriend
			switch myfriend.status
				when "asked", "true friend"
					io.stdout\write "\"friendship is magic\"\n"
					io.stdout\flush!
				when "received"
					io.stdout\write "\"let me think about it\"\n"
					io.stdout\flush!
				else
					print "unknown?"
		else
			-- if not present: write tmp friend file
			-- TODO: create friend
			-- "Ok let's make a friend"
			f = Friend friendname, {status: "received"}
			f\print!
			friendutil.exportFriends f, friendPath

	line = io.read "*line"

io.stdout\write '"See you! \\o_"\n'
io.stdout\flush!

