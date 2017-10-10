#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

json = require "json"

-- friendClass = require "friend"

importFriends = (friendPath) ->
	file, reason = io.open friendPath, "r"

	unless file
		print "warning: friends cannot be reached :(", "path: '#{friendPath}'"
		print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	_, data = serpent.load file\read "*all"
	file\close!

	print "import friends: ", data\dump!
	data

exportFriends = (friends, friendPath) ->
	file, reason = io.open friendPath, "w"

	unless file
		print "warning: friends cannot be exported :(", "path: '#{friendPath}'"
		print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	file\write serpent.dump friends
	file\close!


-- io.stderr\write "nyaa?\n"
line = io.stdin\read "*line"
while line

	-- FIXME: DEBUG
	io.stderr\write line, "\n"
	io.stdout\flush!

	if line\match "\"let's be friends, I'm .*\""
		-- is this person a (true) friend?
		-- read friends file

		print "line: ", line

		name = string.gmatch(line, "\"let's be friends, I'm (%w+)\"")
		friendname = name!
		print "my friend ", friendname

		myfriends = importFriends "friend_#{friendname}.moon"

		-- search for a friend
		-- friends = 
		-- success, friend = friends:search 'friendname'

		if success
			switch friend.status
				when "asked", "true friend"
					io.stdout\write "\"friendship is magic\"\n"
					io.stdout\flush!
				when "received"
					-- TODO
					io.stdout\write "\"let me think about it\"\n"
					io.stdout\flush!
		else
			-- if not present: write tmp friend file
			-- TODO: create friend
			print "Ok let's make a friend -- TODO"

	line = io.read "*line"

io.stdout\write '"See you! \\o_"\n'
io.stdout\flush!

