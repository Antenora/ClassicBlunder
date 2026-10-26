#define HACK_OPEN_TIME 100
#define HACK_COOLDOWN 200
#define HACK_PASS 1.0
#define HACK_DIFF_SECURITY 3
#define HACK_DIFF_GLASS 5
#define HACK_DIFF_REINFORCED 7

mob/var/tmp/hack_next = 0
/obj/Items/Tech/Door/var/tmp/hack_close_at = 0
/obj/Items/Tech/Reinforced_Door/var/tmp/hack_close_at = 0

/obj/Items/Tech/Door/Close()
	hack_close_at = 0
	..()

/obj/Items/Tech/Reinforced_Door/Close()
	hack_close_at = 0
	..()

proc/HackLocked(obj/D)
	if(!D || !isturf(D.loc) || OrdDoorBreached(D) || !D.density) return 0
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		if(X.GodDoor || istype(X, /obj/Items/Tech/Door/Guild_Door)) return 0
		return X.Password && !X.AutoOpen
	return istype(D, /obj/Items/Tech/Reinforced_Door)

proc/HackDifficulty(obj/D)
	if(istype(D, /obj/Items/Tech/Reinforced_Door)) return HACK_DIFF_REINFORCED
	if(istype(D, /obj/Items/Tech/Door/TransparentDoor) || istype(D, /obj/Items/Tech/Door/LazerDoor)) return HACK_DIFF_GLASS
	return HACK_DIFF_SECURITY

proc/HackOpen(obj/D)
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		X.DoorToggle(null, 1)
		X.hack_close_at = world.time + HACK_OPEN_TIME
	else if(istype(D, /obj/Items/Tech/Reinforced_Door))
		var/obj/Items/Tech/Reinforced_Door/R = D
		R.Open()
		R.hack_close_at = world.time + HACK_OPEN_TIME
	spawn(HACK_OPEN_TIME) HackReclose(D)

proc/HackReclose(obj/D)
	if(!D || !D.loc || D.density) return
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		if(X.hack_close_at && world.time >= X.hack_close_at) X.DoorToggle(null, 0)
	else if(istype(D, /obj/Items/Tech/Reinforced_Door))
		var/obj/Items/Tech/Reinforced_Door/R = D
		if(R.hack_close_at && world.time >= R.hack_close_at) R.Close()

mob/proc/HackResolve(obj/Items/Tech/D, success)
	hack_next = world.time + HACK_COOLDOWN
	if(!D) return 0
	if(success)
		AlarmCheck(D, src, "hacked")
		D.last_hacked_by = "[src]([key])"
		HackOpen(D)
		src << "The lock gives. [D] opens for [HACK_OPEN_TIME / 10] seconds."
		return 1
	AlarmCheck(D, src, "tried to hack")
	src << "The lock holds against you."
	return 0

/obj/Items/Tech/Hacking_Device/HackUse(mob/M)
	if(!M || loc != M || Using) return
	if(M.KO) return
	if(M.InCombat())
		M << "You cannot hack a door in a fight."
		return
	if(world.time < M.hack_next)
		M << "[src] is still cooling down."
		return
	if(!M.client || M.client.life_minigame_sink)
		M << "Finish what you are doing first."
		return
	var/list/doors = list()
	for(var/obj/Items/Tech/D in range(1, M))
		if(HackLocked(D)) doors["[D.name] ([D.x], [D.y])"] = D
	if(!doors.len)
		M << "There is no locked door within a tile of you."
		return
	var/obj/D
	if(doors.len == 1)
		D = doors[doors[1]]
	else
		var/pick = Ask(M, "Which door do you want to hack?", "[src]", null, "pick", doors, 1)
		if(!pick || !src || loc != M) return
		D = doors[pick]
	if(!D || !HackLocked(D)) return
	Using = 1
	var/diff = HackDifficulty(D)
	var/rank = M.LifeRank("Technology")
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * diff + LIFE_SPEED_PER_UNDER * max(0, diff - rank) - LIFE_SPEED_PER_OVER * max(0, rank - diff), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	var/perf = RunLifeMinigame(M, "timing_bar", diff, list("speed_mult" = speed, "target" = D))
	if(src) Using = 0
	if(!M) return
	M.HackResolve(D, perf >= HACK_PASS && HackLocked(D))
