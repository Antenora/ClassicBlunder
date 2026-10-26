/mob/var/tmp/gun_aim_angle = 0
/mob/var/tmp/gun_aim_at = 0
/mob/var/tmp/gun_aim_set = 0

mob/proc/GunSetAimAngle(ang)
	while(ang < 0)
		ang += 360
	while(ang >= 360)
		ang -= 360
	gun_aim_angle = ang
	gun_aim_at = world.time
	gun_aim_set = 1

mob/proc/GunClearAim()
	gun_aim_angle = 0
	gun_aim_at = 0
	gun_aim_set = 0

mob/proc/GunAimAngleNow()
	if(gun_aim_set)
		return gun_aim_angle
	return GunDirAngle(dir)

mob/proc/GunAimAtWorld(wx, wy)
	var/dx = wx - (1 + (x - 1) * 32 + step_x + 16)
	var/dy = wy - (1 + (y - 1) * 32 + step_y + 16)
	if(!dx && !dy)
		return 0
	GunSetAimAngle(arctan(dx, dy))
	return 1

/proc/GunAimClickPoint(atom/object, atom/location, params)
	if(ismob(object))
		var/mob/t = object
		return list(1 + (t.x - 1) * 32 + t.step_x + 16, 1 + (t.y - 1) * 32 + t.step_y + 16)
	var/turf/T = location
	if(!istype(T))
		return null
	var/list/p = params2list(params)
	var/ix = text2num(p["icon-x"])
	var/iy = text2num(p["icon-y"])
	if(isnull(ix))
		ix = 16
	if(isnull(iy))
		iy = 16
	return list((T.x - 1) * 32 + ix, (T.y - 1) * 32 + iy)

/proc/GunAimIntercept(mob/m, atom/object, atom/location, params)
	if(!m || !m.client)
		return 0
	if(!isturf(location))
		return 0
	if(!isturf(object) && !ismob(object))
		return 0
	if(m.KO || m.Observing)
		return 0
	if(!m.EquippedGun())
		return 0
	if(m.Target && istype(m.Target, /obj/Others/Build))
		return 0
	var/list/p = params2list(params)
	if(p["right"] || p["middle"])
		return 0
	if(p["button"] && p["button"] != "left")
		return 0
	if(p["ctrl"] || p["alt"] || p["shift"])
		return 0
	return 1

mob/proc/GunAimAtClick(atom/object, atom/location, params)
	var/list/w = GunAimClickPoint(object, location, params)
	if(w)
		GunAimAtWorld(w[1], w[2])
	else
		GunSetAimAngle(GunDirAngle(dir))

mob/proc/GunFaceShot(ang)
	var/want = GunAngleDir(ang)
	if(want && dir != want && Move_Requirements())
		dir = want

mob/proc/GunFaceAim()
	GunFaceShot(GunAimAngleNow())

mob/proc/GunClickFire(atom/object, atom/location, params)
	GunAimAtClick(object, location, params)
	GunFaceAim()
	Melee1()

/mob/var/tmp/gun_hold = 0
/mob/var/tmp/gun_hold_loop = 0

mob/proc/GunHoldStop()
	gun_hold = 0

mob/proc/GunHoldStart()
	gun_hold = 1
	if(gun_hold_loop)
		return
	GunAutoFire()

mob/proc/GunAutoFire()
	set waitfor = 0
	gun_hold_loop = 1
	while(gun_hold && client)
		sleep(world.tick_lag)
		if(KO || Observing || Reloading)
			break
		var/obj/Items/Gun/G = EquippedGun()
		if(!G || G.GunClass != GUN_CLASS_AUTOMATIC || G.Loaded <= 0)
			break
		if((G.energy_gun || G.mech_only) && Overheated())
			continue
		if(NextAttack > world.time)
			continue
		Melee1()
	gun_hold_loop = 0

client/Click(atom/object, atom/location, control, params)
	if(GunAimIntercept(mob, object, location, params))
		DismissPopupsOutside(object)
		mob.GunClickFire(object, location, params)
		return
	return ..()

client/DblClick(atom/object, atom/location, control, params)
	if(GunAimIntercept(mob, object, location, params))
		object.Click(location, control, params)
		return
	return ..()

mob/proc/GunChargeStart(atom/object, atom/location, params)
	return 0

mob/proc/GunChargeRelease(atom/object, atom/location, params)
	return 0

client/MouseDown(atom/object, atom/location, control, params)
	if(GunAimIntercept(mob, object, location, params))
		mob.GunAimAtClick(object, location, params)
		if(!mob.GunChargeStart(object, location, params))
			mob.GunHoldStart()
	return ..()

client/MouseDrag(atom/src_object, atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
	if(mob && mob.gun_hold && isturf(over_location) && (isturf(over_object) || ismob(over_object)))
		mob.GunAimAtClick(over_object, over_location, params)
	return ..()

client/MouseUp(atom/object, atom/location, control, params)
	if(mob)
		mob.GunHoldStop()
		mob.GunChargeRelease(object, location, params)
	return ..()

client/MouseMove(atom/object, atom/location, control, params)
	var/mob/m = mob
	if(m && m.equippedGun && m.gun_aim_at != world.time && !m.KO && !m.Observing && isturf(location) && (isturf(object) || ismob(object)))
		if(m.EquippedGun())
			m.GunAimAtClick(object, location, params)
	return ..()
