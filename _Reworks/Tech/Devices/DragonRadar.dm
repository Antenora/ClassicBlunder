#define RADAR_COOLDOWN 100

mob/var/tmp/radar_next = 0

proc/NearestDragonBall(turf/from)
	if(!from) return null
	var/obj/Items/DragonBall/best
	var/bestd = 0
	for(var/obj/Items/DragonBall/B in world)
		if(!isturf(B.loc) || B.z != from.z) continue
		var/d = get_dist(from, B)
		if(!best || d < bestd)
			best = B
			bestd = d
	return best

/obj/Items/Tech/Dragon_Radar
	name = "Dragon Radar"
	desc = "Points to the nearest Dragon Ball lying on this map: direction and distance. It cannot see a ball someone is carrying or one kept in a container. It needs 10 seconds between sweeps, and a Jammer blinds it."
	icon = 'RedScouter.dmi'
	icon_state = "Meditate"
	TechType = "Telecommunications"
	SubType = "Scouters"

	Click()
		if(loc != usr)
			return ..()
		RadarUse(usr)

	proc/RadarUse(mob/M)
		if(!M || loc != M) return
		if(M.Secret == "Heavenly Restriction" && M.secretDatum?:hasRestriction("Science"))
			M << "The device will not work in your hands."
			return
		if(world.time < M.radar_next)
			M << "[src] is still sweeping."
			return
		M.radar_next = world.time + RADAR_COOLDOWN
		if(IsJammed(M))
			M << "[src]'s screen fills with static."
			return
		var/turf/here = get_turf(M)
		var/obj/Items/DragonBall/B = NearestDragonBall(here)
		if(!B)
			M << "[src] finds no Dragon Ball lying anywhere on this map."
			return
		var/d = get_dist(here, B)
		if(d == 0)
			M << "[src] beeps wildly: a Dragon Ball is right where you stand."
			return
		M << "[src]: the nearest Dragon Ball is [M.CheckDirection(B)], [Commas(d)] tiles away."
