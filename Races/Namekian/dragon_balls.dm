#define NAMEK_DB_FORGE_ASC 4
#define NAMEK_DB_SPACING 40
#define NAMEK_DB_TRIES 300
#define NAMEK_DB_RECHARGE (7 DAYS)
#define NAMEK_DB_SPEAK_RANGE 3
#define NAMEK_DB_PARTY_RANGE 12
#define NAMEK_DB_SHELTER_RADIUS 3
#define NAMEK_DB_AWAKEN_POWER 5
#define NAMEK_DB_AWAKEN_TIME (7 DAYS)
#define NAMEK_DB_LOOP 600
#define NAMEK_DB_REVIVE_PCT 50
#define NAMEK_DB_LIVE "live"
#define NAMEK_DB_RECHARGING "recharging"
#define NAMEK_DB_STONE "stone"
#define NAMEK_DB_MAIN "main"

mob
	var
		NamekAwakenUntil = 0
		tmp
			NamekDragonSummoning = 0

/obj/NamekShelterMarker
	name = "Shelter Marker"
	desc = "Where Porunga sends those who wish for shelter."
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	density = 0
	Savable = 1
	Attackable = 0
	invisibility = 101
	alpha = 0

/obj/Items/DragonBall/verb/Summon_the_Dragon()
	set name = "Summon the Dragon"
	set src in usr
	var/mob/M = usr
	if(ismob(M))
		M.NamekDragonSummon(src)

/obj/Items/DragonBall/Stone/New()
	..()
	src.verbs -= /obj/Items/DragonBall/verb/Summon_the_Dragon

/obj/Skills/Utility/Namekian/Forge_Dragon_Balls
	name = "Forge Dragon Balls"
	desc = "Channel for one minute to forge seven Dragon Balls that scatter across the world. Whoever gathers all seven can summon Porunga for one wish. Only hard crowd control breaks the channel, and you can keep one set at a time."
	Copyable = 0
	ManaCost = 50
	var/ForgeChannel = 600

	verb/Forge_Dragon_Balls()
		set name = "Forge Dragon Balls"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekForgeStart(src)

/obj/Skills/Utility/Namekian/Name_a_Successor
	name = "Name a Successor"
	desc = "Choose another Dragon clan elder to inherit your Dragon Balls if you die. Without a successor, your set turns to stone when you do."
	Copyable = 0

	verb/Name_a_Successor()
		set name = "Name a Successor"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekNameSuccessor(src)

/proc/NamekDragonSets()
	if(!glob)
		return list()
	if(!islist(glob.NamekDragonSets))
		glob.NamekDragonSets = list()
	return glob.NamekDragonSets

/proc/NamekDragonEntry(id)
	if(!istext(id) || id == NAMEK_DB_MAIN)
		return null
	var/list/sets = NamekDragonSets()
	if(!(id in sets))
		return null
	var/list/e = sets[id]
	return islist(e) ? e : null

/proc/NamekDragonCounting()
	var/n = 0
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(islist(e) && e["state"] != NAMEK_DB_STONE)
			n++
	return n

/proc/NamekDragonSetOf(ckey)
	if(!ckey)
		return null
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(islist(e) && e["maker"] == ckey && e["state"] != NAMEK_DB_STONE)
			return id
	return null

/proc/NamekDragonNewId(ckey)
	var/list/sets = NamekDragonSets()
	if(!(ckey in sets))
		return ckey
	var/n = 2
	while("[ckey]-[n]" in sets)
		n++
	return "[ckey]-[n]"

/proc/NamekDragonBallTypes()
	return list(/obj/Items/DragonBall/One, /obj/Items/DragonBall/Two, /obj/Items/DragonBall/Three, /obj/Items/DragonBall/Four, /obj/Items/DragonBall/Five, /obj/Items/DragonBall/Six, /obj/Items/DragonBall/Seven)

/proc/NamekDragonBalls(id)
	var/list/out = list()
	for(var/obj/Items/DragonBall/B in world)
		if(B.set_id == id)
			out += B
	return out

/proc/NamekDragonFindPlayer(ckey)
	if(!ckey)
		return null
	for(var/mob/Players/P in players)
		if(P.ckey == ckey)
			return P
	return null

/proc/NamekDragonElder(mob/M)
	return M && M.NamekIsNamek() && M.Class == NAMEK_CLAN_DRAGON && M.AscensionsAcquired >= NAMEK_DB_FORGE_ASC

