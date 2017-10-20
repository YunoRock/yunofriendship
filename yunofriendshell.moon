#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

package.moonpath ..= ";/media/fast/perso/yunofriendship/?.moon"

json = require "json"

Friend = require "friend"

-- FIXME
cachePath = "/tmp"

require "friendutil"

say = (jsonMsg) ->
	io.stdout\write jsonMsg
	io.stdout\write "\n"
	io.stdout\flush!

-- when asking to be friends: read the friend's file (create one if necessary) then check his status
beFriends = (friendname) ->
	-- print "my friend ", friendname

	-- search for a friend
	friendPath = "#{cachePath}/friend_#{friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	if myfriend
		switch myfriend.status
			when "asked", "true friend"
				say json.encode {answer: "friendship is magic"}
			when "received"
				say json.encode {answer: "let me think about it"}
			else
				say json.encode {answer: "status unknown :("}
	else
		-- if not present: write tmp friend file
		f = Friend friendname, {status: "received"}
		friendutil.exportFriends f, friendPath
		say json.encode {answer: "new friend!", friend: "#{f\str!}"}

shareTokens = (friendReq) ->

	friendname = friendReq.name

	unless friendReq.wants
		say json.encode {answer: "You didn't provide useful info! :( (what do you want?)"}
		return

	-- search for a friend
	friendPath = "#{cachePath}/friend_#{friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	-- TODO: check passwords
	-- explanations: on the first connection the friend get a password then has to provide it for any further communication

	-- keep state of what your friend wants
	for token in *friendReq.wants
		present = false
		for recordedToken in *myfriend.wantsTokens
			if token == recordedToken
				present = true

		continue if present -- do not add a token twice

		table.insert myfriend.wantsTokens, token

	f = Friend myfriend.name, myfriend
	friendutil.exportFriends f, friendPath
	say json.encode {answer: "ok, here what I want", friend: "#{f\str!}", given: f.givenTokens}

letsdothis = (friendReq) ->

	friendname = friendReq.name

	unless friendReq.configs
		say json.encode {answer: "You didn't provide useful info! :( (what are the services you want to share?)"}
		return

	-- search for a friend
	friendPath = "#{cachePath}/friend_#{friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	-- TODO: check passwords

	-- PRINT DEBUG
	-- if myfriend.configs
	-- 	for i,s in pairs(myfriend.configs)
	-- 		for j,v in pairs(s)
	-- 			print "ALREADY HERE: configuration of key #{j},", "value: #{require("pl.pretty").write v}"

	unless myfriend.configs
		myfriend.configs = {}

	-- replace the confguration of the service if present
	-- print "configuration received: #{require("pl.pretty").write friendReq.configs}"
	for i,s in pairs(friendReq.configs)
		-- TODO: check if provided services are those you are willing to accept
		myfriend.configs[i] = friendReq.configs[i]

		-- -- PRINT DEBUG
		-- for j,v in pairs(s)
		-- 	print "configuration of key #{j},", "value: #{require("pl.pretty").write v}"

	f = Friend myfriend.name, myfriend
	friendutil.exportFriends f, friendPath
	say json.encode {answer: "ok let's do this!", friend: "#{f\str!}"} -- DEBUG: , configs: ["[#{require("pl.pretty").write f.configs[k]}]" for k,v in pairs(f.configs)]



-- main code: see the documentation for further explanations about the protocol
while true

	line = io.read "*line"

	unless line
		break

	decodedline = {}

	success, decodedline = pcall -> json.decode line
	-- if json.decode crashes, please continue
	unless success
		say json.encode {answer: "I can't decrypt what you're saying!"}
		continue

	unless decodedline
		decodedline = {}
		say json.encode {answer: "You didn't provide useful info! :("}
		continue

	-- your friend should send his/her name each time
	unless decodedline.name
		say json.encode {answer: "I don't know who you are my friend :("}
		continue

	-- select the right command to execute
	if decodedline.command and decodedline.command == "let's be friends!"
		beFriends decodedline.name
	elseif decodedline.command and decodedline.command == "I know what we can do!"
		-- your friend should send his/her password each time
		unless decodedline.password
			say json.encode {answer: "Huh, you didn't provide the password :/"}
			continue
		shareTokens decodedline
	elseif decodedline.command and decodedline.command == "let's do this!"
		-- your friend should send his/her password each time
		unless decodedline.password
			say json.encode {answer: "Huh, you didn't provide the password :/"}
			continue
		letsdothis decodedline
	else
		say json.encode {answer: "You didn't provide a good command! :("}



say '"See you! \\o_"'
