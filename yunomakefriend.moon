
json = require "json"
process = require "process"
argparse = require "argparse"

parser = with argparse "yunomakefriend", "Time to make self-hosted friends with YunoRock."
	with \argument "domain"
		\args 1

arguments = parser\parse!


ssh, reason = process.exec "ssh", {"anonymous@#{arguments.domain}"}

unless ssh
	print reason
	os.exit 1

sshInput = ""

while process.waitpid ssh\pid!, process.WNOHANG
--	s = ssh\stderr!
--	if s
--		io.stderr\write "ssh: ", s

	s = ssh\stdout!
	if s
		sshInput ..= s

		while sshInput\match "\n"
			line = sshInput\match "^[^\n]*"

			sshInput = sshInput\sub line\len! + 2, sshInput\len!

			input = json.decode line

			unless input
				print "line: ", line

			print "received #{require("pl.pretty").write input}"

			if input == "hi"
				print "sending friendship request™"
				ssh\stdin json.encode("let's be friends").."\n"