/proc/NamekDragonHeirExists(ckey)
	if(NamekDragonFindPlayer(ckey))
		return 1
	return fexists("Saves/Players/[ckey]")

/proc/NamekDragonWhere(obj/Items/DragonBall/B)
	var/atom/A = B ? B.loc : null
	while(A && !isturf(A) && !ismob(A))
		A = A.loc
	if(ismob(A))
		var/mob/M = A
		return M.key ? "[M.name] ([M.key])" : "[M.name]"
	if(isturf(A))
		return "([A.x],[A.y],[A.z])"
	return "nowhere"

/proc/NamekDragonWaitText(ready_at)
	var/left = max(0, ready_at - world.realtime)
	var/hours = round(left / (1 HOURS))
	if(hours >= 24)
		return "[round(hours / 24, 0.1)] days"
	if(hours >= 1)
		return "[hours] hours"
	return "less than an hour"

/proc/NamekDragonScatterZ()
	if(glob && glob.NamekDragonZ >= 1 && glob.NamekDragonZ <= world.maxz)
		return glob.NamekDragonZ
	var/list/count = list()
	var/bestZ = 0
	var/best = 0
	if(glob && islist(glob.Spawns))
		for(var/obj/Special/Spawn/S in glob.Spawns)
			if(S.Afterlife || !isnum(S.gotoZ) || S.gotoZ < 1 || S.gotoZ > world.maxz)
				continue
			var/k = "[S.gotoZ]"
			count[k] = (count[k] || 0) + 1
			if(count[k] > best)
				best = count[k]
				bestZ = S.gotoZ
	return bestZ || 1

/proc/NamekDragonOpenTurf(turf/T, outdoor = 0)
	if(!isturf(T) || T.density || T.Water || T.Lava || istype(T, /turf/Special))
		return 0
	if(outdoor)
		var/area/A = T.loc
		if(!A || !A.sees_sky)
			return 0
	for(var/atom/movable/M in T)
		if(M.density)
			return 0
	return 1

/proc/NamekDragonGap(turf/T, list/picked)
	var/gap = world.maxx + world.maxy
	for(var/turf/P in picked)
		gap = min(gap, get_dist(T, P))
	return gap

/proc/NamekDragonScatterTurfs(z, count)
	var/list/picked = list()
	var/fellBack = 0
	var/short = 0
	for(var/i = 1, i <= count, i++)
		var/turf/bestSky
		var/bestSkyGap = -1
		var/turf/bestAny
		var/bestAnyGap = -1
		for(var/t = 1, t <= NAMEK_DB_TRIES, t++)
			var/turf/T = locate(rand(1, world.maxx), rand(1, world.maxy), z)
			if(!NamekDragonOpenTurf(T))
				continue
			var/gap = NamekDragonGap(T, picked)
			var/area/A = T.loc
			if(A && A.sees_sky)
				if(gap > bestSkyGap)
					bestSky = T
					bestSkyGap = gap
				if(gap >= NAMEK_DB_SPACING)
					break
			else if(gap > bestAnyGap)
				bestAny = T
				bestAnyGap = gap
		var/turf/use = bestSky
		var/useGap = bestSkyGap
		if(!use)
			use = bestAny
			useGap = bestAnyGap
			fellBack = 1
		if(!use)
			Log("Admin", "Dragon Balls: no open ground found on z [z]; the balls could not scatter.")
			return null
		if(useGap < NAMEK_DB_SPACING)
			short = 1
		picked += use
	if(fellBack)
		Log("Admin", "Dragon Balls: no open outdoor ground found on z [z], so some balls landed on any open tile. Paint an outdoor zone on that z.")
	if(short)
		Log("Admin", "Dragon Balls: z [z] could not keep every ball [NAMEK_DB_SPACING] tiles apart; the farthest open tiles were used.")
	return picked

/proc/NamekDragonPlace(list/balls, list/turfs)
	for(var/i = 1, i <= balls.len, i++)
		var/obj/Items/DragonBall/B = balls[i]
		if(!B)
			continue
		B.loc = turfs[min(i, turfs.len)]
		B.step_x = 0
		B.step_y = 0

/proc/NamekDragonScatter(id, list/balls)
	if(!balls || !balls.len)
		return 0
	var/list/turfs = NamekDragonScatterTurfs(NamekDragonScatterZ(), balls.len)
	if(!turfs)
		return 0
	NamekDragonPlace(balls, turfs)
	return 1

