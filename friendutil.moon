module "friendutil", package.seeall
export *

importFriends = (friendPath) ->
	file, reason = io.open friendPath, "r+"

	unless file
		-- print "warning: friends cannot be reached :(", "path: '#{friendPath}'"
		-- print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	_, data = serpent.load file\read "*all"
	file\close!
	data

exportFriends = (friend, friendPath) ->
	file, reason = io.open friendPath, "w"

	unless file
		print "warning: friend cannot be exported :(", "path: '#{friendPath}'"
		print "         ... reason: #{reason}"
		return

	serpent = require "serpent"
	file\write serpent.dump friend
	file\close!

