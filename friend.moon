colors = require "term.colors"

class
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

	str: =>
		printStr = "#{@name}: "

		printStr ..= " (friendship #{@status})"

		if @status == "true friend"
			unless #@validatedTokens == 0
				printStr ..= "(wants + given): "
			for token in *@validatedTokens
				printStr ..= "#{token},"

			unless #@wantsTokens == 0
				printStr ..= "; (wants): "
			for token in *@wantsTokens
				-- unless @\validated token
				printStr ..= "#{token},"

			unless #@givenTokens == 0
				printStr ..= "; (given): "
			for token in *@givenTokens
				-- unless @\validated token
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

		printstr ..= color " (friendship #{@status})"

		if @status == "true friend"
			for token in *@validatedTokens
				printStr ..= "  - " .. colors.green("#{token}") .. " (wants + given);"
			for token in *@wantsTokens
				-- unless @\validated token
				printStr ..= "  - " .. colors.yellow("#{token}") .. " (wants);"
			for token in *@givenTokens
				-- unless @\validated token
				printStr ..= "  - " .. colors.blue("#{token}") .. " (given)"

		printStr
