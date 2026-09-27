/obj/Items/Tech/Aid_Station
	name = "Aid Station"
	desc = "A clinic cabinet that holds up to 10 First Aid Kits. Anyone can click it to take one, once every 5 minutes. Stock it by dragging kits onto it; its owner can also empty it. It needs no power."
	icon = 'device.dmi'
	icon_state = "health"
	TechType = "Medicine"
	SubType = "Trauma Care"
	Pickable = 1
	Grabbable = 1
	UpdatesDescription = 1
	var/list/aid_taken = list()

	proc/Update_Description()
		desc = "[DeviceDescText()]<br><br>Kits inside: [AidCount()] of [DEV_AID_CAP]"

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	proc/AidCount()
		. = 0
		for(var/obj/Items/Tech/First_Aid_Kit/K in src)
			.++

	proc/AidAdd(mob/M, obj/Items/Tech/First_Aid_Kit/K)
		if(!K || K.loc != M) return 0
		if(Grabbable)
			M << "Bolt [src] down before stocking it."
			return 1
		if(K.suffix == "*Equipped*")
			M << "Take [K] off first."
			return 1
		if(AidCount() >= DEV_AID_CAP)
			M << "[src] is full."
			return 1
		K.loc = src
		M << "You stock [src] with [K]. It holds [AidCount()] kits."
		if(M.client) M.client.BuildInvPage()
		return 1

	proc/AidTake(mob/M)
		if(Grabbable)
			M << "[src] is not bolted down yet."
			return
		var/obj/Items/Tech/First_Aid_Kit/K = locate() in src
		if(!K)
			M << "[src] is empty."
			return
		var/k = M.DeviceKey()
		if(!k) return
		var/last = aid_taken[k]
		if(!DeviceIsOwner(M) && isnum(last) && world.realtime < last + DEV_AID_COOLDOWN)
			M << "You took a kit recently. Try again in [round((last + DEV_AID_COOLDOWN - world.realtime) / 600) + 1] minutes."
			return
		if(!M.CanPickupItem(K))
			M << "Your pack has no room for [K]."
			return
		aid_taken[k] = world.realtime
		K.loc = M
		OMsg(M, "[M] takes a First Aid Kit from [src].")
		if(M.client) M.client.BuildInvPage()

	proc/AidEmpty(mob/M)
		var/n = 0
		for(var/obj/Items/Tech/First_Aid_Kit/K in src)
			M.GiveOrDrop(K, 1)
			n++
		M << (n ? "You empty [n] kits out of [src]." : "[src] is already empty.")

	DeviceAcceptItem(mob/M, obj/Items/I)
		if(istype(I, /obj/Items/Tech/First_Aid_Kit))
			if(get_dist(M, src) > 1)
				M << "Get next to [src] to stock it."
				return 1
			return AidAdd(M, I)
		return ..()

	DeviceActions(mob/M)
		. = ..()
		if(Grabbable) return
		. += "Take a First Aid Kit"
		if(locate(/obj/Items/Tech/First_Aid_Kit) in M) . += "Stock a First Aid Kit"
		if(DeviceIsOwner(M) && AidCount()) . += "Empty it"

	DeviceAct(mob/M, act)
		switch(act)
			if("Take a First Aid Kit")
				AidTake(M)
			if("Stock a First Aid Kit")
				AidAdd(M, locate(/obj/Items/Tech/First_Aid_Kit) in M)
			if("Empty it")
				if(DeviceIsOwner(M)) AidEmpty(M)
			else
				..()

	DeviceStatus(mob/M)
		. = ..()
		. += "Kits inside: [AidCount()] of [DEV_AID_CAP]."
