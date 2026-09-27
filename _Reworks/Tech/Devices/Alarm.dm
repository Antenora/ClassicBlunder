var/list/dev_alarms = list()

proc/AlarmCheck(obj/door, mob/intruder, how = "tampered with")
	if(!door || !intruder) return 0
	. = 0
	for(var/obj/Items/Tech/Alarm/A in dev_alarms)
		if(A.alarm_mode != "door" || A.AlarmDoor() != door) continue
		if(A.AlarmTrip(intruder, "someone [how] [door] at ([door.x], [door.y])")) . = 1

proc/AlarmPing(owner, where)
	if(!owner || !where) return 0
	var/mob/Players/M
	for(var/mob/Players/P in players)
		if(P.DeviceKey() == owner)
			M = P
			break
	if(!M || !M.client) return 0
	var/obj/Items/Tech/Communicator/C
	for(var/obj/Items/Tech/Communicator/X in M)
		if(X.toggled_on)
			C = X
			break
	if(!C || IsJammed(M)) return 0
	var/line = "[BROADCAST_COLOR]<b>([C.name])</b> [where]"
	M.client.outputToChat(line, IC_OUTPUT)
	Log(M.ChatLog(), line)
	return 1

proc/AlarmGunshot(mob/M)
	if(!M || !dev_alarms.len) return
	if(M.GunIsSuppressed()) return
	for(var/obj/Items/Tech/Alarm/A in dev_alarms)
		if(A.alarm_mode != "area" || A.z != M.z) continue
		if(get_dist(A, M) > DEV_ALARM_RADIUS) continue
		A.AlarmTrip(M, "someone fired a gun near [A] at ([A.x], [A.y])")