/proc/NamekDragonBallSwap(obj/Items/DragonBall/B, path, keepLook)
	if(!B || !ispath(path))
		return null
	var/obj/Items/DragonBall/N = new path(B.loc)
	N.set_id = B.set_id
	N.set_index = B.set_index
	N.set_total = B.set_total
	if(keepLook)
		N.icon_state = B.icon_state
		N.pixel_x = B.pixel_x
		N.pixel_y = B.pixel_y
	N.step_x = B.step_x
	N.step_y = B.step_y
	del B
	return N

/proc/NamekDragonBallToStone(obj/Items/DragonBall/B)
	if(!B || istype(B, /obj/Items/DragonBall/Stone))
		return B
	var/atom/holder = B.loc
	var/was = "[B.name]"
	var/obj/Items/DragonBall/S = NamekDragonBallSwap(B, /obj/Items/DragonBall/Stone, 1)
	if(ismob(holder))
		holder << "<font color=#aaaaaa>Your [was] turns cold and heavy. It has become stone.</font>"
	return S

/proc/NamekDragonBallFromStone(obj/Items/DragonBall/B)
	if(!istype(B, /obj/Items/DragonBall/Stone))
		return B
	var/list/types = NamekDragonBallTypes()
	if(B.set_index < 1 || B.set_index > types.len)
		return B
	var/atom/holder = B.loc
	var/obj/Items/DragonBall/N = NamekDragonBallSwap(B, types[B.set_index], 0)
	if(ismob(holder))
		holder << "<font color=#77cc77>The stone in your hands warms and glows: it is the [N.name] again.</font>"
	return N

/proc/NamekDragonPetrify(id, list/e)
	if(!islist(e))
		return
	e["state"] = NAMEK_DB_STONE
	e["ready_at"] = 0
	for(var/obj/Items/DragonBall/B in NamekDragonBalls(id))
		NamekDragonBallToStone(B)
	Log("Admin", "Dragon Ball set [id] ([e["maker_name"]]) turned to stone.")

/proc/NamekDragonAdopt(mob/H, id, list/e)
	e["maker"] = H.ckey
	e["maker_name"] = "[H.name]"
	e["successor"] = null
	e["successor_name"] = null
	H.NamekDragonSetId = id
	H.NamekDragonSuccessor = null
	H << "<font color=#77cc77>The Dragon Balls you were promised are yours now. You keep the set.</font>"
	Log("Admin", "[ExtractInfo(H)] inherited Dragon Ball set [id].")

/proc/NamekDragonPass(id, list/e, mob/gone)
	if(!islist(e))
		return
	var/heir = e["successor"]
	if(heir && (!gone || heir != gone.ckey) && NamekDragonHeirExists(heir) && !NamekDragonSetOf(heir))
		e["maker"] = heir
		e["maker_name"] = e["successor_name"] ? e["successor_name"] : heir
		e["successor"] = null
		e["successor_name"] = null
		Log("Admin", "Dragon Ball set [id] passed from [gone ? ExtractInfo(gone) : "its maker"] to [heir].")
		var/mob/Players/H = NamekDragonFindPlayer(heir)
		if(H)
			if(H.NamekDragonSuccessor == id && NamekDragonElder(H))
				NamekDragonAdopt(H, id, e)
			else
				NamekDragonPetrify(id, e)
		return
	NamekDragonPetrify(id, e)

/proc/NamekDragonMakerDied(mob/M)
	if(!M || !M.ckey)
		return
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(!islist(e) || e["maker"] != M.ckey || e["state"] == NAMEK_DB_STONE)
			continue
		NamekDragonPass(id, e, M)

/mob/Players/Death(mob/P, var/text, var/SuperDead = 0, var/NoRemains = 0, extraChance, fakeDeath)
	var/wasDead = src.Dead
	var/oldZ = src.z
	. = ..()
	if(!src || wasDead || fakeDeath)
		return
	if(src.Dead || (src.NoSoul && glob && src.z != oldZ && src.z == glob.NO_SOUL_LOCATION[3]))
		NamekDragonMakerDied(src)

/mob/proc/NamekForgeRefusal()
	if(!NamekDragonElder(src))
		return "Only a Dragon clan elder can forge Dragon Balls."
	if(!src.ckey)
		return "Only a player can forge Dragon Balls."
	if(NamekDragonSetOf(src.ckey))
		return "You already keep a set of Dragon Balls."
	if(NamekDragonCounting() >= glob.NamekDragonSetLimit)
		return "The world cannot hold another set of Dragon Balls right now."
	return null

