
json = require "json"
process = require "process"
argparse = require "argparse"

parser = with argparse "yunomakefriend", "Time to make self-hosted friends with YunoRock."
	with \argument "domain"
		\args 1

arguments = parser\parse!

moonscript = require "moonscript"
friends = moonscript.loadfile "friends.moon"


util = require "moonscript.util"
util.setfenv friends, {
	friend: (name, opt) ->
		print "friend of mine: ", name
		print require("pl.pretty").write opt
}


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
	if beyondMotd
		success, input = pcall -> json.decode line
		unless success
			print "message not understood: ", line
			os.exit 1

		print "received #{require("pl.pretty").write input}"

		if input == "hi"
			print "sending friendship request™"
			ssh\stdin json.encode("let's be friends").."\n"
	else
		if line\match '"I am a friendly server"'
			beyondMotd = true
		else
			print "MOTD: ", line
