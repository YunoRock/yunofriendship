
json = require "json"
process = require "process"
argparse = require "argparse"
moonscript = require "moonscript"
util = require "moonscript.util"
colors = require "term.colors"

parser = with argparse "yunomakefriend", "Time to make self-hosted friends with YunoRock."
	\command "list"
	with \command "request-friendship"
		with \argument "domain"
			\args 1

arguments = parser\parse!

Friend = class
	new: (name, opt) =>
		unless name
			error "missing 'name' argument", 0

		@name = name

		@status = opt.status or "unknown"

		@givenTokens = opt.given or {}
		@wantsTokens = opt.wants or {}

		-- Tokens that are both “given” and “wanted”.
		@validatedTokens = [token for token in *@givenTokens when @\wants token]

	wants: (token) =>
		for e in *@wantsTokens
			if e == token
				return true
		false

	validated: (token) =>
		for e in *@validatedTokens
			if e == token
				return true
		false

	print: =>
		io.write "#{@name}"

		color = switch @status
			when "true friend"
				colors.green
			when "asked"
				colors.yellow
			when "received"
				colors.blue
			else
				(...) -> ...

		io.write color " (friendship #{@status})"

		io.write "\n"

		if @status == "true friend"
			for token in *@validatedTokens
				io.write "  - ", colors.green("#{token}"), " (wants + given)\n"
			for token in *@wantsTokens
				unless @\validated token
					io.write "  - ", colors.yellow("#{token}"), " (wants)\n"
			for token in *@givenTokens
				unless @\validated token
					io.write "  - ", colors.blue("#{token}"), " (given)\n"

friends = do
	code = moonscript.loadfile "friends.moon"

	friends = {}

	util.setfenv code, {
		friend: (name, opt) ->
			table.insert friends, Friend name, opt
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
