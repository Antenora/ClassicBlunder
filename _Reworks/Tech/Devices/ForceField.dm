#define DEV_FIELD_LENGTH 5
#define FIELD_SEG_HP 30
#define FIELD_PUNCH 1
#define FIELD_REGROW 200
#define FIELD_EMP_DOWN 300

/obj/Items/Tech/Force_Field_Emitter
	name = "Force Field Emitter"
	desc = "Bolt it down facing the way the field should run: it raises a barrier on the 5 tiles in front of it. Its owner and whitelisted keys walk and shoot through; everyone else is stopped. Shots and punches wear a section down, and a broken section comes back after 20 seconds while the emitter has power. It burns half a Power Pack a minute while the field is up."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "FFE"
	TechType = "Engineering"
	SubType = "Force Shielding"
	Pickable = 1
	Grabbable = 1
	Attackable = 0
	Destructable = 0
	UpdatesDescription = 1
	dev_hopper = 1
	dev_drain = DEV_PER_MINUTE(0.5)
	var/field_on = 0
	var/field_link
	var/tmp/list/field_segs
	var/tmp/field_down_until = 0

	New()
		..()
		spawn(0)
			if(src)
				if(isturf(loc) && !Grabbable) DeviceRegister()
				FieldSync()

	Del()
		FieldLower()
		..()

	proc/Update_Description()
		desc = "[DeviceDescText()]<br><br>Field: [FieldUp() ? "up" : (field_on ? "switched on, waiting for power" : "switched off")]."

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return DevicePlaced() && field_on

	DevicePowerChanged(on)
		FieldSync()

	DevicePowerTick(minutes)
		..()
		FieldSync()

	DeviceEMP(strength)
		field_down_until = world.time + FIELD_EMP_DOWN * strength
		FieldLower()
		spawn(FIELD_EMP_DOWN * strength + 1)
			if(src) FieldSync()

	DeviceBoltToggle(mob/M)
		. = ..()
		if(. && !Grabbable && M) dir = FieldCardinal(M.dir)
		FieldSync()

	DeviceAcceptItem(mob/M, obj/Items/I)
		if(istype(I, /obj/Items/Tech/Force_Field_Remote))
			if(get_dist(M, src) > 1)
				M << "Get next to [src] first."
				return 1
			if(!DeviceIsOwner(M))
				M << "Only [src]'s owner can link a remote to it."
				return 1
			var/obj/Items/Tech/Force_Field_Remote/R = I
			if(!field_link) field_link = "[CreatorKey]-[num2text(world.realtime, 20)]-[rand(1000, 9999)]"
			R.remote_link = field_link
			M << "[R] is now linked to [src]."
			return 1
		return ..()

	DeviceActions(mob/M)
		. = ..()
		if(!isturf(loc)) return
		if(DeviceIsOwner(M)) . += (field_on ? "Switch field off" : "Switch field on")
		. += GuardActions(M)

	DeviceAct(mob/M, act)
		if(GuardAct(M, act)) return
		switch(act)
			if("Switch field on", "Switch field off")
				FieldToggle(M)
				return
		..()

	DeviceStatus(mob/M)
		. = ..()
		. += "Field: [FieldUp() ? "up" : (field_on ? "switched on, waiting for power" : "switched off")]."
		. += GuardStatus(M)

	proc/FieldCardinal(d)
		if(d == NORTH || d == SOUTH || d == EAST || d == WEST) return d
		if(d & EAST) return EAST
		if(d & WEST) return WEST
		return SOUTH

	proc/FieldUp()
		return length(field_segs) > 0

	proc/FieldShouldRaise()
		return field_on && DevicePlaced() && DevicePowered() && world.time >= field_down_until

	proc/FieldSync()
		if(FieldShouldRaise()) FieldRaise()
		else FieldLower()

	proc/FieldToggle(mob/M)
		if(!DeviceIsOwner(M)) return 0
		field_on = !field_on
		if(M) M << (field_on ? "You switch [src] on." : "You switch [src] off.")
		FieldSync()
		DevicePowerCheck()
		return 1

	proc/FieldRaise()
		if(FieldUp()) return
		if(!isturf(loc)) return
		var/d = FieldCardinal(dir)
		var/turf/t = loc
		field_segs = list()
		for(var/i = 1 to DEV_FIELD_LENGTH)
			t = get_step(t, d)
			if(!t || t.density) break
			var/obj/Traps/Force_Field/S = new(t, null)
			S.field_emitter = src
			field_segs += S
		if(!field_segs.len) field_segs = null
		else OrdAreaLine(src, "<font color='#8be9ff'>[src] hums and a force field shimmers into place.</font>")

	proc/FieldLower()
		if(!field_segs) return
		var/list/L = field_segs
		field_segs = null
		for(var/obj/Traps/Force_Field/S in L)
			S.field_emitter = null
			S.TrapGone()

	proc/FieldPasses(mob/M)
		if(!M) return 0
		if(GuardAllows(M)) return 1
		if(GuardOwnsEmplacement(M)) return 1
		return 0

