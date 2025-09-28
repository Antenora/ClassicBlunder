/obj/leftOver
	Ooze
		icon='Ichor Turf.dmi'
		icon_state="ground"
		power = 1
		lifetime = 30 SECONDS
		proc_to_call = "AddPoison"
		New(_x,_y,_z, mob/p)
			loc = locate(_x,_y,_z)
			proc_params = list("Value" = power*2, "Attacker" = owner)
			ticking_generic += src
			owner = p
			for(var/mob/m in loc)
				tick_on |= m
			spawn(lifetime) // why . . . .
				if(src)
					ticking_generic -= src
					owner = null
					tick_on = null
					loc = null
		Update()
			on_tick()
		on_tick()
			for(var/mob/m in tick_on)
				m.AddPoison(2*power, owner)
				// call(m,proc_to_call)(list2params(proc_params))


/mob/Admin4/verb/SetMadnessToMax()
	src.secretDatum.secretVariable["Madness"] = 100
