
friend "Aleks.example", {
	status: "asked" -- { "asked", "received", "true friend" }
}

friend "LJF.example", {
	status: "received" -- { "asked", "received", "true friend" }
}

friend "Jambo.example", {
	status: "true friend" -- { "asked", "received", "true friend" }
	wants: { "help/nsd", "beHelped/nsd", "beHelped/borg", "help/borg" }
	given: { "help/nsd", "beHelped/nsd", "beHelped/borg", "help/borg" }
}

