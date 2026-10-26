/obj/Skills/Mech/Overload_Pulse
	name = "Overload Pulse"
	desc = "Release a surge that adds 25 heat to every mech within 3 tiles. It adds 15 heat to your own."
	Cooldown = 12
	mech_heat = 15
	mech_ranged = 1
	var/pulse_range = 3
	var/pulse_heat = 25
	verb/Overload_Pulse()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		Cooldown(1, null, p)
		for(var/mob/M in range(pulse_range, p))
			if(M == p || !M.mech) continue
			M.HeatAdd(pulse_heat)
		OMsg(p, "[p] releases an overload pulse!")
		return 1

/obj/Skills/Mech/Smoke_Discharge
	name = "Smoke Discharge"
	desc = "Blow a cloud of smoke over the 3 by 3 tiles around you for 6 seconds. Anyone inside is harder to hit."
	Cooldown = 15
	mech_ranged = 1
	verb/Smoke_Discharge()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		var/turf/T = get_turf(p)
		if(!T) return 0
		Cooldown(1, null, p)
		OrdSpreadClouds(/obj/Traps/Smoke_Cloud/Mech, p, T)
		OMsg(p, "[p] blows out a cloud of smoke.")
		return 1

/obj/Skills/Mech/Evasive_Roll
	name = "Evasive Roll"
	desc = "Kill your drift and snap 2 tiles to the side of your facing, toward your movement input when it points that way."
	Cooldown = 4
	NoGCD = 1
	var/roll_px = 64
	var/roll_ticks = 4
	verb/Evasive_Roll()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.mech)
			p << "[src] only works from inside a mech."
			return 0
		if(p.MechRooted()) return 0
		if(!p.MechSkillGo(src, TRUE)) return 0
		var/d = p.MechRollDir()
		Cooldown(1, null, p)
		p.MechRoll(d, roll_px, roll_ticks)
		return 1

/obj/Skills/Mech/Vault
	name = "Vault"
	desc = "Leap over your target and land on the far side of it, facing it. 5 heat."
	Cooldown = 8
	mech_heat = 5
	var/vault_range = 4
	var/vault_behind = 1
	verb/Vault()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.mech)
			p << "[src] only works from inside a mech."
			return 0
		var/mob/T = p.Target
		if(!ismob(T) || T == p || T.z != p.z || get_dist(p, T) > vault_range)
			p.MechLine("vault", "[src] needs a target within [vault_range] tiles.")
			return 0
		if(p.MechRooted()) return 0
		var/turf/L = p.MechVaultTurf(T, vault_behind)
		if(!L)
			p.MechLine("vault", "There is no room to land behind [T].")
			return 0
		if(!p.MechSkillGo(src, noGCD)) return 0
		Cooldown(1, null, p)
		p.MechVaultTo(L, T)
		return 1

/obj/Skills/Mech/Sensor_Overload
	name = "Sensor Overload"
	desc = "A 6 tile electronic pulse: every enemy mech in it takes 20 heat and its bits fly home."
	Cooldown = 20
	mech_ranged = 1
	var/overload_range = 6
	var/overload_heat = 20
	verb/Sensor_Overload()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		Cooldown(1, null, p)
		for(var/mob/M in range(overload_range, p))
			if(M == p || !M.mech) continue
			if(M.ckey && p.inParty(M.ckey)) continue
			M.MechRecallBits()
			M.HeatAdd(overload_heat)
		OMsg(p, "[p] floods the area with a sensor overload!")
		return 1

mob/proc/MechRollDir()
	var/left = turn(dir, 90)
	var/right = turn(dir, -90)
	var/h = heldDir()
	if(h && (h & right) && !(h & left)) return right
	return left

mob/proc/MechRoll(d, px, ticks)
	set waitfor = 0
	if(!mech || !d) return
	ticks = max(1, round(ticks))
	MechVelocityZero()
	MechImpulse(d, px / ticks, ticks)
	sleep(world.tick_lag * (ticks + 1))
	if(mech && mech_burst_left <= 0) MechVelocityZero()

mob/proc/MechVaultTurf(mob/T, behind = 1)
	var/turf/L = get_turf(T)
	var/d = get_dir(src, T)
	if(!L || !d) return null
	for(var/i = 1 to max(1, behind))
		L = get_step(L, d)
		if(!L) return null
	if(L.density) return null
	for(var/atom/movable/A in L)
		if(A.density && !ismob(A)) return null
	return L

mob/proc/MechVaultTo(turf/L, mob/T)
	if(!L) return
	MechVelocityZero()
	loc = L
	step_x = 0
	step_y = 0
	var/d = get_dir(src, T)
	if(d) dir = d
	OMsg(src, "[src] vaults over [T]!")
