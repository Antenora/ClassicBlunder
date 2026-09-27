#define TURRET_HP_MAX 100

/proc/TurretPotentialBand(q)
	switch(QualityClamp(q))
		if(QUAL_POOR) return 0.5
		if(QUAL_NORMAL) return 0.6
		if(QUAL_GOOD) return 0.7
		if(QUAL_EPIC) return 0.8
	return 0.9

/mob/Player/AI/Emplacement/Turret
	name = "Sentry Turret"
	icon_state = "Turret"

/obj/Items/Tech/Sentry_Turret
	name = "Sentry Turret"
	desc = "An automated gun mount. Bolt it down, drag an Automatic gun onto it, then drag rounds of that gun's caliber and Power Packs onto it. It fires at players and hostile creatures in the gun's range who are not its owner, on its whitelist or in its owner's party, and it never kills: a downed target is left alone. It burns 1 Power Pack an hour while armed."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "Turret"
	TechType = "Engineering"
	SubType = "Automated Defenses"
	Pickable = 1
	Grabbable = 1
	Attackable = 0
	Destructable = 0
	UpdatesDescription = 1
	dev_hopper = 1
	dev_drain = DEV_PER_HOUR(1)
	var/turret_hp = TURRET_HP_MAX
	var/turret_broken = 0
	var/obj/Items/Gun/turret_gun
	var/list/turret_ammo
	var/tmp/mob/Player/AI/Emplacement/Turret/turret_gunner
	var/tmp/turret_looping = 0

	New()
		..()
		spawn(0)
			if(src)
				TurretPrune()
				if(isturf(loc) && !Grabbable) DeviceRegister()
				TurretSync()

	Del()
		var/atom/drop = loc
		TurretDisarm()
		for(var/obj/Items/I in src)
			I.loc = drop
		turret_gun = null
		turret_ammo = null
		..()

	proc/Update_Description()
		desc = "[DeviceDescText()]<br><br>[jointext(TurretLines(), "<br>")]"

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return DevicePlaced() && turret_gun && !turret_broken

	DevicePowerChanged(on)
		TurretSync()

	DevicePowerTick(minutes)
		..()
		TurretSync()

	DeviceBoltToggle(mob/M)
		. = ..()
		TurretSync()

	DeviceAcceptItem(mob/M, obj/Items/I)
		if(istype(I, /obj/Items/Gun) || istype(I, /obj/Items/Ammo))
			if(get_dist(M, src) > 1)
				M << "Get next to [src] first."
				return 1
			if(!DeviceIsOwner(M))
				M << "Only [src]'s owner can load it."
				return 1
			if(turret_broken)
				M << "[src] is broken. Repair it first."
				return 1
			if(istype(I, /obj/Items/Gun)) TurretInsertGun(M, I)
			else TurretInsertAmmo(M, I)
			return 1
		return ..()

	DeviceActions(mob/M)
		. = ..()
		if(!isturf(loc)) return
		if(DeviceIsOwner(M))
			if(turret_broken) . += "Repair"
			else if(turret_gun) . += "Unload"
		. += GuardActions(M)

	DeviceAct(mob/M, act)
		if(GuardAct(M, act)) return
		switch(act)
			if("Repair")
				TurretRepair(M)
				return
			if("Unload")
				TurretUnload(M)
				return
		..()

	DeviceStatus(mob/M)
		. = ..() + TurretLines() + GuardStatus(M)

	EmplacementBroken(mob/Player/AI/Emplacement/E, mob/P)
		if(E != turret_gunner)
			..()
			return
		spawn(0)
			if(src) TurretBreak(P)

	GuardChanged()
		if(turret_gunner) turret_gunner.ai_alliances = GuardAlliances()

	proc/TurretLines()
		. = list()
		if(turret_broken)
			. += "Broken. Its owner can repair it with 1 Servo and 1 Casing."
			return
		. += "Armor: [round(turret_hp)]%."
		var/obj/Items/Gun/G = turret_gun
		if(!G)
			. += "No gun loaded. Drag an Automatic gun onto it."
			return
		. += "Gun: [G.name], [G.Loaded] of [G.MagSize] in the magazine, [TurretRounds()] spare rounds."

	proc/TurretRounds()
		. = 0
		for(var/obj/Items/Ammo/A in turret_ammo)
			. += A.TotalStack

	proc/TurretPrune()
		if(turret_gun && !turret_gun.loc) turret_gun.loc = src
		for(var/obj/Items/Ammo/A in turret_ammo)
			if(!A.loc) A.loc = src
		if(turret_ammo)
			turret_ammo -= null
			if(!turret_ammo.len) turret_ammo = null
		if(turret_gun && turret_gun.loc != src && turret_gun.loc != turret_gunner)
			turret_gun = null

	proc/TurretSyncRefs()
		var/atom/holder = turret_gunner ? turret_gunner : src
		var/list/L = list()
		for(var/obj/Items/Ammo/A in holder)
			L += A
		turret_ammo = L.len ? L : null

	proc/TurretPower(mob/Player/AI/Emplacement/G)
		if(!G) return
		var/total = glob && glob.progress ? glob.progress.totalPotentialToDate : 1
		G.EmplacementStats(round(total * TurretPotentialBand(CraftQuality), 0.1))

	proc/TurretSync()
		if(DevicePlaced() && turret_gun && !turret_broken)
			if(!turret_gunner || !turret_gunner.loc) TurretArm()
			else turret_gunner.EmplacementHome()
		else if(turret_gunner)
			TurretDisarm()
		icon_state = turret_broken ? "TurretBase" : "Turret"
		if(turret_gunner && turret_gunner.loc)
			invisibility = 101
			mouse_opacity = 0
		else
			invisibility = 0
			mouse_opacity = 1

	proc/TurretArm()
		if(!isturf(loc) || !turret_gun) return
		if(turret_gunner) TurretDisarm()
		var/mob/Player/AI/Emplacement/Turret/G = new(loc)
		G.emp_device = src
		G.name = name
		G.dir = dir
		G.ai_alliances = GuardAlliances()
		TurretPower(G)
		G.SetHealthPct(max(1, turret_hp))
		turret_gunner = G
		turret_gun.suffix = null
		turret_gun.loc = G
		for(var/obj/Items/Ammo/A in turret_ammo)
			A.loc = G
		for(var/obj/Items/Ammo/A in src)
			A.loc = G
		turret_gun.GunAlignEquip(G)
		G.overlays = null
		TurretSyncRefs()
		invisibility = 101
		mouse_opacity = 0
		TurretLoop()

	proc/TurretDisarm()
		var/mob/Player/AI/Emplacement/Turret/G = turret_gunner
		turret_gunner = null
		invisibility = 0
		mouse_opacity = 1
		if(!G) return
		dir = G.dir
		if(G.Health > 0 && !turret_broken) turret_hp = clamp(round(G.HealthPct(), 0.1), 1, TURRET_HP_MAX)
		G.Reloading = 0
		if(turret_gun && turret_gun.loc == G)
			if(G.EquippedGun() == turret_gun) turret_gun.GunAlignEquip(G)
			turret_gun.suffix = null
			turret_gun.loc = src
		for(var/obj/Items/Ammo/A in G)
			A.loc = src
		TurretSyncRefs()
		G.emp_device = null
		G.RemoveTarget()
		G.loc = null
		spawn(0)
			if(G) del G

	proc/TurretLoop()
		set waitfor = 0
		if(turret_looping) return
		turret_looping = 1
		while(src && turret_gunner && turret_gunner.loc)
			TurretTick()
			sleep(EMP_TICK)
		if(src) turret_looping = 0

	proc/TurretTick()
		var/mob/Player/AI/Emplacement/Turret/G = turret_gunner
		if(!G) return
		usr = G
		if(!DevicePlaced())
			TurretSync()
			return
		if(G.Health <= 0)
			TurretBreak(null)
			return
		G.EmplacementHome()
		G.EmplacementIntent()
		G.CCRecovery()
		if(G.icon_state != "Turret") G.icon_state = "Turret"
		turret_hp = clamp(round(G.HealthPct(), 0.1), 0, TURRET_HP_MAX)
		TurretSyncRefs()
		TurretPower(G)
		var/obj/Items/Gun/gun = G.EquippedGun()
		if(!gun)
			if(turret_gun && turret_gun.loc == G)
				turret_gun.suffix = null
				turret_gun.GunAlignEquip(G)
				G.overlays = null
			return
		if(!DevicePowered() || G.Reloading)
			return
		if(gun.Loaded <= 0)
			if(G.Target) G.RemoveTarget()
			if(G.GunAmmoStack(gun)) G.ReloadStart()
			return
		var/mob/T = G.EmplacementTarget(gun, src)
		if(!T)
			if(G.Target) G.RemoveTarget()
			return
		if(G.EmplacementShoot(T)) flick("TurretFiring", G)

	proc/TurretBreak(mob/P)
		if(turret_broken) return
		turret_broken = 1
		turret_hp = 0
		var/atom/drop = loc
		TurretDisarm()
		if(turret_gun)
			turret_gun.loc = drop
			turret_gun = null
		for(var/obj/Items/Ammo/A in src)
			A.loc = drop
		turret_ammo = null
		icon_state = "TurretBase"
		if(isturf(loc)) OrdAreaLine(src, "<font color='#ff9a9a'>[src] sparks, shudders and falls silent. Its gun clatters to the ground.</font>")
		DevicePowerCheck()

	proc/TurretRepair(mob/M)
		if(!turret_broken || !DeviceIsOwner(M)) return
		if(CountMaterial(M, "Servo") < 1 || CountMaterial(M, "Casing") < 1)
			M << "You need 1 Servo and 1 Casing in your Collection Log to repair [src]."
			return
		ConsumeMaterial(M, "Servo", 1)
		ConsumeMaterial(M, "Casing", 1)
		turret_broken = 0
		turret_hp = TURRET_HP_MAX
		icon_state = "Turret"
		OMsg(M, "[M] repairs [src].")
		TurretSync()
		DevicePowerCheck()

	proc/TurretInsertGun(mob/M, obj/Items/Gun/G)
		if(!G || G.loc != M) return
		if(turret_gun)
			M << "[src] already holds [turret_gun]. Unload it first."
			return
		var/obj/Items/Gun/Automatic/auto = /obj/Items/Gun/Automatic
		if(G.GunClass != initial(auto.GunClass))
			M << "[src] only takes Automatic guns."
			return
		if(G.mech_only)
			M << "[G] only mounts on a mech's arm."
			return
		if(G.suffix && M.EquippedGun() == G)
			if(G.GunEquipRefused(M)) return
			G.GunAlignEquip(M)
		G.suffix = null
		G.loc = src
		turret_gun = G
		M << "You mount [G] on [src]. Drag [G.Caliber] rounds onto it to feed it."
		if(M.client) M.client.BuildInvPage()
		TurretSync()
		DevicePowerCheck()

	proc/TurretInsertAmmo(mob/M, obj/Items/Ammo/A)
		if(!A || A.loc != M) return
		if(!turret_gun)
			M << "Mount a gun on [src] before you feed it."
			return
		if(A.Caliber != turret_gun.Caliber)
			M << "[turret_gun] takes [turret_gun.Caliber] rounds, not [A.name]."
			return
		A.loc = turret_gunner ? turret_gunner : src
		TurretSyncRefs()
		M << "You feed [A.TotalStack] [A.name] into [src]. It holds [TurretRounds()] spare rounds."
		if(M.client) M.client.BuildInvPage()

	proc/TurretUnload(mob/M)
		if(!DeviceIsOwner(M) || !turret_gun) return
		TurretDisarm()
		var/obj/Items/Gun/G = turret_gun
		turret_gun = null
		if(G && G.loc == src) M.GiveOrDrop(G)
		for(var/obj/Items/Ammo/A in src)
			M.GiveOrDrop(A)
		turret_ammo = null
		M << "You unload [src]."
		TurretSync()
		DevicePowerCheck()
