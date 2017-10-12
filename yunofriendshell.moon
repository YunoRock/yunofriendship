#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

json = require "json"

Friend = require("friend")

-- FIXME
cachePath = "/tmp"

require "friendutil"

-- when asking to be friends: read the friend's file (create one if necessary) then check his status
beFriends = (friendname) ->
	-- print "my friend ", friendname

	-- search for a friend
	friendPath = "#{cachePath}/friend_#{friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	if myfriend
		switch myfriend.status
			when "asked", "true friend"
				io.stdout\write json.encode {answer: "friendship is magic"}
				io.stdout\write "\n"
				io.stdout\flush!
			when "received"
				io.stdout\write json.encode {answer: "let me think about it"}
				io.stdout\write "\n"
				io.stdout\flush!
			else
				io.stdout\write json.encode {answer: "status unknown :("}
				io.stdout\write "\n"
				io.stdout\flush!
	else
		-- if not present: write tmp friend file
		f = Friend friendname, {status: "received"}
		friendutil.exportFriends f, friendPath

		io.stdout\write json.encode {answer: "new friend: #{f\str!}"}
		io.stdout\write "\n"
		io.stdout\flush!

shareTokens = (friendReq) ->

	friendname = friendReq.name

	unless friendReq.wants
		io.stdout\write json.encode {answer: "You didn't provide useful info! :("}
		io.stdout\write "\n"
		io.stdout\flush!
		return

	-- search for a friend
	friendPath = "#{cachePath}/friend_#{friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	-- keep state of what your friend wants

	if friendReq.wants
		print "here what your friend wants: " .. json.encode friendReq.wants

	unless myfriend.wants
		myfriend.wants = {}

	for token in *friendReq.wants
		print "insert " .. token .. "\n"
		table.insert myfriend.wants, token

	for token in *myfriend.wants
		print "should be seen: " .. token

	f = Friend myfriend.name, myfriend

	friendutil.exportFriends f, friendPath

	io.stdout\write json.encode {answer: "here my friend: #{f\str!}"}
	io.stdout\write "\n"
	io.stdout\flush!

-- main code
while true

	line = io.read "*line"

	unless line
		print "line == ''"
		break

	decodedline = {}

	success, decodedline = pcall -> json.decode line
	-- if json.decode crashes, please continue
	unless success
		io.stdout\write json.encode {answer: "I can't decrypt what you're saying!"}
		io.stdout\write "\n"
		io.stdout\flush!
		continue

	unless decodedline
		decodedline = {}
		io.stdout\write json.encode {answer: "You didn't provide useful info! :("}
		io.stdout\write "\n"
		io.stdout\flush!
		continue

	-- your friend should send his/her name each time
	unless decodedline.name
		io.stdout\write json.encode {answer: "I don't know who you are my friend :("}
		io.stdout\write "\n"
		io.stdout\flush!
		continue

	-- select the right command to execute
	-- TODO: for every command other than 'let's be friends' you should send the shared secret
	if decodedline.command and decodedline.command == "let's be friends"
		beFriends decodedline.name
	elseif decodedline.command and decodedline.command == "I know what we can do!"
		shareTokens decodedline
	else
		io.stdout\write json.encode {answer: "You didn't provide useful info! :("}
		io.stdout\write "\n"
		io.stdout\flush!

io.stdout\write '"See you! \\o_"\n'
io.stdout\flush!

