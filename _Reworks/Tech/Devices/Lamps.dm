/obj/Items/Tech/Lamp
	name = "Lamp"
	desc = "A standing lamp that casts a warm glow once it is bolted down. Its owner clicks it to switch it on or off. It needs no power."
	icon = 'Lamp.png'
	TechType = "Engineering"
	SubType = "Engineering"
	surface_profile = "prop_medium"
	Pickable = 1
	Grabbable = 1
	var
		lamp_on = 1
		lamp_radius = DEV_LAMP_RADIUS

	New()
		..()
		spawn(3)
			if(src) LampSync()

	Del()
		LightPropDetach(src)
		..()

	Move()
		. = ..()
		LampSync()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DevicePowerChanged(on)
		LampSync()

	proc/LampLit()
		return lamp_on && DevicePlaced()

	proc/LampSync()
		if(LampLit())
			if(!attached_light) LightPropAttach(src, lamp_radius, DEV_LAMP_COLOR, DEV_LAMP_ALPHA, 0)
		else if(attached_light)
			LightPropDetach(src)

	DeviceActions(mob/M)
		. = ..()
		if(DeviceIsOwner(M) && !Grabbable) . += (lamp_on ? "Switch off" : "Switch on")

	DeviceAct(mob/M, act)
		switch(act)
			if("Switch off", "Switch on")
				if(!DeviceIsOwner(M))
					M << "[src] belongs to someone else."
					return
				lamp_on = !lamp_on
				LampSync()
				M << "You switch [src] [lamp_on ? "on" : "off"]."
			else
				..()
				LampSync()

	DeviceStatus(mob/M)
		. = ..()
		if(!Grabbable) . += "It is switched [lamp_on ? "on" : "off"]."

	DeviceMenu(mob/M)
		if(!DeviceIsOwner(M))
			M << "[src] belongs to someone else."
			return
		..()

/obj/Items/Tech/Street_Light
	parent_type = /obj/Items/Tech/Lamp
	name = "Street Light"
	desc = "A tall street light that lights a wide circle once it is bolted down. Its owner clicks it to switch it on or off. It needs no power."
	icon = 'Lampost.png'
	lamp_radius = DEV_STREET_RADIUS
