#!/usr/bin/env moon
io.stdout\write '"I am a friendly server"\n'
io.stdout\flush!

-- io.stderr\write "nyaa?\n"
line = io.stdin\read "*line"
while line
	io.stderr\write line, "\n"
	switch line
		when "\"let's be friends\""
			io.stdout\write "\"friendship is magic\"\n"
			io.stdout\flush!

	line = io.read "*line"

io.stdout\write '"See you! \\o_"\n'

