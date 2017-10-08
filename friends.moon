
friend "Aleks.example", {
	status: "asked" -- { "asked", "received", "true friend" }
}

friend "LJF.example", {
	status: "received" -- { "asked", "received", "true friend" }
}

friend "Jambo.example", {
	status: "true friend" -- { "asked", "received", "true friend" }
	wants: { "helpsTo/nsd", "helpsWith/nsd", "helpsWith/borg", "helpsTo/borg" }
	given: { "helpsTo/nsd", "helpsWith/nsd", "helpsWith/borg", "helpsTo/borg" }
}

