/obj/var/cloak_field_hidden = 0
/obj/var/tmp/cloak_reveal_until = 0

mob/var/tmp/cloak_revealed = 0
mob/var/tmp/cloak_reveal_until = 0
mob/var/tmp/cloak_looping = 0
mob/var/tmp/cloak_active = 0

atom/proc/RevealCloaked(radius, secs = DEV_REVEAL_SECS)
	var/turf/T = get_turf(src)
	if(!T || radius < 0) return 0
	. = 0
	for(var/mob/M in range(radius, T))
		if(M.IsCloaked())
			M.CloakReveal(secs)
			.++
	for(var/obj/Items/O in range(radius, T))
		if(O.cloak_field_hidden && isturf(O.loc))
			CloakObjReveal(O, secs)
			.++

proc/CloakObjHide(obj/O)
	O.cloak_field_hidden = 1
	if(world.time >= O.cloak_reveal_until) O.invisibility = DEV_CLOAK_FIELD_INVIS

proc/CloakObjShow(obj/O)
	O.cloak_field_hidden = 0
	O.cloak_reveal_until = 0
	O.invisibility = 0

proc/CloakObjReveal(obj/O, secs)
	O.cloak_reveal_until = max(O.cloak_reveal_until, world.time + secs * 10)
	O.invisibility = 0
	spawn(secs * 10 + 1)
		if(O && O.cloak_field_hidden && world.time >= O.cloak_reveal_until)
			O.invisibility = DEV_CLOAK_FIELD_INVIS

mob/proc/CloakBuff()
	return locate(/obj/Skills/Buffs/SlotlessBuffs/Optic_Cloak) in src

mob/proc/IsCloaked()
	var/obj/Skills/Buffs/B = CloakBuff()
	return B && BuffOn(B)

mob/proc/CloakItem()
	var/obj/Items/Tech/Cloak/best
	for(var/obj/Items/Tech/Cloak/C in src)
		if(C.Uses > 0 && (!best || C.Uses > best.Uses)) best = C
	return best

mob/proc/CloakReveal(secs)
	cloak_reveal_until = max(cloak_reveal_until, world.time + secs * 10)
	if(!cloak_revealed)
		cloak_revealed = 1
		invisibility = max(0, invisibility - DEV_CLOAK_INVISIBLE)
		animate(src, alpha = 255, time = 3)
		src << "<font color='#ff6b6b'>You are exposed!</font>"
	spawn(secs * 10 + 1) CloakRevealEnd()

mob/proc/CloakRevealEnd()
	if(!cloak_revealed || world.time < cloak_reveal_until) return
	cloak_revealed = 0
	if(IsCloaked())
		invisibility += DEV_CLOAK_INVISIBLE
		animate(src, alpha = 50, time = 3)

mob/proc/CloakUnreveal()
	if(!cloak_revealed) return
	cloak_revealed = 0
	cloak_reveal_until = 0
	invisibility += DEV_CLOAK_INVISIBLE

mob/proc/CloakOff(why)
	if(!cloak_active) return 0
	cloak_active = 0
	var/obj/Skills/Buffs/B = CloakBuff()
	if(!B || !BuffOn(B)) return 0
	CloakUnreveal()
	B.Trigger(src, Override = 1)
	if(why) src << "<font color='#8be9ff'>[why]</font>"
	return 1

mob/proc/CloakToggle(obj/Skills/Buffs/SlotlessBuffs/Optic_Cloak/B)
	if(!B) return
	if(BuffOn(B))
		cloak_active = 0
		CloakUnreveal()
		B.Trigger(src)
		return
	if(InCombat())
		src << "You cannot cloak in a fight."
		return
	var/obj/Items/Tech/Cloak/C = CloakItem()
	if(!C)
		src << "Your Cloak has no charge. Recharge it with a Power Pack."
		return
	B.Trigger(src)
	if(!BuffOn(B)) return
	cloak_active = 1
	C.Uses = max(0, C.Uses - 1)
	if(!cloak_looping)
		cloak_looping = 1
		spawn(DEV_CLOAK_TICK) CloakLoop()

mob/proc/CloakLoop()
	set waitfor = 0
	while(IsCloaked())
		var/obj/Items/Tech/Cloak/C = CloakItem()
		if(!C)
			CloakOff("Your Cloak runs out of power and you flicker back into view.")
			break
		C.Uses = max(0, C.Uses - 1)
		sleep(DEV_CLOAK_TICK)
	cloak_looping = 0
	if(!IsCloaked()) cloak_active = 0