/mob/proc/NamekForgeStart(obj/Skills/Utility/Namekian/Forge_Dragon_Balls/S)
	if(!NamekCastReady(S))
		return
	var/why = NamekForgeRefusal()
	if(why)
		src << why
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	S.Using = 1
	spawn()
		NamekForgeCast(S)

/mob/proc/NamekForgeCast(obj/Skills/Utility/Namekian/Forge_Dragon_Balls/S)
	src.OMessage(10, "[src] kneels and begins to shape seven orbs of light...", "<font color=green>[src]([src.key]) begins to forge Dragon Balls.")
	if(!NamekChannel(S, S.ForgeChannel, null))
		return
	var/why = NamekForgeRefusal()
	if(why)
		src << why
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	var/list/turfs = NamekDragonScatterTurfs(NamekDragonScatterZ(), 7)
	if(!turfs)
		src << "The world has no open ground to hold the Dragon Balls."
		return
	NamekSpendMana(drain)
	NamekDragonForgeSet(src, turfs)
	src.OMessage(15, "Seven Dragon Balls rise from [src]'s hands and streak away across the sky!", "<font color=green>[src]([src.key]) forged a set of Dragon Balls.")

/proc/NamekDragonForgeSet(mob/M, list/turfs)
	var/id = NamekDragonNewId(M.ckey)
	var/list/sets = NamekDragonSets()
	sets[id] = list("maker" = M.ckey, "maker_name" = "[M.name]", "successor" = null, "successor_name" = null, "state" = NAMEK_DB_LIVE, "ready_at" = 0)
	M.NamekDragonSetId = id
	var/list/balls = list()
	for(var/p in NamekDragonBallTypes())
		var/obj/Items/DragonBall/B = new p
		B.set_id = id
		balls += B
	NamekDragonPlace(balls, turfs)
	Log("Admin", "[ExtractInfo(M)] forged Dragon Ball set [id].")
	return id

/mob/proc/NamekNameSuccessor(obj/Skills/S)
	var/id = NamekDragonSetOf(src.ckey)
	if(!id)
		src << "You keep no Dragon Balls to pass on."
		return
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P != src && P.ckey && NamekDragonElder(P))
			pool += P
	if(!pool.len)
		src << "No other Dragon clan elder is here to take up your Dragon Balls."
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(src, "Who will inherit your Dragon Balls if you die?", "[S]", null, "pick", lab, 1)
	if(isnull(choice))
		return
	var/mob/Players/H = lab[choice]
	if(!H || !NamekDragonElder(H) || NamekDragonSetOf(src.ckey) != id)
		return
	NamekDragonSetSuccessor(id, H)
	src << "<font color=#77cc77>[H] will inherit your Dragon Balls if you die.</font>"
	H << "<font color=#77cc77>[src] has named you the heir to their Dragon Balls.</font>"

/proc/NamekDragonSetSuccessor(id, mob/H)
	var/list/e = NamekDragonEntry(id)
	if(!e || !H)
		return 0
	var/mob/Players/old = NamekDragonFindPlayer(e["successor"])
	if(old && old.NamekDragonSuccessor == id)
		old.NamekDragonSuccessor = null
	var/list/other = NamekDragonEntry(H.NamekDragonSuccessor)
	if(other && other != e && other["successor"] == H.ckey)
		other["successor"] = null
		other["successor_name"] = null
	e["successor"] = H.ckey
	e["successor_name"] = "[H.name]"
	H.NamekDragonSuccessor = id
	Log("Admin", "[ExtractInfo(H)] was named successor of Dragon Ball set [id].")
	return 1

/mob/proc/NamekDragonHeld(id)
	var/list/found = list()
	for(var/obj/Items/DragonBall/B in src)
		if(B.set_id != id || istype(B, /obj/Items/DragonBall/Stone))
			continue
		if(B.set_index >= 1 && B.set_index <= 7 && !found["[B.set_index]"])
			found["[B.set_index]"] = B
	if(found.len < 7)
		return null
	var/list/out = list()
	for(var/k in found)
		out += found[k]
	return out

/mob/proc/NamekDragonSpeaker()
	for(var/mob/Players/P in range(NAMEK_DB_SPEAK_RANGE, src))
		if(!P.KO && P.NamekIsNamek())
			return P
	return null

