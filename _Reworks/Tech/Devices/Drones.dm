#if fexists("../../../Icons/Private/Mecha/Fighters.dmi") || fexists("Icons/Private/Mecha/Fighters.dmi")
#define DRONE_FIGHTER_ICON 'Icons/Private/Mecha/Fighters.dmi'
#define DRONE_FIGHTER_PRIVATE 1
#else
#define DRONE_FIGHTER_ICON 'Icons/Technology/Tech.dmi'
#define DRONE_FIGHTER_PRIVATE 0
#endif

#define DRONE_TICK (world.tick_lag * 5)
#define DRONE_SECS_PER_PACK 60
#define DRONE_ROUNDS 90
#define DRONE_DESIGNS 8
#define DRONE_FOLLOW 2
#define DRONE_LEASH 12

/obj/Items/Tech/Drone
	name = "Drone"
	desc = "A small armed flier with a built-in SMG. Launch it from your inventory: it follows you and fires only at your current target, and it never kills. Each Power Pack in it gives 60 seconds of flight; then it lands back in your pack. An EMP or enough damage drops it early."
	icon = DRONE_FIGHTER_ICON
	icon_state = "Turret"
	TechType = "Engineering"
	SubType = "Drones"
	UpdatesDescription = 1
	dev_hopper = 1
	var/drone_design = 1
	var/tmp/mob/Player/AI/Emplacement/Drone/drone_mob

	New()
		..()
		icon_state = DroneState()

	Del()
		if(drone_mob) drone_mob.DroneLand("is lost")
		..()

	proc/Update_Description()
		desc = "[DeviceDescText()] That is about [DroneFlightText()] of flight."

	proc/DroneState()
		if(!DRONE_FIGHTER_PRIVATE) return "Turret"
		return "Fighter[clamp(round(drone_design), 1, DRONE_DESIGNS)]"

	proc/DroneFlightText()
		var/s = round(dev_packs * DRONE_SECS_PER_PACK)
		return s >= 60 ? "[round(s / 60)] min [s % 60] s" : "[s] s"

	Click()
		if(loc != usr) return ..()
		DroneMenu(usr)

	proc/DroneMenu(mob/M)
		if(!M || loc != M) return
		var/list/acts = list()
		if(drone_mob) acts += "Recall"
		else
			acts += "Launch"
			acts += "Load a Power Pack"
			acts += "Pick a design"
		var/act = Ask(M, "[DevicePowerLine()]. About [DroneFlightText()] of flight.", "[src]", null, "pick", acts, 1)
		if(!act || !src || loc != M) return
		switch(act)
			if("Recall")
				if(drone_mob) drone_mob.DroneLand("is called back")
			if("Launch")
				DroneLaunch(M)
			if("Load a Power Pack")
				DeviceInsertFromPack(M)
			if("Pick a design")
				var/list/opts = list()
				for(var/i = 1 to DRONE_DESIGNS)
					opts["Fighter [i]"] = i
				var/pick = Ask(M, "Pick a design.", "[src]", null, "pick", opts, 1)
				if(!pick || !src) return
				drone_design = opts[pick]
				icon_state = DroneState()
				M << "[src] will fly as Fighter [drone_design]."

	proc/DroneLaunch(mob/M)
		if(!M || loc != M || drone_mob) return 0
		if(!isturf(M.loc))
			M << "You need open ground to launch [src]."
			return 0
		if(M.KO || M.Dead)
			return 0
		if(DeviceStalled())
			M << "[src] is still shorted out."
			return 0
		if(dev_packs <= 0)
			M << "[src] has no power. Load a Power Pack first."
			return 0
		var/mob/Player/AI/Emplacement/Drone/D = new(M.loc)
		D.emp_device = src
		D.drone_pilot = M
		D.name = name
		D.icon = DRONE_FIGHTER_ICON
		D.icon_state = DroneState()
		D.dir = M.dir
		D.ai_alliances = list(M.DeviceKey())
		D.EmplacementStats(DronePotential())
		var/obj/Items/Gun/Automatic/SMG/G = new(D)
		G.Loaded = G.MagSize
		var/obj/Items/Ammo/Rifle/Standard/A = new(D)
		A.TotalStack = DRONE_ROUNDS
		A.suffix = "[DRONE_ROUNDS]"
		G.GunAlignEquip(D)
		D.overlays = null
		drone_mob = D
		if(!M.ai_followers) M.ai_followers = list()
		M.ai_followers |= D
		suffix = "*Flying*"
		OMsg(M, "[M] launches [src].")
		if(M.client) M.client.BuildInvPage()
		D.DroneLoop()
		return 1

	proc/DronePotential()
		var/total = glob && glob.progress ? glob.progress.totalPotentialToDate : 1
		return round(total * TurretPotentialBand(CraftQuality), 0.1)