/obj/Traps/Force_Field
	name = "Force Field"
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "ForceField"
	density = 1
	Attackable = 1
	Destructable = 0
	trap_box = 32
	var/tmp/obj/Items/Tech/Force_Field_Emitter/field_emitter
	var/tmp/seg_hp = FIELD_SEG_HP
	var/tmp/seg_down = 0
	var/tmp/seg_regrow_at = 0

	Cross(atom/movable/O)
		if(seg_down) return 1
		if(istype(O, /obj/Skills/Projectile/_Projectile)) return 1
		if(ismob(O) && field_emitter && field_emitter.FieldPasses(O)) return 1
		return ..()

	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/P = Obstacle
			if(seg_down || !field_emitter || P.Killed || P.Distance < 0) return
			if(P.Owner && field_emitter.FieldPasses(P.Owner)) return
			SegmentHit(max(0, P.DamageMult) * (P.Owner ? P.Owner.GunAMMult(src, P) : 1))
			P.ProjectileFinish()
			return
		..()

	StruckByMelee(mob/A, dmg)
		if(seg_down || !field_emitter || !A) return 0
		if(field_emitter.FieldPasses(A)) return 0
		SegmentHit(FIELD_PUNCH)
		return 1

	EMPHit(strength)
		if(strength <= 0 || !field_emitter) return 0
		return field_emitter.EMPHit(strength)

	proc/SegmentHit(dmg)
		if(seg_down || dmg <= 0) return
		seg_hp -= dmg
		if(seg_hp <= 0) SegmentDrop()

	proc/SegmentDrop()
		if(seg_down) return
		seg_down = 1
		density = 0
		invisibility = 101
		mouse_opacity = 0
		seg_regrow_at = world.time + FIELD_REGROW
		OrdAreaLine(src, "<font color='#8be9ff'>A section of the force field flickers out.</font>")
		spawn(FIELD_REGROW)
			if(src) SegmentRegrow()

	proc/SegmentRegrow()
		if(!seg_down || !loc || !field_emitter) return
		if(world.time < seg_regrow_at)
			spawn(seg_regrow_at - world.time)
				if(src) SegmentRegrow()
			return
		if(!field_emitter.FieldShouldRaise()) return
		seg_hp = FIELD_SEG_HP
		seg_down = 0
		density = 1
		invisibility = 0
		mouse_opacity = 1

/obj/Items/Tech/Force_Field_Remote
	name = "Force Field Remote"
	desc = "Switches a Force Field Emitter on or off from anywhere on the same map. Drag it onto your emitter to link it, then click it in your inventory."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "FFRemote"
	TechType = "Engineering"
	SubType = "Force Shielding"
	var/remote_link

	Click()
		if(loc != usr) return ..()
		RemoteToggle(usr)

	proc/RemoteToggle(mob/M)
		if(!M) return 0
		if(!remote_link)
			M << "[src] is not linked. Drag it onto your Force Field Emitter first."
			return 0
		var/obj/Items/Tech/Force_Field_Emitter/E
		for(var/obj/Items/Tech/Force_Field_Emitter/X in dev_registry)
			if(X.field_link == remote_link)
				E = X
				break
		if(!E || !isturf(E.loc))
			M << "[src] cannot find its emitter. It must be bolted down."
			return 0
		if(E.z != M.z)
			M << "[src] is out of range of [E]."
			return 0
		if(!E.DeviceIsOwner(M))
			M << "[E] does not answer to you."
			return 0
		return E.FieldToggle(M)
