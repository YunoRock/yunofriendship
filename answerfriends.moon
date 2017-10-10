
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

parser = with argparse "answerfriends", "Tell your friends you love them!"
	\command "list"
	with \command "accept-friendship"
		with \argument "friendname"
			\args 1

arguments = parser\parse!
if arguments.friendname
	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	myfriend = friendutil.importFriends friendPath
	myfriend.status = "true friend"
	friendutil.exportFriends myfriend, friendPath
	print "accepting #{arguments.friendname} has a true friend"
