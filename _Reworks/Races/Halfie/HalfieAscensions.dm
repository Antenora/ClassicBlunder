
/mob/proc/halfieClassSelection()
	switch(prompt("What side do you feel more in tune with?", "Class Selection", list("Human","Both","Saiyan")))
		if("Human")
			Class = "Desperate"
		if("Both")
			Class = "Effecient"
		if("Saiyan")
			Class = "Brutal"

/mob/proc/GetBrutalize()
	if(passive_handler.Get("Brutalize"))
		. = passive_handler.Get("Brutalize") / 10
	else
		return 0