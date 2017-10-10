#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

json = require "json"

-- io.stderr\write "nyaa?\n"
line = io.stdin\read "*line"
while line
	io.stderr\write line, "\n"
	io.stdout\flush!
	switch line
		when "\"let's be friends\""
			-- is this person a (true) friend?
			-- read friends file

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

	line = io.read "*line"

io.stdout\write '"See you! \\o_"\n'
io.stdout\flush!

