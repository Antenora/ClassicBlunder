globalTracker/var/ENSHRINE_HEAL = 0.008
globalTracker/var/ENSHRINE_TIMER = 20

mob/proc/applyEnshrine(radius)
	for(var/turf/T in range(radius, src))
		if(!T.density)
			CHECK_TICK
			new/obj/leftOver/Enshrine(T.x, T.y, T.z, src)

/obj/leftOver
	Enshrine
		icon='lightEffect.dmi'
		power = 1
		lifetime = 20 SECONDS
		New(_x,_y,_z, mob/p)
			loc = locate(_x,_y,_z)
			lifetime = (glob.ENSHRINE_TIMER) SECONDS
			init(p)
		on_tick()
			for(var/mob/m in tick_on)
				m.HealHealth(power * glob.ENSHRINE_HEAL)