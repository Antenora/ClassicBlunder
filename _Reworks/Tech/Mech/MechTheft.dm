#define MECH_HACK_DIFF HACK_DIFF_REINFORCED
#define MECH_HACK_CHANNEL 450
#define MECH_HACK_LINE 50
#define MECH_HACK_STEP 2
#define MECH_HACK_DAY 864000
#define MECH_PULL_BEACON_DS 600
#define MECH_BREACH_HULL 0.4
#define MECH_BREACH_FUSE 100

var/mech_hack_channel_ds = MECH_HACK_CHANNEL
var/mech_beacon_period = MECH_BEACON_PERIOD
var/mech_pull_beacon_ds = MECH_PULL_BEACON_DS
var/mech_beacon_serial = 0

mob/proc/MechParkedAt(turf/T)
	if(!T) return null
	for(var/turf/X in range(1, T))
		for(var/obj/Items/Mech/R in X)
			if(!R.mounted && OrdBoxOverlap(R, T)) return R
	return null

mob/proc/MechFrontRecord()
	return MechParkedAt(get_step(src, dir))

mob/proc/MechFrontPilot()
	var/turf/T = get_step(src, dir)
	if(!T) return null
	for(var/turf/X in range(2, T))
		for(var/mob/P in X)
			if(P != src && P.mech && OrdBoxOverlap(P, T)) return P
	return null

mob/proc/MechHackTarget()
	var/obj/Items/Mech/R = MechFrontRecord()
	if(R) return R
	for(var/obj/Items/Tech/D in range(1, src))
		if(HackLocked(D)) return null
	for(var/turf/X in range(1, src))
		for(var/obj/Items/Mech/Y in X)
			if(Y.mounted) continue
			if(!R || get_dist(src, Y) < get_dist(src, R)) R = Y
	return R

mob/proc/MechHackRefusal(obj/Items/Mech/R)
	if(!R) return "There is no parked mech in front of you."
	if(R.mounted) return "[R] has a pilot inside."
	if(!isturf(R.loc)) return "[R] is not parked."
	if(R.MechIsPilot(src)) return "You are already a registered pilot of [R]. There is nothing to steal."
	if(get_dist(src, R) > 1) return "Get next to [R] first."
	var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
	if(intrinsic_refusal) return intrinsic_refusal
	if(R.disabled || R.MechBuilderOnline() || R.MechParkedLong()) return null
	return "[R]'s builder is away and it has been parked for less than a day, so its lock will not open yet."

mob/proc/MechHackStill(obj/Items/Mech/R)
	if(!R || R.mounted || !isturf(R.loc)) return 0
	if(R.MechIsPilot(src) || get_dist(src, R) > 1) return 0
	if(R.IntrinsicPilotRefusal(src)) return 0
	return 1

mob/proc/MechHackBegin(obj/Items/Mech/R)
	var/why = MechHackRefusal(R)
	if(why)
		src << why
		return 0
	R.MechAlarmPing("started hacking")
	return 1

mob/proc/MechHackResolve(obj/Items/Mech/R, success)
	hack_next = world.time + HACK_COOLDOWN
	if(!R) return 0
	if(!success)
		R.MechAlarmPing("failed to hack")
		src << "[R]'s lock holds against you."
		return 0
	src << "[R]'s lock gives. Stay still while you rewrite its pilot list: [round(mech_hack_channel_ds / 10)] seconds."
	return MechHijackChannel(R)

mob/proc/MechHijackBroken(obj/Items/Mech/R, turf/start, turf/home, hs)
	if(!R || R.loc != home || R.mounted) return "The mech is gone from under your hands. The hack breaks off."
	var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
	if(intrinsic_refusal) return intrinsic_refusal
	if(KO || Dead) return "The hack breaks off."
	if(loc != start) return "You moved. The hack breaks off."
	if(Health < hs || InCombat()) return "The fight breaks off the hack."
	if(Stunned || Suspended || Launched || Stasis > 0 || held_skill) return "You lose your hold on the hack."
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed/charm_skill = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed) in src
	if(charm_skill && BuffOn(charm_skill)) return "You lose your hold on the hack."
	return null

