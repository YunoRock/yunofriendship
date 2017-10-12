
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

scandir = (directory) ->
	t = {}
    pfile = io.popen "ls -a #{directory}"
    for filename in pfile\lines!
        table.insert t, filename
    pfile\close!
    t

parser = with argparse "answerfriends", "Tell your friends you love them!"
	with \command "list"
		\description "list all your friends!"
	with \command "acceptfriend"
		with \argument "friendname"
			\args 1
		\description "tell your friend you accept him/her! <3"
	with \command "iwant"
		with \argument "friendname"
			\args 1
		with \argument "tokenList"
			\args 1
		\description "give a friend some tokens (to help him/her or asking for help)"
	with \command "newfriend"
		with \argument "friendname"
			\args 1
		\description "create a new friend (erase existing one), debug tool"

arguments = parser\parse!

if arguments.acceptfriend
	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	myfriend = friendutil.importFriends friendPath
	myfriend.status = "true friend"
	friendutil.exportFriends myfriend, friendPath
	print "accepting #{arguments.friendname} as a true friend"

if arguments.iwant
	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	myfriend = friendutil.importFriends friendPath

	myfriend.given = {} -- TODO
	tokens = string.gmatch arguments.tokenList, "([^,]+)"
	for token in tokens
		table.insert myfriend.given, token

	f = Friend myfriend.name, myfriend
	friendutil.exportFriends myfriend, friendPath
	print "our friend: #{f\str!}"

if arguments.list
	print "listing friends"
	for i in *scandir "#{cachePath}/friend_*"
		myfriend = friendutil.importFriends i
		f = Friend myfriend.name, myfriend
		f\print!

if arguments.newfriend
	print "new friend: #{arguments.friendname}"

	friendPath = "#{cachePath}/friend_#{arguments.friendname}.moon"
	f = Friend arguments.friendname, {status: "received"}
	friendutil.exportFriends f, friendPath
	print "our friend: #{f\str!}"
