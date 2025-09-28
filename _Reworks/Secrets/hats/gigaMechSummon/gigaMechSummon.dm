/*
there r two facets to it,
a skill + an ai obj

skill sets up + spawns, afaik, given this is meant to be timed (?)
prob wont do atoggle

*/



/obj/Skills/Companion/GIGASpiritMechSummon // : )
	name = "GIGA Spirit Mech Summon"
	companion_icon = null
	companion_name = "GIGA Spirit Mech"
	Mastery = 4
	var/next_summon_time = 0
	Companion_Summon()
		set src in usr
		if(Using) return
		Using=1
		initializeSummon(usr)


	proc/initializeSummon(mob/p)
		// this only exists at max rank but not potential
		for(var/mob/Player/AI/GIGASpiritSummon/gSS in p.ai_followers)
			gSS.vanish()
			p.ai_followers -= gSS
			Using = 0
			return
		
		if(!(world.realtime >= next_summon_time))
			p << "You cannot summon another GIGA Spirit Mech yet."
			return
		
		companion_icon = 'Icons/NPCS/Arcane/SpriteB.dmi' // TODO ICONS HERE FOR THIS THING
		companion_name = "Giga Taci"
		var/mob/Player/AI/GIGASpiritSummon/newGiga = new()
		newGiga.passive_handler = new()
		newGiga.appear(p)
		newGiga.ai_owner = p
		newGiga.ai_follow = 1
		newGiga.ai_hostility = 0
		newGiga.icon = icon(companion_icon)
		newGiga.name = companion_name
		var/focusStat = p.Potential / 25
		var/normalStat = p.Potential / 35

		newGiga.StrMod = 1.25 + normalStat
		newGiga.ForMod = 3 + focusStat
		newGiga.EndMod = 1.25 + normalStat
		newGiga.SpdMod = 2.5 + focusStat
		newGiga.OffMod = 3 + focusStat
		newGiga.DefMod = 2.5 + focusStat
		newGiga.RecovMod = 2 + normalStat
		newGiga.Intimidation = 1 + p.Potential / 10 // P sure these values r meant to be higher
		newGiga.Godspeed = 4
		newGiga.Timeless = 1
		newGiga.TechniqueMastery = 3
		newGiga.ai_spammer = 10
		newGiga.Potential = p.Potential + (p.Potential * 0.5)
		p.ai_followers += newGiga
		newGiga.ai_alliances = list()
		newGiga.ai_alliances += p.ckey

		// add skills
		newGiga.initSkills()
		
		newGiga.density = 0
		newGiga.AIGain()
		newGiga.filters += filter(type="drop_shadow",x=0,y=0,size=3,color="green")
		newGiga.glow_filter = newGiga.filters[newGiga.filters.len]
		animate(newGiga.glow_filter, offset=0, size = 10, time=30, loop=-1)
		Using=0
		last_use = world.time
		active_ai+=newGiga