/mob/Player/AI/Emplacement/Drone
	name = "Drone"
	var/tmp/mob/drone_pilot
	var/tmp/drone_last = 0
	var/tmp/drone_looping = 0

	EmplacementMobile()
		return 1

	EmplacementKey()
		return drone_pilot ? drone_pilot.DeviceKey() : ..()

	EmplacementDown(mob/P)
		var/obj/Items/Tech/Drone/I = emp_device
		if(I) I.dev_packs = 0
		spawn(0)
			if(src) DroneLand("is shot down")

	EMPHit(strength)
		if(strength <= 0) return 0
		var/obj/Items/Tech/Drone/I = emp_device
		if(I)
			I.dev_packs = 0
			I.DeviceStall(DEV_EMP_STALL * strength)
		DroneLand("shorts out and drops")
		return 1

	Click(location, control, params)
		if(usr == drone_pilot && usr.Target == src)
			DroneLand("is called back")
			return
		return ..()

	Del()
		if(emp_device) DroneLand("is lost")
		..()

	proc/DroneLand(reason)
		var/obj/Items/Tech/Drone/I = emp_device
		var/mob/P = drone_pilot
		emp_device = null
		drone_pilot = null
		if(P && P.ai_followers) P.ai_followers -= src
		if(I)
			I.drone_mob = null
			I.suffix = null
			if(P)
				P << "[I] [reason] and lands back in your pack."
				if(P.client) P.client.BuildInvPage()
		if(isturf(loc) && reason) OrdAreaLine(src, "<font color='#8be9ff'>[name] [reason].</font>")
		Reloading = 0
		RemoveTarget()
		for(var/obj/Items/Gun/G in src)
			G.loc = null
			del G
		for(var/obj/Items/Ammo/A in src)
			A.loc = null
			del A
		loc = null
		spawn(0)
			if(src) del src

	proc/DroneLoop()
		set waitfor = 0
		if(drone_looping) return
		drone_looping = 1
		drone_last = world.time
		while(src && emp_device && loc)
			DroneTick()
			sleep(DRONE_TICK)
		if(src) drone_looping = 0

	proc/DroneTick()
		var/obj/Items/Tech/Drone/I = emp_device
		var/mob/P = drone_pilot
		if(!I) return
		usr = src
		var/dt = world.time - drone_last
		drone_last = world.time
		I.dev_packs = max(0, I.dev_packs - dt / (DRONE_SECS_PER_PACK * 10))
		if(I.dev_packs <= 0)
			DroneLand("runs out of power")
			return
		if(!P || (P.key && !P.client) || I.loc != P || P.Dead)
			DroneLand("loses its pilot")
			return
		if(!isturf(P.loc) || P.z != z || get_dist(src, P) > DRONE_LEASH)
			if(isturf(P.loc))
				loc = P.loc
				step_x = 0
				step_y = 0
			else
				DroneLand("loses its pilot")
				return
		EmplacementIntent()
		CCRecovery()
		if(icon_state != I.DroneState()) icon_state = I.DroneState()
		if(get_dist(src, P) > DRONE_FOLLOW) step_to(src, P, 1)
		var/obj/Items/Gun/gun = EquippedGun()
		if(!gun || Reloading) return
		if(gun.Loaded <= 0)
			if(Target) RemoveTarget()
			if(GunAmmoStack(gun)) ReloadStart()
			return
		var/mob/T = P.Target
		if(!DroneTargetOK(T, gun))
			if(Target) RemoveTarget()
			return
		EmplacementShoot(T)

	proc/DroneTargetOK(mob/T, obj/Items/Gun/gun)
		var/mob/P = drone_pilot
		if(!ismob(T) || !P || T == src || T == P) return 0
		if(T.KO || T.Dead || !T.density || T.z != z) return 0
		if(T.ckey && P.inParty(T.ckey)) return 0
		if(P.ai_followers && (T in P.ai_followers)) return 0
		if(get_dist(src, T) > gun.ClassRange()) return 0
		return EmpClearShot(src, T, null)
