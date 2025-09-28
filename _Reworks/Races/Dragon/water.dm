// when buff is on and you entere  tile, attempt to surround the block in water
// if the block is already effected or the surrounding ones are, back out
// passive 'Ocean Bringer"
// 
// make dragon roar pull in and flood the area with water





/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Slithereen_Crush
	passives = list("Ocean Bringer" = 1) // 1 tile around
	ActiveMessage = "brings the ocean to the land."
	OffMessage = "returns the land to its former form..."
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("Ocean Bringer" = 1 + (round(asc/2)), "AbsoluteZero" = 5 + (asc * 2), "Erosion" = min(0.6, 0.25 + (asc * 0.1)), "FluidForm" = 1 + (0.25 * asc), "Flow" = 1 + asc, "VoidField" = 3 + (asc * 2), \
		"Godspeed" = asc)
		ElementalDefense = "Void"
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			adjust(User)
		..()


/mob/Players/proc/HasOceanBringer()
	if(passive_handler.Get("Ocean Bringer") && Health<=15)
		return 1
	return 0


/turf/Cross(O)
	. = ..()
	if(ismob(O))
		var/mob/Players/p = O
		if(!p.client || !p.passive_handler) return
		if(p.HasOceanBringer())
			// start here
			if(hasOceanEffect(p)) return
			applyOceanEffect(p)

/turf/proc/hasOceanEffect(mob/p)
	for(var/turf/t in Turf_Circle(p,p.passive_handler.Get("Ocean Bringer"))) // look at all tiles in the range
		if(t.Deluged)
			continue
		return 0 // if any aren't effected
	return 1 // they are all inflicted

/turf/proc/applyOceanEffect(mob/p)
	for(var/turf/t in Turf_Circle(p,p.passive_handler.Get("Ocean Bringer"))) // look at all tiles in the range
		var/image/i=image(icon='PlainWater.dmi', loc = t)
		i.layer = MOB_LAYER-0.1
		i.mouse_opacity = 0
		animate(i, alpha=0)
		world << i
		t.effects+=i
		animate(i, alpha = 255, time = 2)
		t.Deluged=1
		t.timeToDeath = 150 + (100 * p.AscensionsAcquired)
		t.ownerOfEffect=p
		ticking_turfs+=t


/turf/proc/applyLeftOver(mob/p, leftover, time2death)
	effects+=leftover
	Deluged=1
	timeToDeath = time2death
	ownerOfEffect=p
	ticking_turfs+=src