/mob/proc/NamekDragonSummonRefusal(obj/Items/DragonBall/B)
	if(!B || B.loc != src)
		return "You need to hold the Dragon Ball."
	if(istype(B, /obj/Items/DragonBall/Stone))
		return "The stone is cold and silent."
	var/list/e = NamekDragonEntry(B.set_id)
	if(!e)
		return "These Dragon Balls answer to no one."
	if(e["state"] == NAMEK_DB_STONE)
		return "The stone is cold and silent."
	if(e["state"] == NAMEK_DB_RECHARGING)
		if(world.realtime < e["ready_at"])
			return "The Dragon Balls are dark and cold. They will wake in about [NamekDragonWaitText(e["ready_at"])]."
		e["state"] = NAMEK_DB_LIVE
		e["ready_at"] = 0
	if(src.KO || src.Dead)
		return "You cannot call the dragon like this."
	if(!NamekDragonHeld(B.set_id))
		return "You need all seven Dragon Balls of this set."
	if(!NamekDragonSpeaker())
		return "The balls glow, but no one here speaks the words."
	return null

/proc/NamekDragonWishList(mob/M)
	var/list/out = list()
	var/list/W = glob ? glob.NamekDragonWishes : null
	if(!islist(W))
		return out
	for(var/name in W)
		var/procname = W[name]
		if(!istext(procname) || !hascall(M, procname))
			Log("Admin", "Dragon Ball wish \"[name]\" names no wish proc ([procname]); it was skipped.")
			continue
		out[name] = procname
	return out

/mob/proc/NamekDragonSummon(obj/Items/DragonBall/B)
	if(src.NamekDragonSummoning)
		return
	var/why = NamekDragonSummonRefusal(B)
	if(why)
		src << why
		return
	var/id = B.set_id
	var/list/wishes = NamekDragonWishList(src)
	if(!wishes.len)
		src << "Porunga has no wishes to grant."
		return
	src.NamekDragonSummoning = 1
	src.OMessage(15, "The sky goes dark as [src] raises the Dragon Balls. Porunga rises from the light!", "<font color=green>[src]([src.key]) summoned Porunga with Dragon Ball set [id].")
	var/list/names = list()
	for(var/n in wishes)
		names += n
	while(src)
		var/choice = Ask(src, "Porunga will grant one wish. What do you desire?", "Porunga", null, "pick", names, 1)
		if(isnull(choice))
			src.OMessage(15, "Porunga sinks back into the light, the wish unspoken.")
			break
		why = NamekDragonSummonRefusal(B)
		if(why)
			src << why
			break
		if(NamekDragonGrant(src, id, choice, wishes[choice]))
			break
	if(src)
		src.NamekDragonSummoning = 0

/proc/NamekDragonGrant(mob/M, id, wish, procname)
	if(!M || !istext(procname) || !hascall(M, procname))
		return 0
	if(!call(M, procname)())
		return 0
	M.OMessage(15, "Porunga's voice booms: \"Your wish has been granted!\"", "<font color=green>[M]([M.key]) wished for [wish] with Dragon Ball set [id].")
	NamekDragonSpend(id, M)
	return 1

/proc/NamekDragonSpend(id, mob/M)
	var/list/e = NamekDragonEntry(id)
	if(e)
		e["state"] = NAMEK_DB_RECHARGING
		e["ready_at"] = world.realtime + NAMEK_DB_RECHARGE
	var/list/balls = NamekDragonBalls(id)
	if(!NamekDragonScatter(id, balls))
		Log("Admin", "Dragon Ball set [id] could not scatter after a wish and stays where it was.")
		return
	if(M)
		M.OMessage(15, "The seven Dragon Balls rise into the sky and scatter, dark and cold.")

/mob/proc/NamekWishRestore()
	var/list/party = NamekAllies(NAMEK_DB_PARTY_RANGE, 1)
	for(var/mob/m in party)
		m.FullRestore()
		m << "<font color=#77cc77>Porunga's light washes over you. Every wound closes.</font>"
	return 1

/mob/proc/NamekWishFortune()
	if(src.EconomyMult <= 1)
		src.EconomyMult *= 2
	else
		src.EconomyMult += 0.15
	src << "<font color=#ffff77>Porunga blesses your fortune. Your economy multiplier is now [round(src.EconomyMult, 0.01)].</font>"
	return 1