mob/proc/MechHijackChannel(obj/Items/Mech/R)
	if(!R) return 0
	if(mech_channeling)
		src << "You're already in the middle of something."
		return 0
	mech_channeling = 1
	var/turf/start = loc
	var/turf/home = R.loc
	var/hs = Health
	var/end = world.time + mech_hack_channel_ds
	var/next_line = world.time + MECH_HACK_LINE
	. = 1
	while(world.time < end)
		sleep(MECH_HACK_STEP)
		var/why = MechHijackBroken(R, start, home, hs)
		if(why)
			src << why
			. = 0
			break
		hs = Health
		if(world.time >= next_line && world.time < end)
			next_line += MECH_HACK_LINE
			src << "Hacking [R]: [round((end - world.time) / 10)] seconds left."
	mech_channeling = 0
	if(!R) return 0
	if(!. || !MechHackStill(R))
		R.MechAlarmPing("failed to hack")
		return 0
	if(!R.pilots) R.pilots = list()
	R.pilots |= ckey
	R.MechAlarmPing("finished hacking")
	src << "[R] accepts you. You are now a registered pilot of [R]."
	return 1

/obj/Items/Tech/Hacking_Device/HackUse(mob/M)
	var/obj/Items/Mech/R = M ? M.MechHackTarget() : null
	if(!R) return ..()
	if(loc != M || Using || M.KO) return
	if(M.InCombat())
		M << "You cannot hack a mech in a fight."
		return
	if(world.time < M.hack_next)
		M << "[src] is still cooling down."
		return
	if(!M.client || M.client.life_minigame_sink)
		M << "Finish what you are doing first."
		return
	if(M.mech_channeling)
		M << "You're already in the middle of something."
		return
	if(!M.MechHackBegin(R)) return
	Using = 1
	var/diff = MECH_HACK_DIFF
	var/rank = M.LifeRank("Technology")
	var/speed = clamp(LIFE_SPEED_BASE + LIFE_SPEED_PER_DIFF * diff + LIFE_SPEED_PER_UNDER * max(0, diff - rank) - LIFE_SPEED_PER_OVER * max(0, rank - diff), LIFE_SPEED_MIN, LIFE_SPEED_MAX)
	var/perf = RunLifeMinigame(M, "timing_bar", diff, list("speed_mult" = speed, "target" = R))
	if(src) Using = 0
	if(!M) return
	M.MechHackResolve(R, perf >= HACK_PASS && M.MechHackStill(R))

/obj/Items/Mech
	var/tmp/mech_beacon_token = 0

	proc/MechBuilderOnline()
		if(!builder) return 0
		for(var/mob/Players/P in players)
			if(P.DeviceKey() == builder && P.client) return 1
		return 0

	proc/MechParkedLong()
		if(!isnum(parked_since) || parked_since <= 0) return 0
		return (world.realtime - parked_since) >= MECH_HACK_DAY

	proc/MechWhere()
		var/turf/T = get_turf(src)
		return T ? "([T.x], [T.y], [T.z])" : "an unknown spot"

	proc/MechBuilderPing(text)
		if(!builder || !text) return 0
		return AlarmPing(builder, text)

	proc/MechAlarmPing(how)
		if(!MechHasChip(/obj/Items/Chip/System/Mech_Alarm)) return 0
		return MechBuilderPing("Mech Alarm: someone [how] [name] at [MechWhere()].")

	proc/MechBeaconLive()
		if(!MechHasChip(/obj/Items/Chip/System/Mech_Beacon)) return 0
		if(!deployed_by || deployed_by == builder) return 0
		return (isturf(loc) || mounted) ? 1 : 0

	proc/MechBeaconWake()
		set waitfor = 0
		if(mech_beacon_token || !MechBeaconLive()) return
		mech_beacon_token = ++mech_beacon_serial
		MechBeaconLoop(mech_beacon_token)

	proc/MechBeaconLoop(token)
		set waitfor = 0
		var/next = world.time
		while(src && mech_beacon_token == token)
			if(!MechBeaconLive()) break
			if(world.time >= next)
				MechBuilderPing("Mech Beacon: [name] is at [MechWhere()].")
				next = world.time + mech_beacon_period
			sleep(max(1, min(MECH_BEACON_STEP, mech_beacon_period)))
		if(src && mech_beacon_token == token) mech_beacon_token = 0

	proc/MechBreachHit()
		if(!isturf(loc) || mounted || disabled) return 0
		MechGuardPull()
		if(disabled) return 0
		Hull = max(0, Hull - MechHullMax() * MECH_BREACH_HULL)
		if(Hull <= 0)
			MechGuardDown(null)
		else
			MechGuardPush()
		return 1

	MechPlaced(stamp = 1)
		..()
		MechBeaconWake()

