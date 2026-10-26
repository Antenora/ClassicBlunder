var/list/dev_registry = list()
var/dev_power_running = 0

proc/DevicePowerLoop()
	set waitfor = 0
	set background = 1
	while(1)
		sleep(DEV_POWER_TICK)
		dev_registry -= null
		for(var/obj/Items/Tech/D in dev_registry.Copy())
			D.DevicePowerTick(DEV_POWER_TICK / 600)

proc/DeviceTimeText(minutes)
	if(minutes < 1) return "under a minute"
	if(minutes < 120) return "[round(minutes)] min"
	if(minutes < 2880) return "[round(minutes / 60)] h"
	return "[round(minutes / 1440)] days"

mob/proc/DeviceKey()
	return ckey

client/DeviceDropTarget(atom/over, obj/Items/I)
	. = ..()
	if(. || !mob || !I) return
	if(!istype(over, /obj/Items/Tech) || !isturf(over.loc)) return 0
	var/obj/Items/Tech/D = over
	return D.DeviceAcceptItem(mob, I)

/obj/Items/Tech
	var
		dev_hopper = 0
		dev_packs = 0
		dev_cap = DEV_HOPPER_CAP
		dev_drain = 0
		tmp/dev_stall_until = 0
		tmp/dev_live = 0

	proc/DeviceIsOwner(mob/M)
		if(!M || !CreatorKey) return 0
		var/k = M.DeviceKey()
		return k && k == CreatorKey

	proc/DeviceDescText()
		. = "[initial(desc)]"
		if(dev_hopper) . += "<br><br>[DevicePowerLine()]"

	proc/DevicePlaced()
		return isturf(loc) && !Grabbable

	proc/DeviceStalled()
		return world.time < dev_stall_until

	proc/DevicePowered()
		if(DeviceStalled()) return 0
		if(!dev_hopper) return 1
		return dev_packs > 0

	proc/DeviceDrawing()
		return DevicePlaced()

	proc/DeviceLive()
		return dev_live

	proc/DeviceStall(ds)
		dev_stall_until = max(dev_stall_until, world.time + ds)
		DevicePowerCheck()
		spawn(ds + 1)
			if(src) DevicePowerCheck()

	proc/DeviceRegister()
		if(!(src in dev_registry)) dev_registry += src
		if(!dev_power_running)
			dev_power_running = 1
			DevicePowerLoop()
		DevicePowerCheck()

	proc/DeviceUnregister()
		dev_registry -= src
		DevicePowerCheck()

	proc/DevicePowerTick(minutes)
		if(!isturf(loc))
			DeviceUnregister()
			return
		if(dev_hopper && dev_drain > 0 && dev_packs > 0 && !DeviceStalled() && DeviceDrawing())
			dev_packs -= dev_drain * minutes
			if(dev_packs < 0.001) dev_packs = 0
		DevicePowerCheck()

	proc/DevicePowerCheck()
		var/on = (DevicePlaced() && DevicePowered()) ? 1 : 0
		if(on == dev_live) return
		dev_live = on
		DevicePowerChanged(on)

	proc/DevicePowerChanged(on)
		return

	proc/DeviceEMP(strength)
		return

	proc/DeviceInsertPack(mob/M, obj/Items/Tech/Power_Pack/P)
		if(!dev_hopper || !M || !P || P.loc != M) return 0
		if(dev_packs + 1 > dev_cap)
			M << "[src] is full: [DevicePowerLine()]."
			return 1
		if(P.Stackable && P.TotalStack > 1)
			P.TotalStack--
			P.suffix = "[P.TotalStack]"
		else
			del P
		dev_packs += 1
		M << "You load a Power Pack into [src]. [DevicePowerLine()]."
		if(M.client) M.client.BuildInvPage()
		DevicePowerCheck()
		return 1

	proc/DeviceInsertFromPack(mob/M)
		if(!M) return 0
		var/obj/Items/Tech/Power_Pack/P = locate() in M
		if(!P)
			M << "You have no Power Packs."
			return 0
		return DeviceInsertPack(M, P)

	proc/DeviceAcceptItem(mob/M, obj/Items/I)
		if(!dev_hopper || !istype(I, /obj/Items/Tech/Power_Pack)) return 0
		if(get_dist(M, src) > 1)
			M << "Get next to [src] to load it."
			return 1
		DeviceInsertPack(M, I)
		return 1

	proc/DevicePowerLine()
		if(!dev_hopper) return ""
		. = "Power: [round(dev_packs, 0.1)] of [dev_cap] packs"
		if(DeviceStalled())
			. += ", stalled for [round((dev_stall_until - world.time) / 10) + 1] s"
		else if(dev_drain > 0 && dev_packs > 0)
			. += ", about [DeviceTimeText(dev_packs / dev_drain)] left while running"

	proc/DeviceBoltToggle(mob/M)
		if(!M || !isturf(loc)) return 0
		if(!DeviceIsOwner(M))
			M << "[src] belongs to someone else."
			return 0
		if(Grabbable)
			for(var/obj/Items/i in loc)
				if(i != src && !i.Grabbable)
					M << "Something else is already bolted here."
					return 0
			Grabbable = 0
			OMsg(M, "[M] bolts [src] down.")
			DeviceRegister()
		else
			Grabbable = 1
			OMsg(M, "[M] unbolts [src].")
			DeviceUnregister()
		return 1

	proc/DeviceActions(mob/M)
		. = list()
		if(!isturf(loc)) return
		if(dev_hopper) . += "Insert Power Pack"
		if(DeviceIsOwner(M)) . += (Grabbable ? "Bolt down" : "Unbolt")

	proc/DeviceAct(mob/M, act)
		switch(act)
			if("Insert Power Pack")
				DeviceInsertFromPack(M)
			if("Bolt down", "Unbolt")
				DeviceBoltToggle(M)

	proc/DeviceStatus(mob/M)
		. = list()
		if(Grabbable && isturf(loc)) . += "Not bolted down: it does nothing until its owner bolts it."
		if(dev_hopper) . += DevicePowerLine()

	proc/DeviceMenu(mob/M)
		if(!M || !M.client || !isturf(loc)) return
		if(get_dist(M, src) > 1)
			M << "Get next to [src] first."
			return
		if(M.Secret == "Heavenly Restriction" && M.secretDatum?:hasRestriction("Science"))
			M << "[src] sparks and will not answer your touch."
			return
		if(DevicePlaced() && !(src in dev_registry)) DeviceRegister()
		var/list/acts = DeviceActions(M)
		var/list/lines = DeviceStatus(M)
		if(!acts.len)
			if(lines.len) M << "[src]: [jointext(lines, " ")]"
			return
		var/act = Ask(M, lines.len ? jointext(lines, "\n") : "What do you want to do?", "[src]", null, "pick", acts, 1)
		if(!act || !src || get_dist(M, src) > 1) return
		DeviceAct(M, act)

	EMPHit(strength)
		if(!dev_hopper) return ..()
		if(strength <= 0) return 0
		var/had = dev_packs > 0 || dev_live
		dev_packs = 0
		DeviceStall(DEV_EMP_STALL * strength)
		DeviceEMP(strength)
		if(had && isturf(loc)) OrdAreaLine(src, "<font color='#8be9ff'>[src] sparks and goes dark.</font>")
		return 1
