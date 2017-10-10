#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

json = require "json"

Friend = require("friend")

cachePath = "/tmp"

importFriends = (friendPath) ->
	file, reason = io.open friendPath, "r"

	unless file
		print "warning: friends cannot be reached :(", "path: '#{friendPath}'"
		print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	_, data = serpent.load file\read "*all"
	file\close!

	if data
		print "import friends: ", data\dump!
	else
		print "no data, empty file"
	data

exportFriends = (friend, friendPath) ->
	file, reason = io.open friendPath, "w"

	unless file
		print "warning: friend cannot be exported :(", "path: '#{friendPath}'"
		print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	file\write serpent.dump friend
	file\close!


line = io.stdin\read "*line"
while line

	-- FIXME: DEBUG
	io.stderr\write line, "\n"
	io.stdout\flush!

	if line\match "\"let's be friends, I'm .*\""
		-- is this person a (true) friend?
		-- read friends file

		name = string.gmatch(line, "\"let's be friends, I'm (%w+)\"")
		friendname = name!
		-- print "my friend ", friendname

		-- search for a friend
		friendPath = "#{cachePath}/friend_#{friendname}.moon"
		myfriend = importFriends friendPath

		if myfriend
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
			f = Friend friendname, {}
			f\print!
			exportFriends f, friendPath

	line = io.read "*line"

io.stdout\write '"See you! \\o_"\n'
io.stdout\flush!

