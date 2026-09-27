/obj/Items/Tech/Communicator/RelayToTowers(mob/speaker, msg)
	if(!speaker || !Frequency) return
	for(var/obj/Items/Tech/Transmission_Tower/T in dev_registry)
		if(T.Frequency != Frequency || !T.TowerLive()) continue
		T.TowerBroadcast(speaker, msg)

/obj/Items/Tech/Transmission_Tower
	dev_hopper = 1
	dev_drain = DEV_PER_DAY(DEV_DRAIN_TOWER)
	UpdatesDescription = 1
	desc = "A long-range relay. Anything said on its frequency over a Scouter, a Communicator or internal comms is broadcast to everyone on this world who carries one. It burns one Power Pack a day; a Jammer or an EMP silences it."

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

	TowerLive()
		return dev_live && Frequency && !IsJammed(src)

	proc/TowerBroadcast(mob/speaker, msg)
		var/line = "<font color=red><b>(Long-Range Frequency)</b> [speaker.name]: [msg]"
		for(var/mob/Players/P in players)
			if(P.z != z || !P.client) continue
			if(!(locate(/obj/Items/Tech/Scouter) in P) && !(locate(/obj/Items/Tech/Communicator) in P) && !(locate(/obj/Skills/Utility/Internal_Communicator) in P)) continue
			P.client.outputToChat(line, IC_OUTPUT)
			Log(P.ChatLog(), "<font color=red>(Long-Range Frequency)[speaker]([speaker.key]) says: [msg]")

	DeviceActions(mob/M)
		. = ..()
		if(DeviceIsOwner(M)) . += "Set the frequency"

	DeviceAct(mob/M, act)
		if(act == "Set the frequency")
			if(!DeviceIsOwner(M)) return
			var/f = Ask(M, "Which frequency should [src] relay?", "[src]", Frequency, "num", null, 1)
			if(isnull(f) || !src) return
			Frequency = f
			M << "[src] now relays frequency [Frequency]."
			return
		..()

	DeviceStatus(mob/M)
		. = ..()
		if(DeviceIsOwner(M)) . += Frequency ? "Relaying frequency [Frequency]." : "No frequency set."
		if(dev_live && IsJammed(src)) . += "Something is jamming it."

/obj/Items/Tech/Beacon
	UpdatesDescription = 1
	desc = "A locator beacon. Switched on and set down, it shows its position in the Scouter scans of its owner and the keys they allow. A Jammer hides it."
	var/list/beacon_keys = list()

	proc/Update_Description()
		desc = "[initial(desc)]<br><br>It is switched [BeaconState == "On" ? "on" : "off"]."

	BeaconShows(mob/M)
		if(BeaconState != "On" || !isturf(loc) || !M) return 0
		if(IsJammed(src)) return 0
		var/k = M.DeviceKey()
		return k && (k == CreatorKey || (k in beacon_keys))

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to set it up."
			return
		DeviceMenu(usr)

	DeviceMenu(mob/M)
		if(!DeviceIsOwner(M))
			M << "[src] belongs to someone else."
			return
		..()

	DeviceActions(mob/M)
		. = ..()
		if(!DeviceIsOwner(M)) return
		. += (BeaconState == "On") ? "Switch off" : "Switch on"
		. += "Allow a key"
		if(beacon_keys.len) . += "Stop allowing a key"

	DeviceAct(mob/M, act)
		switch(act)
			if("Switch on", "Switch off")
				BeaconState = (BeaconState == "On") ? "Off" : "On"
				icon_state = (BeaconState == "On") ? "talarm1" : "talarm0"
				M << "You switch [src] [BeaconState == "On" ? "on" : "off"]."
			if("Allow a key")
				var/k = PromptKnownKey(M, "Allow a key")
				if(!k || !src) return
				k = ckey(k)
				if(!length(k) || k == CreatorKey) return
				beacon_keys |= k
				M << "[k] can now see [src] in their scans."
			if("Stop allowing a key")
				var/r = Ask(M, "Stop allowing which key?", "[src]", null, "pick", beacon_keys, 1)
				if(!r || !src) return
				beacon_keys -= r
				M << "[r] can no longer see [src]."
			else
				..()

	DeviceStatus(mob/M)
		. = ..()
		. += "It is switched [BeaconState == "On" ? "on" : "off"]."
		. += beacon_keys.len ? "Allowed: [jointext(beacon_keys, ", ")]" : "Only you see it."