/mob/proc/NamekWishRevive()
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P.Dead)
			pool += P
	if(!pool.len)
		src << "There is no one in the afterlife to bring back."
		return 0
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(src, "Who will Porunga return from the dead?", "Porunga", null, "pick", lab, 1)
	if(isnull(choice))
		return 0
	var/mob/Players/T = lab[choice]
	if(!T || !T.Dead)
		src << "That soul is beyond Porunga's reach now."
		return 0
	NamekDragonRevive(T, src)
	return 1

/proc/NamekDragonRevive(mob/T, mob/near)
	T.Revive()
	if(near && T != near)
		var/turf/W = T.NamekLandingBeside(near)
		T.loc = W ? W : near.loc
		T.step_x = 0
		T.step_y = 0
		GfxBcHolderMoved(T)
	if(T.KO)
		T.Conscious()
	T.SetHealthPct(NAMEK_DB_REVIVE_PCT)
	T.MaxHealth()
	T << "<font color=#77cc77>Porunga's light pulls you back from the afterlife!</font>"

/proc/NamekShelterFor(mob/M)
	var/obj/NamekShelterMarker/best
	var/bestd = 0
	for(var/obj/NamekShelterMarker/S in world)
		if(!isturf(S.loc))
			continue
		var/d = (S.z == M.z) ? get_dist(M, S) : 100000 + S.z
		if(!best || d < bestd)
			best = S
			bestd = d
	return best

/proc/NamekShelterSpots(obj/NamekShelterMarker/S, n)
	var/list/out = list()
	for(var/r = 0, r <= NAMEK_DB_SHELTER_RADIUS && out.len < n, r++)
		for(var/turf/T in range(r, S))
			if(get_dist(T, S) != r || !NamekDragonOpenTurf(T))
				continue
			out += T
			if(out.len >= n)
				break
	return out

/mob/proc/NamekWishShelter()
	if(glob.DISABLE_ALL_TELEPORTS)
		src << "The ability to teleport has been sealed off!"
		return 0
	var/obj/NamekShelterMarker/S = NamekShelterFor(src)
	if(!S)
		src << "No shelter has been marked in this world."
		return 0
	var/list/party = NamekAllies(NAMEK_DB_PARTY_RANGE, 1)
	var/list/spots = NamekShelterSpots(S, party.len)
	var/i = 0
	for(var/mob/m in party)
		i++
		if(m.Grab)
			m.Grab_Release()
		var/mob/g = m.IsGrabbed()
		if(g)
			g.Grab_Release()
		m.loc = (i <= spots.len) ? spots[i] : S.loc
		m.step_x = 0
		m.step_y = 0
		GfxBcHolderMoved(m)
		m << "<font color=#77cc77>Porunga carries you away to shelter.</font>"
	return 1

/mob/proc/NamekWishAwaken()
	if(!src.passive_handler)
		return 0
	if(src.NamekAwakenUntil <= 0)
		src.passive_handler.Increase("Transformation Power", NAMEK_DB_AWAKEN_POWER)
	src.NamekAwakenUntil = world.realtime + NAMEK_DB_AWAKEN_TIME
	src << "<font color=#77ffff>Porunga stirs the power sleeping in you. For seven days it runs ahead of you.</font>"
	return 1

/mob/proc/NamekAwakenEnd()
	if(src.NamekAwakenUntil <= 0)
		return
	src.NamekAwakenUntil = 0
	if(src.passive_handler)
		src.passive_handler.Decrease("Transformation Power", NAMEK_DB_AWAKEN_POWER)
	src << "<font color=#aaaaaa>The power Porunga stirred in you settles back to sleep.</font>"

/proc/NamekDragonCheckPlayer(mob/Players/P)
	if(P.NamekAwakenUntil > 0 && world.realtime >= P.NamekAwakenUntil)
		P.NamekAwakenEnd()
	if(!P.ckey)
		return
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(!islist(e) || e["maker"] != P.ckey || e["state"] == NAMEK_DB_STONE || P.NamekDragonSetId == id)
			continue
		if(P.NamekDragonSuccessor == id && NamekDragonElder(P))
			NamekDragonAdopt(P, id, e)
		else
			NamekDragonPass(id, e, P)

