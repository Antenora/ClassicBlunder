var/list/dev_jammers = list()
var/list/dev_hand_jammers = list()
var/list/dev_gravity = list()
var/list/dev_seeders = list()

proc/IsJammed(atom/A)
	if(!A || (!dev_jammers.len && !dev_hand_jammers.len)) return 0
	var/turf/T = get_turf(A)
	if(!T) return 0
	for(var/obj/Items/Tech/P in dev_jammers)
		if(P.z != T.z || !P.ProjActive()) continue
		if(get_dist(P, T) <= P.ProjRadius(DEV_JAM_RADIUS)) return 1
	for(var/obj/Items/Tech/H in dev_hand_jammers)
		if(H.JamReaches(T)) return 1
	return 0

/obj/Items/Tech/proc/JamReaches(turf/T)
	return 0

mob/proc/GravityWellHolds()
	if(!dev_gravity.len) return 0
	var/turf/T = get_turf(src)
	if(!T) return 0
	for(var/obj/Items/Tech/P in dev_gravity)
		if(P.z != T.z || !P.ProjActive()) continue
		if(get_dist(P, T) <= P.ProjRadius(DEV_GRAV_RADIUS)) return 1
	return 0

mob/proc/FieldGround()
	spawn() Flight(src, Land = 1)

/obj/Items/Tech
	var
		proj_mult = 0
		proj_on = 0
		proj_burst_cd = DEV_TOWER_BURST_CD
		proj_next_burst = 0
		tmp/proj_pulsing = 0
		tmp/obj/Items/Tech/Emitter/proj_running

	proc/ProjEmitter()
		return locate(/obj/Items/Tech/Emitter) in src

	proc/ProjRadius(base)
		return max(1, round(base * proj_mult))

	proc/ProjActive()
		return proj_mult > 0 && proj_on && dev_live && ProjEmitter()

	proc/ProjSync()
		var/obj/Items/Tech/Emitter/E = ProjEmitter()
		var/field = ProjActive() && E && !E.emit_burst
		if(proj_running && (!field || proj_running != E))
			var/obj/Items/Tech/Emitter/old = proj_running
			proj_running = null
			old.EmitStop(src)
		dev_jammers -= src
		dev_gravity -= src
		dev_seeders -= src
		if(!field) return
		proj_running = E
		E.EmitStart(src)
		if(!proj_pulsing)
			proj_pulsing = 1
			spawn() ProjPulseLoop()

	proc/ProjPulseLoop()
		set waitfor = 0
		while(src && proj_running && ProjActive() && proj_running == ProjEmitter())
			proj_running.EmitPulse(src)
			sleep(DEV_EMITTER_PULSE)
		if(src)
			proj_pulsing = 0
			ProjSync()

	proc/ProjFit(mob/M, obj/Items/Tech/Emitter/E)
		if(!E || E.loc != M) return 0
		if(!DeviceIsOwner(M))
			M << "[src] belongs to someone else."
			return 1
		if(M.InCombat())
			M << "You cannot swap emitters in a fight."
			return 1
		var/obj/Items/Tech/Emitter/old = ProjEmitter()
		if(old)
			old.loc = null
			M.GiveOrDrop(old, 1)
		E.loc = src
		M << "You fit [E] into [src][old ? " and take out [old]" : ""]."
		if(M.client) M.client.BuildInvPage()
		ProjSync()
		return 1

	proc/ProjPickFit(mob/M)
		var/list/have = list()
		for(var/obj/Items/Tech/Emitter/E in M)
			have["[E.name]"] = E
		if(!have.len)
			M << "You have no emitters with you."
			return
		var/pick = have.len == 1 ? have[1] : Ask(M, "Fit which emitter?", "[src]", null, "pick", have, 1)
		if(!pick || !src) return
		ProjFit(M, have[pick])

	proc/ProjRemove(mob/M)
		var/obj/Items/Tech/Emitter/E = ProjEmitter()
		if(!E) return
		if(M.InCombat())
			M << "You cannot swap emitters in a fight."
			return
		E.loc = null
		M.GiveOrDrop(E, 1)
		M << "You take [E] out of [src]."
		ProjSync()

	proc/ProjBurst(mob/M)
		var/obj/Items/Tech/Emitter/E = ProjEmitter()
		if(!E || !E.emit_burst) return
		if(!ProjActive())
			M << "[src] needs to be bolted down, switched on and powered first."
			return
		if(world.realtime < proj_next_burst)
			M << "[src] is still charging after the last burst."
			return
		proj_next_burst = world.realtime + proj_burst_cd
		E.EmitBurst(src, ProjRadius(DEV_BURST_RADIUS))

	proc/ProjActions(mob/M)
		. = list()
		if(!DeviceIsOwner(M) || Grabbable) return
		var/obj/Items/Tech/Emitter/E = ProjEmitter()
		. += proj_on ? "Switch off" : "Switch on"
		if(E && E.emit_burst) . += "Fire a burst"
		. += "Fit an emitter"
		if(E) . += "Take out the emitter"

	proc/ProjAct(mob/M, act)
		switch(act)
			if("Switch on", "Switch off")
				proj_on = !proj_on
				M << "You switch [src] [proj_on ? "on" : "off"]."
				ProjSync()
				return 1
			if("Fire a burst")
				ProjBurst(M)
				return 1
			if("Fit an emitter")
				ProjPickFit(M)
				return 1
			if("Take out the emitter")
				ProjRemove(M)
				return 1
		return 0

	proc/ProjStatus()
		. = list()
		var/obj/Items/Tech/Emitter/E = ProjEmitter()
		. += E ? "Emitter: [E.name]." : "No emitter fitted."
		. += "Switched [proj_on ? "on" : "off"]."
		if(E && E.emit_burst && world.realtime < proj_next_burst)
			. += "Next burst in [round((proj_next_burst - world.realtime) / 600) + 1] min."

