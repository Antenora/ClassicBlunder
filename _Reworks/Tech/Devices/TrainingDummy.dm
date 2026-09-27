/strikeHook/trainingDummyReadout
	stage = "post"
	fire(strike/S)
		var/mob/Player/AI/Training_Dummy/D = S.defender
		if(istype(D) && S.attacker && S.dealt > 0) D.DummyHit(S.attacker, S.dealt)

/obj/Items/Tech/PunchingBag
	name = "Training Dummy"
	desc = "A padded target for practice. Bolt it down and hit it: every hit tells you the damage it took and your damage per second over the last 10 seconds. It resets every 30 seconds, or when someone clicks it."
	icon = 'PunchingBag.dmi'
	TechType = "Engineering"
	SubType = "Engineering"
	Pickable = 1
	Grabbable = 1
	var/tmp/mob/Player/AI/Training_Dummy/dummy_mob

	New()
		..()
		spawn(1)
			if(src)
				if(isturf(loc) && !Grabbable) DeviceRegister()
				else DummyDrop()

	Del()
		DummyDrop()
		..()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DevicePowerChanged(on)
		DummySync()

	DevicePowerTick(minutes)
		..()
		DummySync()

	proc/DummySync()
		if(DevicePlaced())
			if(!dummy_mob || !dummy_mob.loc)
				dummy_mob = new(loc)
				dummy_mob.dummy_of = src
			dummy_mob.DummyHome()
			invisibility = 101
			mouse_opacity = 0
		else
			DummyDrop()

	proc/DummyDrop()
		invisibility = 0
		mouse_opacity = 1
		if(!dummy_mob) return
		var/mob/Player/AI/Training_Dummy/D = dummy_mob
		dummy_mob = null
		D.dummy_of = null
		D.loc = null
		spawn() del D

	DeviceStatus(mob/M)
		. = ..()
		if(dummy_mob) . += "It stands ready. Click it again once it is your target to reset it."

/mob/Player/AI/Training_Dummy
	name = "Training Dummy"
	icon = 'PunchingBag.dmi'
	density = 1
	ai_hostility = 0
	ai_wander = 0
	var
		tmp/obj/Items/Tech/PunchingBag/dummy_of
		tmp/list/dummy_log

	New()
		..()
		ticking_ai -= src
		ai_state = "Idle"
		dummy_log = list()
		ApplyPixelBounds()
		ApplyHurtbox()
		spawn(DEV_DUMMY_RESET) DummyResetLoop()

	Update()
		return

	Unconscious(mob/P, text)
		DummyReset()

	Death(mob/P, text, SuperDead = 0, NoRemains = 0, extraChance, fakeDeath)
		DummyReset()

	Click()
		var/was = (usr.Target == src)
		..()
		if(!dummy_of || get_dist(usr, src) > 1) return
		if(was && dummy_of.DeviceIsOwner(usr))
			dummy_of.DeviceMenu(usr)
			return
		DummyReset(1)
		usr << "[src] resets."

	proc/DummyResetLoop()
		set waitfor = 0
		while(src && dummy_of)
			DummyReset()
			sleep(DEV_DUMMY_RESET)

	proc/DummyHome()
		if(!dummy_of || !isturf(dummy_of.loc)) return
		if(loc != dummy_of.loc) loc = dummy_of.loc
		step_x = 0
		step_y = 0

	proc/DummyReset(clear = 0)
		SetHealthPct(100)
		TotalInjury = 0
		TotalFatigue = 0
		if(KO) Conscious()
		DummyHome()
		if(clear) dummy_log = list()

	proc/DummyHit(mob/A, dmg)
		flick("Hit", src)
		DummyHome()
		var/list/L = dummy_log[A]
		if(!L)
			L = list()
			dummy_log[A] = L
		L += world.time
		L += dmg
		var/cut = world.time - DEV_DUMMY_DPS_WINDOW
		while(L.len >= 2 && L[1] < cut)
			L.Cut(1, 3)
		var/total = 0
		for(var/i = 2, i <= L.len, i += 2)
			total += L[i]
		A << "<font color='#bfefff'>[src]: hit for [round(dmg, 0.1)]. Last 10 s: [round(total * 10 / DEV_DUMMY_DPS_WINDOW, 0.1)] per second.</font>"