/proc/NamekDragonTick()
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(islist(e) && e["state"] == NAMEK_DB_RECHARGING && world.realtime >= e["ready_at"])
			e["state"] = NAMEK_DB_LIVE
			e["ready_at"] = 0
	for(var/mob/Players/P in players)
		NamekDragonCheckPlayer(P)
	var/list/orphans = list()
	var/list/petrify = list()
	var/list/wake = list()
	for(var/obj/Items/DragonBall/B in world)
		if(!istext(B.set_id) || B.set_id == NAMEK_DB_MAIN)
			continue
		var/list/e = NamekDragonEntry(B.set_id)
		if(!e)
			orphans += B
		else if(e["state"] == NAMEK_DB_STONE)
			if(!istype(B, /obj/Items/DragonBall/Stone))
				petrify += B
		else if(istype(B, /obj/Items/DragonBall/Stone))
			wake += B
	for(var/obj/Items/DragonBall/O in orphans)
		Log("Admin", "Dragon Ball [O] of vanished set [O.set_id] was removed from [NamekDragonWhere(O)].")
		del O
	for(var/obj/Items/DragonBall/S in petrify)
		NamekDragonBallToStone(S)
	for(var/obj/Items/DragonBall/W in wake)
		NamekDragonBallFromStone(W)

/proc/NamekDragonLoop()
	set waitfor = 0
	while(WorldLoading || !glob)
		sleep(50)
	while(1)
		NamekDragonTick()
		sleep(NAMEK_DB_LOOP)

/world/New()
	..()
	spawn(10)
		NamekDragonLoop()

/proc/NamekDragonLabels(list/states)
	var/list/out = list()
	var/list/sets = NamekDragonSets()
	for(var/id in sets)
		var/list/e = sets[id]
		if(!islist(e) || (states && !(e["state"] in states)))
			continue
		out["[e["maker_name"]]'s set ([id], [e["state"]])"] = id
	return out

/proc/NamekDragonDestroy(id)
	var/list/e = NamekDragonEntry(id)
	if(!e)
		return 0
	for(var/obj/Items/DragonBall/B in NamekDragonBalls(id))
		del B
	var/mob/Players/M = NamekDragonFindPlayer(e["maker"])
	if(M && M.NamekDragonSetId == id)
		M.NamekDragonSetId = null
	var/mob/Players/H = NamekDragonFindPlayer(e["successor"])
	if(H && H.NamekDragonSuccessor == id)
		H.NamekDragonSuccessor = null
	var/list/sets = NamekDragonSets()
	sets -= id
	return 1

/proc/NamekDragonRestore(id)
	var/list/e = NamekDragonEntry(id)
	if(!e)
		return "That set no longer exists."
	var/other = NamekDragonSetOf(e["maker"])
	if(other && other != id)
		return "[e["maker_name"]] already keeps another set ([other])."
	e["state"] = NAMEK_DB_LIVE
	e["ready_at"] = 0
	var/mob/Players/M = NamekDragonFindPlayer(e["maker"])
	if(M)
		M.NamekDragonSetId = id
	for(var/obj/Items/DragonBall/B in NamekDragonBalls(id))
		NamekDragonBallFromStone(B)
	return null

/mob/Admin3/verb/Dragon_Set_Report()
	set category = "Admin"
	set name = "Dragon Set Report"
	var/list/sets = NamekDragonSets()
	var/list/rows = list()
	for(var/id in sets)
		var/list/e = sets[id]
		if(!islist(e))
			continue
		var/list/where = list()
		var/list/seen = list()
		for(var/obj/Items/DragonBall/B in NamekDragonBalls(id))
			seen["[B.set_index]"] = 1
			where += "[B.set_index]: [NamekDragonWhere(B)][istype(B, /obj/Items/DragonBall/Stone) ? " (stone)" : ""]"
		for(var/n = 1, n <= 7, n++)
			if(!seen["[n]"])
				where += "[n]: unseen (an offline holder)"
		var/ready = e["state"] == NAMEK_DB_RECHARGING ? NamekDragonWaitText(e["ready_at"]) : "-"
		var/heir = e["successor"] ? "[e["successor_name"]] ([e["successor"]])" : "-"
		rows[++rows.len] = list("t" = "[id]", "t2" = jointext(where, "; "), "c" = list("[e["maker_name"]] ([e["maker"]])", "[e["state"]]", ready, heir))
	usr.client?.TableShow("namekian:dragonsets", "NAMEKIAN", "Dragon Ball sets", "[NamekDragonCounting()] of [glob.NamekDragonSetLimit] live, balls scatter on z [NamekDragonScatterZ()]", list(list("l" = "SET", "a" = "l"), list("l" = "MAKER", "a" = "l"), list("l" = "STATE", "a" = "l"), list("l" = "WAKES IN", "a" = "l"), list("l" = "SUCCESSOR", "a" = "l")), rows, "", null, list("nosort" = 1))

