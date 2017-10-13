colors = require "term.colors"

class
	new: (name, opt) =>
		unless name
			error "missing 'name' argument", 0

		@name = name

		-- possible status are: received, asked, true friend
		@status = opt.status or "unknown"
		@configs = opt.configs or {}

		@givenTokens = opt.given or opt.givenTokens or {}
		@wantsTokens = opt.wants or opt.wantsTokens or {}

		-- Tokens that are both “given” and “wanted”.
		@validatedTokens = [token for token in *@givenTokens when @\wants token]

	configs: (service) =>
		for k,v in *(pairs @configs)
			if k == service
				return true
		false

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

	str: =>
		printStr = "#{@name}: (friendship #{@status}): "

		unless #@validatedTokens == 0
			printStr ..= "(wants + given): "
		for token in *@validatedTokens
			printStr ..= "#{token},"

		unless #@wantsTokens == 0
			printStr ..= "; (wants): "
		for token in *@wantsTokens
			printStr ..= "#{token},"

		unless #@givenTokens == 0
			printStr ..= "; (given): "
		for token in *@givenTokens
			printStr ..= "#{token},"

		printStr


	print: =>
		printStr = "#{@name}: "

		color = switch @status
			when "true friend"
				colors.green
			when "asked"
				colors.yellow
			when "received"
				colors.blue
			else
				(...) -> ...

		printStr ..= color " (friendship #{@status})"

		for token in *@validatedTokens
			printStr ..= "\n\t(wants + given): " .. colors.green("#{token}")
		for token in *@wantsTokens
			printStr ..= "\n\t(wants): " .. colors.yellow("#{token}")
		for token in *@givenTokens
			printStr ..= "\n\t(given): " .. colors.blue("#{token}")


		if @configs
			for i,s in pairs(@configs)
				if s
					for j,v in pairs(s)
						printStr ..= "\n\t\tmy configuration of #{j} is:  #{require("pl.pretty").write v}"
				
		print printStr