mob/MarkCombat(mob/other)
	..()
	CloakOff("Your Cloak drops as the fight starts.")
	if(other && other != src) other.CloakOff("Your Cloak drops as the fight starts.")

mob/Players/EMPHit(strength)
	. = ..()
	if(strength > 0 && CloakOff("The pulse shorts out your Cloak.")) . = 1

/obj/Items/Tech/Power_Pack/RechargeExtras(mob/user)
	. = ..()
	for(var/obj/Items/Tech/Cloak/C in user)
		if(C.Uses < C.MaxUses) . += C

/obj/Skills/Buffs/SlotlessBuffs/Optic_Cloak
	BuffName = "Optic Cloak"
	desc = "Bends light around you so others cannot see you. It needs a charged Cloak in your pack, spends 1 of its charge a minute, and drops the moment a fight starts or an EMP hits you. Flares and scanners expose you for a moment."
	Invisible = DEV_CLOAK_INVISIBLE
	Cooldown = 10
	ActiveMessage = "shimmers and fades from sight..."
	OffMessage = "flickers back into view!"
	verb/Optic_Cloak()
		set category = "Skills"
		usr.CloakToggle(src)

/obj/Items/Tech/Cloak
	desc = "A personal cloaking rig. Click it to bend light around you; its skill can also go on your hotbar. It spends 1 charge a minute and drops when a fight starts or an EMP hits you. A Power Pack recharges it."
	UpdatesDescription = 1
	var
		Uses = DEV_CLOAK_USES
		MaxUses = DEV_CLOAK_USES

	proc/Update_Description()
		desc = "[initial(desc)]<br><br>Charge: [Uses] of [MaxUses] minutes."

	Click()
		if(loc != usr)
			return ..()
		var/obj/Skills/Buffs/SlotlessBuffs/Optic_Cloak/B = usr.CloakBuff()
		if(!B)
			B = new
			usr.AddSkill(B)
		usr.CloakToggle(B)

/obj/Items/Tech/Cloak_Controls
	dev_hopper = 1
	dev_drain = DEV_PER_MINUTE(DEV_DRAIN_CLOAK_FIELD)
	UpdatesDescription = 1
	desc = "A cloaking field generator. Bolted down and switched on, it hides every item its owner made within 5 tiles. Flares expose the hidden things for a moment. It burns half a Power Pack a minute while the field is up; an EMP drops it."
	var
		field_on = 0
		tmp/field_pulsing = 0

	New()
		..()
		spawn(1)
			if(!src) return
			if(isturf(loc) && !Grabbable) DeviceRegister()
			if(!dev_live) FieldRelease()

	Del()
		FieldRelease()
		..()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return DevicePlaced() && field_on

	DevicePowerChanged(on)
		FieldSync()

	proc/FieldUp()
		return dev_live && field_on

	proc/FieldSync()
		if(!FieldUp())
			FieldRelease()
			return
		if(!field_pulsing)
			field_pulsing = 1
			spawn() FieldLoop()

	proc/FieldLoop()
		set waitfor = 0
		while(src && FieldUp())
			FieldPulse()
			sleep(DEV_EMITTER_PULSE)
		if(src)
			field_pulsing = 0
			FieldRelease()

	proc/FieldPulse()
		for(var/obj/Items/O in range(DEV_CLOAK_FIELD_RADIUS, src))
			if(O == src || !isturf(O.loc) || O.CreatorKey != CreatorKey) continue
			if(!O.cloak_field_hidden || O.invisibility < DEV_CLOAK_FIELD_INVIS) CloakObjHide(O)

	proc/FieldRelease()
		if(!isturf(loc)) return
		for(var/obj/Items/O in range(DEV_CLOAK_FIELD_RADIUS + 1, src))
			if(O.cloak_field_hidden && O.CreatorKey == CreatorKey) CloakObjShow(O)

	DeviceActions(mob/M)
		. = ..()
		if(DeviceIsOwner(M) && !Grabbable) . += field_on ? "Drop the field" : "Raise the field"

	DeviceAct(mob/M, act)
		if(act == "Raise the field" || act == "Drop the field")
			if(!DeviceIsOwner(M)) return
			field_on = !field_on
			M << (field_on ? "You raise the cloaking field." : "You drop the cloaking field.")
			FieldSync()
			return
		..()

	DeviceStatus(mob/M)
		. = ..()
		. += "The field is [FieldUp() ? "up" : "down"]."