/mob/Admin4/verb/Destroy_Dragon_Set()
	set category = "Admin"
	set name = "Destroy Dragon Set"
	var/list/lab = NamekDragonLabels(null)
	if(!lab.len)
		usr << "<font color=red>There are no Dragon Ball sets.</font>"
		return
	var/choice = Ask(usr, "Which set will you destroy? Its balls vanish wherever they are.", "Destroy Dragon Set", null, "pick", lab, 1)
	if(isnull(choice))
		return
	var/id = lab[choice]
	var/confirm = Ask(usr, "Destroy [choice] for good?", "Destroy Dragon Set", null, "confirm", null, 1, "Destroy", "Cancel")
	if(confirm != "Destroy")
		return
	if(!NamekDragonDestroy(id))
		usr << "<font color=red>That set no longer exists.</font>"
		return
	usr << "<font color=yellow>Dragon Ball set [id] destroyed.</font>"
	Log("Admin", "[ExtractInfo(usr)] destroyed Dragon Ball set [id].")

/mob/Admin4/verb/Restore_Dragon_Set()
	set category = "Admin"
	set name = "Restore Dragon Set"
	var/list/lab = NamekDragonLabels(list(NAMEK_DB_STONE, NAMEK_DB_RECHARGING))
	if(!lab.len)
		usr << "<font color=red>No set is stone or recharging.</font>"
		return
	var/choice = Ask(usr, "Which set will you make live again? Stone balls wake and a recharge ends now.", "Restore Dragon Set", null, "pick", lab, 1)
	if(isnull(choice))
		return
	var/id = lab[choice]
	var/why = NamekDragonRestore(id)
	if(why)
		usr << "<font color=red>[why]</font>"
		return
	usr << "<font color=yellow>Dragon Ball set [id] is live again.</font>"
	Log("Admin", "[ExtractInfo(usr)] restored Dragon Ball set [id].")

/mob/Admin3/verb/Set_Dragon_Set_Limit()
	set category = "Admin"
	set name = "Set Dragon Set Limit"
	var/n = Ask(usr, "How many Dragon Ball sets may be live at once? Now: [glob.NamekDragonSetLimit].", "Set Dragon Set Limit", glob.NamekDragonSetLimit, "num", null, 1)
	if(isnull(n))
		return
	n = max(0, round(n))
	glob.NamekDragonSetLimit = n
	usr << "<font color=yellow>The Dragon Ball set limit is now [n].</font>"
	Log("Admin", "[ExtractInfo(usr)] set the Dragon Ball set limit to [n].")

/mob/Admin3/verb/Set_Dragon_Ball_Z()
	set category = "Admin"
	set name = "Set Dragon Ball Z"
	var/n = Ask(usr, "Which z do Dragon Balls scatter on? 0 means the z most spawns use. Now: [glob.NamekDragonZ ? glob.NamekDragonZ : "0 (z [NamekDragonScatterZ()])"].", "Set Dragon Ball Z", glob.NamekDragonZ, "num", null, 1)
	if(isnull(n))
		return
	n = round(n)
	if(n < 0 || n > world.maxz)
		usr << "<font color=red>Pick 0 or a z from 1 to [world.maxz].</font>"
		return
	glob.NamekDragonZ = n
	usr << "<font color=yellow>Dragon Balls now scatter on z [NamekDragonScatterZ()].</font>"
	Log("Admin", "[ExtractInfo(usr)] set the Dragon Ball z to [n].")

/mob/Admin3/verb/Place_Shelter_Marker()
	set category = "Admin"
	set name = "Place Shelter Marker"
	var/turf/T = get_step(usr, usr.dir)
	if(!isturf(T))
		usr << "<font color=red>There is no tile in front of you.</font>"
		return
	for(var/obj/NamekShelterMarker/M in T)
		usr << "<font color=red>There is already a Shelter Marker there.</font>"
		return
	new/obj/NamekShelterMarker(T)
	usr << "<font color=yellow>Shelter Marker placed at ([T.x],[T.y],[T.z]). Save the world to keep it.</font>"
	Log("Mapper", "[ExtractInfo(usr)] placed a Shelter Marker at ([T.x],[T.y],[T.z]).", 1)
