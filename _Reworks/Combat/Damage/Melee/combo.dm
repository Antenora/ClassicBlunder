/mob/proc/progressCombo(d)
	var/obj/Skills/Queue/q = AttackQueue
	if(q)
		if(q.Combo && !(q.Counter + q.CounterTemp))
			if(!Target || Target == src)
				src << "You have no target to combo with."
				return FALSE
			if(q.ComboPerformed>0)
				if(get_dist(src, Target) > 1)
					var/na_save = NextAttack
					NextAttack = world.time + 100
					QueueDashTo(Target, max(q.Warp, 3))
					NextAttack = na_save
					if(KO || Stunned || (Stasis > 0) || Suspended)
						return FALSE
			if(q.ComboPerformed<=q.Combo)
				q.ComboPerformed++
			else
				ClearQueue()
			if(q.ComboHitMessages.len>0)
				var/msg = q.ComboHitMessages[q.ComboPerformed]
				if(msg)
					if(q.TextColor)
						OMessage(10, "<font color='[q.TextColor]'><b>[src] [msg]</b></font color>", "[src]([key]) hit with [q]")
					else
						OMessage(10, "<font color='[Text_Color]'><b>[src] [msg]</b></font color>", "[src]([key]) hit with [q]")
			return d / 5
		else return d
	else return d