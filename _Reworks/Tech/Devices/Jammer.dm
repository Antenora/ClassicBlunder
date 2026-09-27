#define JAM_HAND_RADIUS 5
#define JAM_HAND_CHARGE 10
#define JAM_HAND_TICK 600

/obj/Items/Tech/Jammer
	name = "Jammer"
	desc = "A pocket jammer. Click it to switch it on: while you carry it, communicators, scouters, beacons, alarms and tracker tags within 5 tiles stop working, yours included. It spends 1 charge a minute; a Power Pack recharges it."
	icon = 'device.dmi'
	icon_state = "electropack0"
	TechType = "Telecommunications"
	SubType = "Intrusion Tools"
	UpdatesDescription = 1
	var
		Uses = JAM_HAND_CHARGE
		MaxUses = JAM_HAND_CHARGE
		tmp/jam_on = 0
		tmp/jam_looping = 0

	proc/Update_Description()
		desc = "[initial(desc)]<br><br>Charge: [Uses] of [MaxUses] minutes. It is switched [jam_on ? "on" : "off"]."

	Click()
		if(loc != usr)
			return ..()
		JamToggle(usr)

	Del()
		dev_hand_jammers -= src
		..()

	JamReaches(turf/T)
		if(!jam_on || !T || !ismob(loc)) return 0
		var/turf/J = get_turf(src)
		return J && J.z == T.z && get_dist(J, T) <= JAM_HAND_RADIUS

	proc/JamToggle(mob/M)
		if(jam_on)
			JamOff(M, "You switch [src] off.")
			return
		if(M.Secret == "Heavenly Restriction" && M.secretDatum?:hasRestriction("Science"))
			M << "The device will not work in your hands."
			return
		if(Uses < 1)
			M << "[src] has no charge. A Power Pack recharges it."
			return
		Uses--
		jam_on = 1
		icon_state = "electropack1"
		dev_hand_jammers |= src
		M << "You switch [src] on. Radios, scouters and alarms within [JAM_HAND_RADIUS] tiles go quiet, yours included."
		if(M.client) M.client.BuildInvPage()
		if(!jam_looping)
			jam_looping = 1
			spawn(JAM_HAND_TICK) JamLoop()

	proc/JamOff(mob/M, msg)
		jam_on = 0
		icon_state = "electropack0"
		dev_hand_jammers -= src
		if(M && msg) M << msg
		if(M && M.client) M.client.BuildInvPage()

	proc/JamLoop()
		set waitfor = 0
		while(jam_on)
			if(!ismob(loc))
				JamOff(null, null)
				break
			if(Uses < 1)
				JamOff(loc, "[src] runs out of charge and switches off.")
				break
			Uses--
			sleep(JAM_HAND_TICK)
		jam_looping = 0

/obj/Items/Tech/Power_Pack/RechargeExtras(mob/user)
	. = ..()
	for(var/obj/Items/Tech/Jammer/J in user)
		if(J.Uses < J.MaxUses) . += J
