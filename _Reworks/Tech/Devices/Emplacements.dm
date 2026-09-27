#define EMP_TICK (world.tick_lag * 5)
#define GUARD_PASSWORD_MAX 32

/obj/Items/Tech
	var/list/guard_keys
	var/guard_password

	proc/GuardAllows(mob/M)
		if(!M) return 0
		if(DeviceIsOwner(M)) return 1
		var/k = M.DeviceKey()
		if(!k || !guard_keys) return 0
		return (k in guard_keys) ? 1 : 0

	proc/GuardOwnerMob()
		if(!CreatorKey) return null
		for(var/mob/Players/P in players)
			if(P.DeviceKey() == CreatorKey) return P
		return null

	proc/GuardOwnsEmplacement(mob/M)
		if(!istype(M, /mob/Player/AI/Emplacement) || !CreatorKey) return 0
		var/mob/Player/AI/Emplacement/E = M
		return E.EmplacementKey() == CreatorKey

	proc/GuardSpares(mob/M, mob/O = -1)
		if(!M) return 1
		if(GuardAllows(M)) return 1
		if(GuardOwnsEmplacement(M)) return 1
		if(O == -1) O = GuardOwnerMob()
		if(O)
			if(M.ckey && O.inParty(M.ckey)) return 1
			if(O.ai_followers && (M in O.ai_followers)) return 1
		return 0

	proc/GuardAlliances()
		. = list()
		if(CreatorKey) . += CreatorKey
		if(guard_keys) . += guard_keys

	proc/GuardChanged()
		return

	proc/GuardAllowKey(mob/M)
		var/k = PromptKnownKey(M, "Whitelist a key")
		if(!k || !src) return
		k = ckey(k)
		if(!length(k)) return
		if(k == CreatorKey)
			M << "[src] always knows its owner."
			return
		if(!guard_keys) guard_keys = list()
		guard_keys |= k
		M << "[k] is now on [src]'s whitelist."
		GuardChanged()

	proc/GuardRemoveKey(mob/M)
		if(!length(guard_keys))
			M << "Nobody is on [src]'s whitelist yet."
			return
		var/k = Ask(M, "Take which key off the whitelist?", "[src]", null, "pick", guard_keys, 1)
		if(!k || !src || !guard_keys) return
		guard_keys -= k
		if(!guard_keys.len) guard_keys = null
		M << "[k] is off [src]'s whitelist."
		GuardChanged()

	proc/GuardSetPassword(mob/M)
		var/t = Ask(M, "Set a password. Anyone who enters it joins the whitelist. Leave it empty to clear it.", "[src]", null, "text", null, 1)
		if(isnull(t) || !src) return
		t = trimtext("[t]")
		if(!length(t))
			guard_password = null
			M << "[src] no longer takes a password."
			return
		guard_password = copytext(t, 1, GUARD_PASSWORD_MAX + 1)
		M << "[src]'s password is set."

	proc/GuardTryPassword(mob/M)
		if(!guard_password || !M) return
		var/t = Ask(M, "Enter the password.", "[src]", null, "text", null, 1)
		if(isnull(t) || !src || !M || !guard_password) return
		if(trimtext("[t]") != guard_password)
			M << "[src] rejects the password."
			return
		var/k = M.DeviceKey()
		if(!k) return
		if(!guard_keys) guard_keys = list()
		guard_keys |= k
		M << "[src] accepts the password. You are on its whitelist."
		GuardChanged()

	proc/GuardActions(mob/M)
		. = list()
		if(DeviceIsOwner(M))
			. += "Whitelist a key"
			if(length(guard_keys)) . += "Remove a key"
			. += "Set password"
		else if(guard_password && !GuardAllows(M))
			. += "Enter password"

	proc/GuardAct(mob/M, act)
		switch(act)
			if("Whitelist a key")
				if(DeviceIsOwner(M)) GuardAllowKey(M)
			if("Remove a key")
				if(DeviceIsOwner(M)) GuardRemoveKey(M)
			if("Set password")
				if(DeviceIsOwner(M)) GuardSetPassword(M)
			if("Enter password")
				GuardTryPassword(M)
			else
				return 0
		return 1

	proc/GuardStatus(mob/M)
		. = list()
		if(!DeviceIsOwner(M)) return
		. += length(guard_keys) ? "Whitelist: [jointext(guard_keys, ", ")]." : "Whitelist: nobody but you."
		if(guard_password) . += "A password is set."

	proc/EmplacementBroken(mob/Player/AI/Emplacement/E, mob/P)
		if(!E) return
		spawn(0)
			if(E) del E

client/DeviceDropTarget(atom/over, obj/Items/I)
	. = ..()
	if(. || !mob || !I) return
	if(!istype(over, /mob/Player/AI/Emplacement)) return 0
	var/mob/Player/AI/Emplacement/E = over
	if(!E.emp_device || !isturf(E.emp_device.loc)) return 0
	return E.emp_device.DeviceAcceptItem(mob, I)

