mob
	var/tmp/PingCooldown
	verb
		Ping(var/mob/m in view(15, src))
			set category="Other"
			if(!(world.time > usr.verb_delay)) return
			usr.verb_delay=world.time+1
			if(!src.PingCooldown)
				if(m.client)
					winset(m, "mainwindow", "flash=-1")
					m << "<b><font size=+1>[src] has pinged you!</font size></b>"
					src << "You've pinged [m]."
					src.PingCooldown=1
					spawn(20)
						src.PingCooldown=0