
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

-- Lua implementation of PHP scandir function
scandir = (directory) ->
	t = {}
    pfile = io.popen "ls -a #{directory}"
    for filename in pfile\lines!
        table.insert t, filename
    pfile\close!
    t

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
	print "accepting #{arguments.friendname} as a true friend"

if arguments.list
	print "listing friends"
	for i in *scandir "#{cachePath}/friend_*"
		myfriend = friendutil.importFriends i
		f = Friend myfriend.name, myfriend
		f\print!