mob/Players/GunStampShot(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	AlarmGunshot(src)

/obj/Items/Tech/Door/DoorToggle(mob/M, opening)
	..()
	if(opening && M) AlarmCheck(src, M, "opened")

/obj/Items/Tech/Reinforced_Door/Open()
	..()
	if(ismob(usr)) AlarmCheck(src, usr, "opened")

/obj/DeviceSensor
	name = "sensor"
	density = 0
	opacity = 0
	mouse_opacity = 0
	invisibility = 101
	Savable = 0
	Grabbable = 0
	Pickable = 0
	Attackable = 0
	Destructable = 0
	gfx_transient_visual = 1
	var/tmp/obj/Items/Tech/Alarm/sensor_for

	Crossed(atom/movable/A)
		..()
		if(ismob(A) && sensor_for) sensor_for.AlarmSensed(A)

/obj/Items/Tech/Alarm
	name = "Alarm"
	desc = "A door and motion sensor. Bolt it down, then bind it to a door within a tile or have it watch the area around it. Players you have not allowed set it off, and your Communicator tells you where. It burns one Power Pack a day."
	icon = 'device.dmi'
	icon_state = "infrared0"
	TechType = "Engineering"
	SubType = "Engineering"
	Pickable = 1
	Grabbable = 1
	UpdatesDescription = 1
	dev_hopper = 1
	dev_drain = DEV_PER_DAY(DEV_DRAIN_ALARM)
	var
		alarm_mode = "area"
		alarm_door_x = 0
		alarm_door_y = 0
		alarm_door_z = 0
		list/alarm_keys = list()
		alarm_last = ""
		tmp/alarm_next = 0
		tmp/obj/alarm_door_ref
		tmp/obj/DeviceSensor/alarm_sensor

	New()
		..()
		spawn(1)
			if(src && isturf(loc) && !Grabbable) DeviceRegister()

	Del()
		dev_alarms -= src
		AlarmDropSensor()
		..()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down and set it up."
			return
		DeviceMenu(usr)

	DevicePowerChanged(on)
		icon_state = on ? "infrared1" : "infrared0"
		if(on) dev_alarms |= src
		else dev_alarms -= src
		AlarmSyncSensor()

	DevicePowerTick(minutes)
		..()
		if(dev_live) AlarmSyncSensor()

	proc/AlarmAllows(mob/M)
		if(!istype(M, /mob/Players)) return 1
		var/k = M.DeviceKey()
		if(!k) return 0
		return k == CreatorKey || (k in alarm_keys)

	proc/AlarmDoor()
		if(alarm_mode != "door") return null
		var/turf/T = locate(alarm_door_x, alarm_door_y, alarm_door_z)
		if(!T) return null
		if(alarm_door_ref && alarm_door_ref.loc == T) return alarm_door_ref
		alarm_door_ref = null
		for(var/obj/Items/Tech/D in T)
			if(istype(D, /obj/Items/Tech/Door) || istype(D, /obj/Items/Tech/Reinforced_Door))
				alarm_door_ref = D
				return D
		return null

	proc/AlarmDropSensor()
		if(!alarm_sensor) return
		alarm_sensor.sensor_for = null
		alarm_sensor.loc = null
		alarm_sensor = null

	proc/AlarmSyncSensor()
		if(alarm_mode != "area" || !dev_live || !isturf(loc))
			AlarmDropSensor()
			return
		var/lx = max(1, x - DEV_ALARM_RADIUS)
		var/ly = max(1, y - DEV_ALARM_RADIUS)
		var/turf/T = locate(lx, ly, z)
		if(!T) return
		var/w = (min(world.maxx, x + DEV_ALARM_RADIUS) - lx + 1) * 32
		var/h = (min(world.maxy, y + DEV_ALARM_RADIUS) - ly + 1) * 32
		if(!alarm_sensor)
			alarm_sensor = new
			alarm_sensor.sensor_for = src
		alarm_sensor.bound_width = w
		alarm_sensor.bound_height = h
		if(alarm_sensor.loc != T) alarm_sensor.loc = T

	proc/AlarmSensed(mob/M)
		if(alarm_mode != "area" || !M || M.z != z) return
		if(get_dist(src, M) > DEV_ALARM_RADIUS) return
		AlarmTrip(M, "someone entered the area around [src] at ([x], [y])")

	proc/AlarmTrip(mob/M, what)
		if(!M || AlarmAllows(M)) return 0
		if(!dev_live || world.time < alarm_next) return 0
		alarm_next = world.time + DEV_ALARM_COOLDOWN
		flick("talarm2", src)
		for(var/mob/Players/P in hearers(DEV_ALARM_HEAR, src))
			P << sound('Sounds/scouter.wav', volume = 60)
		OrdAreaLine(src, "<font color='#ff6b6b'>[src] blares!</font>")
		alarm_last = "[time2text(world.realtime, "hh:mm")]: [what]"
		if(!IsJammed(src)) AlarmPing(CreatorKey, "Alarm: [what].")
		return 1

	proc/AlarmBindDoor(mob/M)
		var/list/doors = list()
		for(var/obj/Items/Tech/D in range(1, src))
			if(!isturf(D.loc)) continue
			if(istype(D, /obj/Items/Tech/Door) || istype(D, /obj/Items/Tech/Reinforced_Door))
				doors["[D.name] ([D.x], [D.y])"] = D
		if(!doors.len)
			M << "There is no door within a tile of [src]."
			return
		var/obj/D
		if(doors.len == 1)
			D = doors[doors[1]]
		else
			var/pick = Ask(M, "Which door should [src] watch?", "[src]", null, "pick", doors, 1)
			if(!pick || !src) return
			D = doors[pick]
		if(!D || !D.loc) return
		alarm_mode = "door"
		alarm_door_x = D.x
		alarm_door_y = D.y
		alarm_door_z = D.z
		alarm_door_ref = D
		AlarmSyncSensor()
		M << "[src] now watches [D.name]."

	proc/AlarmWatchArea(mob/M)
		alarm_mode = "area"
		alarm_door_ref = null
		AlarmSyncSensor()
		M << "[src] now watches everything within [DEV_ALARM_RADIUS] tiles."

	proc/AlarmAllowKey(mob/M)
		var/k = PromptKnownKey(M, "Allow a key")
		if(!k || !src) return
		k = ckey(k)
		if(!length(k)) return
		if(k == CreatorKey)
			M << "You are always allowed past your own alarm."
			return
		alarm_keys |= k
		M << "[k] can now pass [src] without setting it off."

	proc/AlarmRemoveKey(mob/M)
		if(!alarm_keys.len)
			M << "No keys are allowed yet."
			return
		var/k = Ask(M, "Stop allowing which key?", "[src]", null, "pick", alarm_keys, 1)
		if(!k || !src) return
		alarm_keys -= k
		M << "[k] will set [src] off again."

	DeviceActions(mob/M)
		. = ..()
		if(!DeviceIsOwner(M)) return
		. += "Watch a door"
		. += "Watch the area"
		. += "Allow a key"
		if(alarm_keys.len) . += "Stop allowing a key"
		. += "Last trip"

	DeviceAct(mob/M, act)
		switch(act)
			if("Watch a door")
				AlarmBindDoor(M)
			if("Watch the area")
				AlarmWatchArea(M)
			if("Allow a key")
				AlarmAllowKey(M)
			if("Stop allowing a key")
				AlarmRemoveKey(M)
			if("Last trip")
				M << (alarm_last ? "[src] last went off at [alarm_last]" : "[src] has not gone off.")
			else
				..()

	DeviceStatus(mob/M)
		if(!DeviceIsOwner(M)) return list("An alarm sensor.")
		. = ..()
		if(alarm_mode == "door")
			var/obj/D = AlarmDoor()
			. += D ? "Watching [D.name] at ([D.x], [D.y])." : "Watching a door that is gone. Bind it again."
		else
			. += "Watching everything within [DEV_ALARM_RADIUS] tiles."
		. += alarm_keys.len ? "Allowed: [jointext(alarm_keys, ", ")]" : "Allowed: only you."