/mob/Players/MechMount(obj/Items/Mech/R, remount = 0)
	..()
	if(R) R.MechBeaconWake()

/obj/LifeSkills/Station/MechBay/MechBayApplySocket(mob/M, obj/Items/Mech/R, obj/Items/Chip/C)
	. = ..()
	if(. && R) R.MechBeaconWake()

/obj/LifeSkills/Station/MechBay/MechBayApplyUnsocket(mob/M, obj/Items/Mech/R, t)
	if(ispath(t, /obj/Items/Chip/System/Mech_Beacon))
		if(M) M << "The Mech Beacon only comes out through Pull Beacon."
		return 0
	return ..()

/obj/LifeSkills/Station/MechBay/MechBayPullBeacon(mob/M, obj/Items/Mech/R)
	if(!M || !R) return 0
	var/t = /obj/Items/Chip/System/Mech_Beacon
	if(!R.MechHasChip(t))
		M << "No beacon is fitted to [R]."
		return 0
	if(M.InCombat())
		M << "You can't pull a beacon in a fight."
		return 0
	M << "You start working the Mech Beacon loose from [R]."
	if(!M.MechChannel(mech_pull_beacon_ds, src, "beacon pull")) return 0
	if(!MechBayValid(M, R) || !R.MechHasChip(t)) return 0
	var/q = R.socket_chips[t]
	R.socket_chips -= t
	if(!R.socket_chips.len) R.socket_chips = null
	var/obj/Items/Chip/C = new t
	C.CraftQuality = q
	M.GiveOrDrop(C)
	R.MechBuilderPing("Mech Beacon: someone pulled the beacon out of [R.name] at [R.MechWhere()].")
	M << "You pull [C] out of [R]."
	if(M.client) M.client.BuildInvPage()
	return 1

/mob/Players/PlaceBreachingCharge(obj/Items/Ordnance/Breaching_Charge/C)
	if(!C || C.loc != src || BreachTargetDoor()) return ..()
	var/obj/Items/Mech/R = MechFrontRecord()
	var/mob/P = R ? null : MechFrontPilot()
	if(!R && !P) return ..()
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science")) return 0
	if(KO || Dead) return 0
	if(InCombat())
		src << "<font color='#ff6b6b'>You cannot set a charge in a fight.</font>"
		return 0
	if(P)
		src << "<font color='#ff6b6b'>[P.mech] has a pilot inside. A breaching charge only takes to a parked mech.</font>"
		return 0
	if(R.disabled)
		src << "<font color='#ff6b6b'>[R] is already a wreck.</font>"
		return 0
	for(var/obj/Traps/Breaching_Charge/B in ord_live_traps)
		if(B.door == R)
			src << "<font color='#ff6b6b'>[R] already has a charge on it.</font>"
			return 0
	var/obj/Traps/Breaching_Charge/Mech/B = new(R.loc, src)
	B.door = R
	OMsg(src, "<font color='#ffb347'>[src] fixes a breaching charge to [R]! It will blow in [round(B.fuse / 10)] seconds.</font>")
	if(C.Stackable && C.TotalStack > 1)
		C.TotalStack--
		C.suffix = "[C.TotalStack]"
	else
		del C
	if(client) client.BuildInvPage()
	return 1

/obj/Traps/Breaching_Charge/Mech
	var/fuse = MECH_BREACH_FUSE

	TrapStart()
		spawn(fuse) BreachFire()

	BreachFire()
		if(gone) return
		var/obj/Items/Mech/R = door
		var/turf/T = loc
		TrapGone()
		if(!T) return
		Bang(T, Size = 1, Offset = 0)
		if(!istype(R) || !R.MechBreachHit())
			OrdAreaLine(T, "<font color='#ffb347'>The breaching charge blows on empty ground.</font>")
			return
		OrdAreaLine(T, "<font color='#ffb347'>The breaching charge tears into [R]!</font>")
