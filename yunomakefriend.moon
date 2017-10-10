
json = require "json"
process = require "process"
argparse = require "argparse"
moonscript = require "moonscript"
util = require "moonscript.util"
colors = require "term.colors"

Friend = require("friend")

parser = with argparse "yunomakefriend", "Time to make self-hosted friends with YunoRock."
	\command "list"
	with \command "request-friendship"
		with \argument "domain"
			\args 1

arguments = parser\parse!

friendClass = require "friend.moon"

friends = do
	code = moonscript.loadfile "myfriends.moon"

	friends = {}

	util.setfenv code, {
		friend: (name, opt) ->
			table.insert friends, friendClass name, opt
	}

	code!

	friends

if arguments.list
	for friend in *friends
		friend\print!
	os.exit 0

ssh, reason = process.exec "ssh", {"anonymous@#{arguments.domain}"}

unless ssh
	print reason
	os.exit 1

sshInput = ""

readSSHLine = (ssh) ->
	coroutine.wrap ->
		while process.waitpid ssh\pid!, process.WNOHANG
			s = ssh\stderr!
			if s
				io.stderr\write "ssh: ", s

			s = ssh\stdout!
			if s
				sshInput ..= s

				while sshInput\match "\n"
					line = sshInput\match "^[^\n]*"

					sshInput = sshInput\sub line\len! + 2, sshInput\len!

					coroutine.yield line


beyondMotd = false
for line in readSSHLine ssh
	unless beyondMotd
		if line\match '"I am a friendly server"'
			beyondMotd = true
		else
			print "MOTD: ", line
	else
		ssh\stdin json.encode("let's be friends").."\n"

		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			os.exit 1

		print "received #{require("pl.pretty").write input}"

		if input == "hi"
			print "sending friendship request™"
			ssh\stdin json.encode("let's be friends").."\n"
