/mob/proc/QuincyHoldingFire()
	var/last = max(src.lastHit, src.gun_last_fire)
	return world.time - last >= QUINCY_CALM_TIME

/mob/proc/QuincyConvergenceLoop()
	set waitfor = 0
	if(src.QuincyConvergenceOn)
		return
	src.QuincyConvergenceOn = 1
	while(src && istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon))
		sleep(10)
		if(!src || !istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon))
			break
		var/pts = src.passive_handler.Get("Reishi Convergence")
		if(pts > 0 && QuincyHoldingFire())
			var/rate = 0.01 * src.ManaCap() * pts * (QuincyReishiRich(src.loc) ? 2 : 1)
			if(rate > 0)
				src.HealMana(rate)
	if(src)
		src.QuincyConvergenceOn = 0

/mob/Players/attackModifiers(mob/defender, list/forcedDmgList=list())
	. = ..()
	if(!ismob(defender))
		return
	if((HollowIsHollow() && defender.QuincyIsQuincy()) || (QuincyIsQuincy() && defender.HollowIsHollow()))
		. += QUINCY_HOLLOW_MOD

/obj/Skills/Quincy

/obj/Skills/Quincy/Hollow_Sense
	name = "Hollow Sense"
	desc = "Feel for the Reiatsu of nearby Hollows."
	Cooldown = 10

	verb/Hollow_Sense()
		set name = "Hollow Sense"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(src.Using || src.cooldown_remaining > 0)
			User << "<font color=red>[src] is not ready yet.</font>"
			return
		var/list/found = list()
		for(var/mob/M in range(QUINCY_SENSE_RANGE, User))
			if(M == User || M.z != User.z)
				continue
			if(!M.HollowIsHollow())
				continue
			found += M
		if(!found.len)
			User << "<font color=#9fd8ff>You sense no Hollows.</font>"
		else
			User << "<font color=#9fd8ff>You sense [found.len] Hollow[found.len == 1 ? "" : "s"] nearby:</font>"
			for(var/mob/M in found)
				var/d = get_dir(User, M)
				if(d)
					User << "<font color=#9fd8ff>[M]: [get_dist(User, M)] tiles to the [QuincyDirName(d)].</font>"
				else
					User << "<font color=#9fd8ff>[M]: right beside you.</font>"
		src.Cooldown(1, null, User)