/proc/EmpClearShot(mob/G, mob/T, obj/Items/Tech/D)
	if(!G || !T || !isturf(G.loc) || !isturf(T.loc) || G.z != T.z) return 0
	var/turf/a = G.loc
	var/turf/b = T.loc
	var/dx = b.x - a.x
	var/dy = b.y - a.y
	var/n = max(abs(dx), abs(dy))
	for(var/i = 1 to n - 1)
		var/turf/t = locate(a.x + round(dx * i / n, 1), a.y + round(dy * i / n, 1), a.z)
		if(!t || t.density) return 0
		for(var/atom/movable/O in t)
			if(O == G || O == T) continue
			if(ismob(O))
				var/mob/m = O
				if(m.density && D && D.GuardSpares(m)) return 0
			else if(O.density)
				if(istype(O, /obj/Traps/Force_Field))
					var/obj/Traps/Force_Field/F = O
					if(F.field_emitter && F.field_emitter.FieldPasses(G)) continue
				return 0
	return 1

/mob/Player/AI/Emplacement
	name = "Emplacement"
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "Turret"
	density = 1
	Savable = 0
	ai_hostility = 0
	ai_wander = 0
	ai_team_fire = 0
	var/tmp/obj/Items/Tech/emp_device

	New()
		..()
		ticking_ai -= src
		ai_state = "Idle"
		EmplacementIntent()
		ApplyPixelBounds()
		ApplyHurtbox()

	Update()
		return

	Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
		if(!EmplacementMobile()) return 0
		return ..()

	BeginKB(Direction, Distance, Ki, override_speed, thrown = 0)
		if(!EmplacementMobile()) return
		return ..()

	Unconscious(mob/P, text)
		EmplacementDown(P)

	Death(mob/P, text, SuperDead = 0, NoRemains = 0, extraChance, fakeDeath)
		EmplacementDown(P)

	EMPHit(strength)
		if(strength <= 0) return 0
		if(emp_device) return emp_device.EMPHit(strength)
		return 0

	Click(location, control, params)
		var/was = (usr.Target == src)
		..()
		if(!emp_device || get_dist(usr, src) > 1) return
		if(was) emp_device.DeviceMenu(usr)

	proc/EmplacementMobile()
		return 0

	proc/EmplacementKey()
		return emp_device ? emp_device.CreatorKey : null

	proc/EmplacementIntent()
		Lethal = 0
		WoundIntent = 0

	proc/EmplacementStats(pot)
		pot = max(1, pot)
		StrMod = 1
		EndMod = 1
		ForMod = 1
		OffMod = 1
		DefMod = 1
		SpdMod = 1
		if(Potential != pot)
			Potential = pot
			AIAvailablePower()

	proc/EmplacementHome()
		if(!emp_device || !isturf(emp_device.loc)) return
		if(loc != emp_device.loc) loc = emp_device.loc
		step_x = 0
		step_y = 0

	proc/EmplacementDown(mob/P)
		if(emp_device)
			emp_device.EmplacementBroken(src, P)
			return
		spawn(0)
			if(src) del src

	proc/EmplacementTarget(obj/Items/Gun/gun, obj/Items/Tech/D)
		if(!gun || !D) return null
		var/range = gun.ClassRange()
		var/mob/best
		var/bestd = 1.#INF
		var/mob/O = D.GuardOwnerMob()
		for(var/mob/M in view(range, src))
			if(M == src) continue
			if(!EmplacementValidTarget(M, D, O)) continue
			var/d = get_dist(src, M)
			if(d > range || d >= bestd) continue
			if(!EmpClearShot(src, M, D)) continue
			best = M
			bestd = d
		return best

	proc/EmplacementValidTarget(mob/M, obj/Items/Tech/D, mob/O = -1)
		if(!M || M.Dead || M.KO || !M.density) return 0
		if(M.PureRPMode || M.Stasis) return 0
		if(istype(M, /mob/Players))
			if(!M.client) return 0
		else if(istype(M, /mob/Player/AI))
			var/mob/Player/AI/A = M
			if(A.ai_hostility < 1) return 0
		else
			return 0
		if(D.GuardSpares(M, O)) return 0
		return 1

	proc/EmplacementShoot(mob/T)
		if(!T) return 0
		var/obj/Items/Gun/gun = EquippedGun()
		if(!gun || gun.Loaded <= 0) return 0
		if(Target != T) SetTarget(T)
		var/ang = GunTargetAngle(T)
		GunSetAimAngle(ang)
		var/d = GunAngleDir(ang)
		if(d) dir = d
		var/before = gun.Loaded
		Melee1()
		return gun && gun.Loaded < before
