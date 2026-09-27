/obj/Items/Tech/Door_Repair_Kit
	name = "Door Repair Kit"
	desc = "Patches a breached door so it closes and locks again. Stand next to the door and use the kit: the work takes 5 seconds and taking damage stops it."
	icon = 'Tech.dmi'
	icon_state = "ModernKit"
	TechType = "Engineering"
	SubType = "Engineering"
	Stackable = 1

	Click()
		if(loc != usr)
			return ..()
		if(Using)
			usr << "You are already repairing a door."
			return
		spawn() RepairUse(usr)

	proc/RepairTargets(mob/M)
		. = list()
		for(var/obj/Items/Tech/D in range(1, M))
			if(!isturf(D.loc) || !OrdDoorBreached(D)) continue
			.["[D.name] ([D.x], [D.y])"] = D

	proc/RepairUse(mob/M)
		if(!M || loc != M) return
		if(M.KO || M.InCombat())
			M << "You cannot patch a door in a fight."
			return
		var/list/doors = RepairTargets(M)
		if(!doors.len)
			M << "There is no breached door next to you."
			return
		var/obj/D
		if(doors.len == 1)
			D = doors[doors[1]]
		else
			var/pick = Ask(M, "Which door do you want to repair?", "[src]", null, "pick", doors, 1)
			if(!pick || !src || loc != M) return
			D = doors[pick]
		if(!D) return
		Using = 1
		var/start = world.time
		OMsg(M, "[M] starts patching [D].")
		while(world.time < start + DEV_REPAIR_TIME)
			sleep(2)
			if(!src || !M || !D || !D.loc || loc != M || M.KO || get_dist(M, D) > 1 || M.last_damaged_time > start || !OrdDoorBreached(D))
				if(src) Using = 0
				if(M) M << "The repair is interrupted."
				return
		Using = 0
		DoorRepairFinish(D)
		OMsg(M, "[M] finishes patching [D]. It closes and locks again.")
		if(Stackable && TotalStack > 1)
			TotalStack--
			suffix = "[TotalStack]"
			if(M.client) M.client.BuildInvPage()
			return
		loc = null
		if(M.client) M.client.BuildInvPage()
		del src

proc/DoorRepairFinish(obj/D)
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		X.breached = 0
		X.Close()
	else if(istype(D, /obj/Items/Tech/Reinforced_Door))
		var/obj/Items/Tech/Reinforced_Door/R = D
		R.breached = 0
		R.Close()