/obj/Items/Tech/Projector_Tower
	proj_mult = 1
	proj_burst_cd = DEV_TOWER_BURST_CD
	dev_hopper = 1
	dev_drain = DEV_PER_MINUTE(DEV_DRAIN_PROJECTOR)
	UpdatesDescription = 1
	desc = "A projector tower. Fit one emitter and switch it on: Blutz Wave and Ultraviolet fire a burst on command, while Gravity Well, Jammer and Rain Seeder hold a field around it. It burns 0.2 Power Packs a minute while switched on with an emitter fitted."

	New()
		..()
		spawn(1)
			if(src && isturf(loc) && !Grabbable) DeviceRegister()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return DevicePlaced() && proj_on && ProjEmitter()

	DevicePowerChanged(on)
		ProjSync()

	DeviceAcceptItem(mob/M, obj/Items/I)
		if(istype(I, /obj/Items/Tech/Emitter))
			if(get_dist(M, src) > 1)
				M << "Get next to [src] first."
				return 1
			return ProjFit(M, I)
		return ..()

	DeviceActions(mob/M)
		. = ..() + ProjActions(M)

	DeviceAct(mob/M, act)
		if(ProjAct(M, act)) return
		..()

	DeviceStatus(mob/M)
		. = ..() + ProjStatus()

/obj/Items/Tech/Portable_Projector
	proj_mult = DEV_PORTABLE_MULT
	proj_burst_cd = DEV_PORTABLE_BURST_CD
	dev_hopper = 1
	dev_drain = DEV_PER_MINUTE(DEV_DRAIN_PROJECTOR)
	UpdatesDescription = 1
	desc = "A smaller projector you can carry. It works like the Projector Tower at a shorter reach and a longer wait between bursts, once it is bolted down."

	New()
		..()
		spawn(1)
			if(src && isturf(loc) && !Grabbable) DeviceRegister()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return DevicePlaced() && proj_on && ProjEmitter()

	DevicePowerChanged(on)
		ProjSync()

	DeviceAcceptItem(mob/M, obj/Items/I)
		if(istype(I, /obj/Items/Tech/Emitter))
			if(get_dist(M, src) > 1)
				M << "Get next to [src] first."
				return 1
			return ProjFit(M, I)
		return ..()

	DeviceActions(mob/M)
		. = ..() + ProjActions(M)

	DeviceAct(mob/M, act)
		if(ProjAct(M, act)) return
		..()

	DeviceStatus(mob/M)
		. = ..() + ProjStatus()

