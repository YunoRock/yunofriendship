
json = require "json"
process = require "process"
argparse = require "argparse"
moonscript = require "moonscript"
util = require "moonscript.util"
colors = require "term.colors"

Friend = require("friend")

require "friendutil"

-- FIXME
cachePath = "/tmp"

scandir = (directory) ->
	t = {}
    pfile = io.popen "ls -a #{directory}"
    for filename in pfile\lines!
        table.insert t, filename
    pfile\close!
    t

getFriend = (friendname) ->
	for i in *scandir "#{cachePath}/friend_*"
		myfriend = friendutil.importFriends i
		if myfriend
			if myfriend.name == friendname
				f = Friend myfriend.name, myfriend
				f\print!
				return f
		else
			return

parser = with argparse "yunomakefriend", "Tell your friends you love them!"
	with \command "list"
		\description "LOCAL: list all your friends!"
	with \command "acceptfriend"
		with \argument "friendname"
			\args 1
		\description "LOCAL: accept a friend! <3  (done in local, no communication)"
	with \command "iwant"
		with \argument "myname"
			\args 1
		with \argument "friendname"
			\args 1
		with \argument "tokenList"
			\args 1
		\description "LOCAL: give a friend some tokens to help him/her or asking for help (done in local, no communication)"
	with \command "newfriend"
		with \argument "myname"
			\args 1
		with \argument "friendname"
			\args 1
		\description "LOCAL: create a new friend (or erase an existing one), debug tool"
	with \command "request"
		with \argument "myname"
			\args 1
		with \argument "domain"
			\args 1
		\description "REMOTE: let's ask someone to be friends! (request a friend through ssh anonymous@domain)"
	with \command "sendtokens"
		with \argument "myname"
			\args 1
		with \argument "domain"
			\args 1
		\description "REMOTE: send the tokens (what you are willing to do and accept) to a friend! (through ssh anonymous@domain)"
	with \command "sendtokensdebug"
		with \argument "myname"
			\args 1
		with \argument "domain"
			\args 1
		with \argument "password"
			\args 1
		with \argument "given"
			\args 1
		\description "REMOTE, DEBUG: send the tokens (what you are willing to do and accept) to a friend! (through ssh anonymous@domain)"
	with \command "letsdothis"
		with \argument "myname"
			\args 1
		with \argument "domain"
			\args 1
		\description "REMOTE: send the service configurations to a friend! (through ssh anonymous@domain)"

arguments = parser\parse!

if arguments.acceptfriend
	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	myfriend = friendutil.importFriends friendPath
	myfriend.status = "true friend"
	friendutil.exportFriends myfriend, friendPath
	print "accepting #{arguments.friendname} as a true friend"

if arguments.iwant
	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	myfriend.given = {} -- TODO
	tokens = string.gmatch arguments.tokenList, "([^,]+)"
	for token in tokens
		table.insert myfriend.given, token

	f = Friend myfriend.name, myfriend
	friendutil.exportFriends myfriend, friendPath
	print "our friend: #{f\str!}"

if arguments.list
	print "listing friends"
	for i in *scandir "#{cachePath}/friend_*"
		myfriend = friendutil.importFriends i
		f = Friend myfriend.name, myfriend
		f\print!

if arguments.newfriend
	print "new friend: #{arguments.friendname}"

	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	f = Friend arguments.friendname, {status: "received"}
	friendutil.exportFriends f, friendPath
	print "our friend: #{f\str!}"

sshInput = ""
readSSHLine = (ssh) ->
	coroutine.wrap ->
		-- print "BEFORE WHILE"
		while process.waitpid ssh\pid!, process.WNOHANG

		-- 	print "BEFORE REQ STDERR"
		-- 	s, err, again = ssh\stderr! -- data, error string (nil on success), again (true if got a EAGAIN or EWOULDBLOCK)
		-- 	print "JUST AFTER REQ STDERR"
		-- 	if s
		-- 		io.stderr\write "ssh: ", s
		-- 	elseif err
		-- 		io.stderr\write "ERROR: ", err
		-- 	elseif again
		-- 		io.stderr\write "EAGAIN or EWOULDBLOCK"

			-- print "BEFORE READING STDOUT"
			s = ssh\stdout!
			-- print "AFTER READING STDOUT"
			if s
				sshInput ..= s

				while sshInput\match "\n"
					line = sshInput\match "^[^\n]*"

					sshInput = sshInput\sub line\len! + 2, sshInput\len!

					coroutine.yield line

sshWhile = (domain, greetingmsg) ->

	ssh, reason = process.exec "ssh", {"anonymous@#{domain}"}

	unless ssh
		print reason
		os.exit 1

	for line in readSSHLine ssh
		if line\match greetingmsg
			break
		else
			print "MOTD: ", line
	ssh


if arguments.request
	-- endpoint ssh and the greeting message
	ssh = sshWhile arguments.domain, '"I am a friendly server"'

	-- after the motd, let's send our request
	request = {
		command: 	"let's be friends!"
		name: 		arguments.myname
	}

	-- PRINT DEBUG
	print "our request is #{json.encode(request)}"

	ssh\stdin json.encode(request).."\n"
	-- print "AFTER OUR REQUEST"

	for line in readSSHLine ssh
		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			continue

		print "received #{require("pl.pretty").write input}"
		os.exit 0

-- TODO
if arguments.sendtokens
	-- endpoint ssh and the greeting message
	ssh = sshWhile arguments.domain, '"I am a friendly server"'

	-- search a friend
	f = getFriend arguments.domain
	unless f
		print "there is no friend #{arguments.domain}"
		os.exit 1

	request = {
		command: 	"I know what we can do!"
		name: 		arguments.myname
		password:	f.password
		wants:    	f.given
	}

	-- after the motd, let's send the configuration
	ssh\stdin json.encode(request).."\n"

	for line in readSSHLine ssh
		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			os.exit 1

		print "received #{require("pl.pretty").write input}"
		os.exit 0

if arguments.sendtokensdebug
	-- endpoint ssh and the greeting message
	ssh = sshWhile arguments.domain, '"I am a friendly server"'

	-- TODO: do not search for a friend, tokens are given by cmdline

	tokens = string.gmatch arguments.given, "([^,]+)"
	given = {}
	for token in tokens
		table.insert given, token

	request = {
		command: 	"I know what we can do!"
		name: 		arguments.myname
		password:	arguments.password
		wants:    	given
	}

	-- after the motd, let's send the configuration
	print "our request is #{json.encode(request)}"
	ssh\stdin json.encode(request).."\n"

	for line in readSSHLine ssh
		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			os.exit 1

		print "received #{require("pl.pretty").write input}"
		os.exit 0


-- TODO
if arguments.letsdothis
	-- endpoint ssh and the greeting message
	ssh = sshWhile arguments.domain, '"I am a friendly server"'

	-- search a friend
	f = getFriend arguments.domain
	unless f
		print "there is no friend #{arguments.domain}"
		os.exit 1

	request = {
		command: 	"let's do this!"
		name: 		f.name
		password:	f.password
		services: 	f.services
	}

	-- after the motd, let's send the configuration
	ssh\stdin json.encode(request).."\n"

	for line in readSSHLine ssh
		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			os.exit 1

		print "received #{require("pl.pretty").write input}"
