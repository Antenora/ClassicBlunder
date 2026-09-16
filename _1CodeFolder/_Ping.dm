mob
	var/tmp/PingCooldown
	verb
		Ping()
			set category="Other"
			set hidden = 1
			if(!(world.time > usr.verb_delay)) return
			usr.verb_delay=world.time+1
			var/mob/m = PromptArg(usr, args, 1, "Ping", "view:15:mob", 1)
			if(isnull(m)) return
			if(!src.PingCooldown)
				if(m.client)
					winset(m, "mainwindow", "flash=-1")
					m << "<b><font size=+1>[src] has pinged you!</font size></b>"
					src << "You've pinged [m]."
					src.PingCooldown=1
					spawn(20)
						src.PingCooldown=0