/obj/Items/Tech/Emitter
	name = "Emitter"
	desc = "An emitter for a Projector Tower or a Portable Projector."
	icon = 'Tech.dmi'
	icon_state = "Emissor"
	TechType = "Telecommunications"
	SubType = "EM Wave Projectors"
	var/emit_burst = 0

	proc/EmitStart(obj/Items/Tech/T)
		return

	proc/EmitStop(obj/Items/Tech/T)
		return

	proc/EmitPulse(obj/Items/Tech/T)
		return

	proc/EmitBurst(obj/Items/Tech/T, radius)
		return

	Blutz_Wave
		name = "Blutz Wave Emitter"
		desc = "Fitted to a projector, it fires a burst of intensified Blutz Waves on command. Saiyans caught in it regrow their tails and turn Great Ape."
		emit_burst = 1

		EmitBurst(obj/Items/Tech/T, radius)
			view(radius, T) << "<font color=red><small>The projector emits a burst of intensified Blutz Rays!"
			for(var/turf/t in Turf_Circle(T, radius))
				sleep(-1)
				TurfShift('GreenDay.dmi', t, 10, T, EFFECTS_LAYER)
				for(var/mob/m in t)
					if(m.isRace(SAIYAN) || m.isRace(HALFSAIYAN))
						m.Tail = 1
						m.Oozaru(1)

	Ultraviolet
		name = "Ultraviolet Emitter"
		desc = "Fitted to a projector, it fires a burst of powerful ultraviolet light on command, as harsh as sunlight."
		emit_burst = 1

		EmitBurst(obj/Items/Tech/T, radius)
			view(radius, T) << "<font color=red><small>The projector emits a powerful burst of UV light!"
			for(var/turf/t in Turf_Circle(T, radius))
				sleep(-1)
				TurfShift('BrightDay.dmi', t, 10, T, EFFECTS_LAYER)
				for(var/mob/m in t)
					switch(m.Secret)
						if("Vampire")
							var/bloodPower = m.secretDatum.currentTier
							m.BPPoison = min(0.2 * bloodPower, 0.9)
							m.BPPoisonTimer = RawHours(6) / bloodPower
						if("Hamon")
							if(m.RippleActive() && !m.PoseEnhancement)
								m.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Ripple_Enhancement)

	Gravity_Well
		name = "Gravity Well Emitter"
		desc = "Fitted to a projector and switched on, it holds a heavy field: nobody can fly inside it and everyone inside is Slowed."

		EmitStart(obj/Items/Tech/T)
			dev_gravity |= T

		EmitStop(obj/Items/Tech/T)
			dev_gravity -= T

		EmitPulse(obj/Items/Tech/T)
			dev_gravity |= T
			for(var/mob/m in range(T.ProjRadius(DEV_GRAV_RADIUS), T))
				if(m.Flying)
					m << "<font color='#8be9ff'>A gravity well drags you out of the air!</font>"
					m.FieldGround()
				if(m.Slow < DEV_GRAV_SLOW) m.Slow = DEV_GRAV_SLOW

	Jammer
		name = "Jammer Emitter"
		desc = "Fitted to a projector and switched on, it floods the air with noise: communicators, scouters, beacons, alarms and tracker tags inside its reach stop working."

		EmitStart(obj/Items/Tech/T)
			dev_jammers |= T

		EmitStop(obj/Items/Tech/T)
			dev_jammers -= T

		EmitPulse(obj/Items/Tech/T)
			dev_jammers |= T

	Rain_Seeder
		name = "Rain Seeder Emitter"
		desc = "Fitted to a projector and switched on under open sky, it seeds the clouds and keeps it raining over the whole area."

		EmitStart(obj/Items/Tech/T)
			dev_seeders |= T

		EmitStop(obj/Items/Tech/T)
			dev_seeders -= T
			var/area/A = DevSkyArea(T)
			if(!A) return
			var/zheld = 0
			for(var/obj/Items/Tech/O in dev_seeders)
				if(O != T && DevSkyArea(O) == A && O.z == T.z && O.ProjActive())
					zheld = 1
					break
			if(!zheld && WxSeedRelease(A, T.z)) WxSeedFlip(A)
			for(var/obj/Items/Tech/O in dev_seeders)
				if(O != T && DevSkyArea(O) == A && O.ProjActive()) return
			A.wx_seeded = 0
			if(A.wx_seed_z)
				A.wx_seed_z = null
				WxSeedFlip(A)
			if(A.wx_kind != "rain") return
			if(istype(A, /area/MapperZone))
				BuildZoneWxRestore(A)
				return
			var/kind = A.wx_table ? _WxPickWeighted(A.wx_table) : null
			if(kind == "clear") kind = null
			WxSet(A, kind)

		EmitPulse(obj/Items/Tech/T)
			dev_seeders |= T
			var/area/A = DevSkyArea(T)
			if(!A || !glob || !glob.WEATHER) return
			A.wx_seeded = world.time + DEV_RAIN_HOLD
			var/flip = WxSeedClaim(A, T.z, A.wx_seeded)
			if(A.wx_kind != "rain") WxSet(A, "rain")
			if(flip) WxSeedFlip(A)

proc/DevSkyArea(obj/O)
	if(!O || !isturf(O.loc)) return null
	var/turf/T = O.loc
	var/area/A = T.loc
	if(!A || !A.sees_sky) return null
	return A
