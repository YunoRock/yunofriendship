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
