/obj/Effects/Senbonzakura_Petal
	icon = 'Icons/Effects/byakuyashikai.dmi'
	density = 0
	layer = EFFECTS_LAYER
	Lifetime = -1
	var/tmp/mob/owner
	var/tmp/list/already_hit
	var/wpx = 0
	var/wpy = 0
	var/inactive = FALSE

	New()
		already_hit = list()
		..()

client
	var/senbonzakura_dragging = FALSE
	var/petal_target_wx = 0
	var/petal_target_wy = 0

	MouseDown(atom/object, turf/location, control, params)
		var/plist = params2list(params)
		if(plist["right"] == "1" && mob && mob.ShinigamiRelease == "Senbonzakura" && (mob.InShikai() || mob.InBankai()))
			senbonzakura_dragging = TRUE
			if(location)
				var/TSIZE = world.icon_size
				petal_target_wx = location.x + (text2num(plist["icon-x"]) - TSIZE/2) / TSIZE
				petal_target_wy = location.y + (text2num(plist["icon-y"]) - TSIZE/2) / TSIZE
			return
		..()

	MouseMove(atom/object, turf/location, control, params)
		if(senbonzakura_dragging && mob && mob.ShinigamiRelease == "Senbonzakura" && (mob.InShikai() || mob.InBankai()) && location)
			var/plist = params2list(params)
			var/TSIZE = world.icon_size
			petal_target_wx = location.x + (text2num(plist["icon-x"]) - TSIZE/2) / TSIZE
			petal_target_wy = location.y + (text2num(plist["icon-y"]) - TSIZE/2) / TSIZE
		..()

	MouseDrag(atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
		if(senbonzakura_dragging && mob && mob.ShinigamiRelease == "Senbonzakura" && (mob.InShikai() || mob.InBankai()) && over_location)
			var/plist = params2list(params)
			var/TSIZE = world.icon_size
			petal_target_wx = over_location.x + (text2num(plist["icon-x"]) - TSIZE/2) / TSIZE
			petal_target_wy = over_location.y + (text2num(plist["icon-y"]) - TSIZE/2) / TSIZE
		..()

	MouseUp(atom/object, turf/location, control, params)
		var/plist = params2list(params)
		if(plist["right"] == "1" && senbonzakura_dragging)
			senbonzakura_dragging = FALSE
		..()

/obj/Effects/PetalWall
	icon = 'Icons/Effects/Byakuya - Petals - Shield.dmi'
	icon_state = "1"
	density = 1
	layer = EFFECTS_LAYER + 1
	Lifetime = -1
	pixel_x = -64
	pixel_y = -64
	var/tmp/mob/owner

	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/proj = Obstacle
			proj.endLife()

/obj/Effects/BankaiSword
	icon = 'Icons/Effects/BigSword.dmi'
	density = 0
	layer = EFFECTS_LAYER + 1
	Lifetime = -1
	alpha = 0
