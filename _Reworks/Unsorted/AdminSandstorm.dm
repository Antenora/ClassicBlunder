var/datum/sandstorm_controller/admin_sandstorm_active = null

/particles/sandstorm_dots
	icon = 'sandstorm.dmi'
	width = 1400
	height = 1000
	count = 4200
	spawning = 60
	lifespan = 70
	fade = 3
	grow = 0.015
	scale = generator("num", 1.0, 2.2)
	gravity = list(-0.6, 0)
	position = generator("box", list(-500, -380, 0), list(500, 380, 0))
	spin = 0
	color = "#5a2808"

// Screen tint overlay
/obj/screen/sandstorm_tint
	screen_loc = "CENTER"
	layer = 19
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	alpha = 90

	New()
		..()
		var/icon/I = new('sandstorm.dmi')
		I.DrawBox("#c49848", 1, 1, 32, 32)
		icon = I
		var/matrix/M = matrix()
		M.Scale(42, 32)
		transform = M

// Screen emitter for the sweeping dots
/obj/screen/sandstorm_dots_emitter
	screen_loc = "CENTER"
	layer = 20
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE

/datum/sandstorm_controller
	var/zone_z
	var/list/screen_objs = list()

	New(turf/T)
		..()
		zone_z = T.z
		for(var/mob/M in players)
			if(M.client && M.z == zone_z)
				AddToClient(M.client)

	proc/AddToClient(client/C)
		var/obj/screen/sandstorm_tint/tint = new()
		var/obj/screen/sandstorm_dots_emitter/dots = new()
		dots.particles = new/particles/sandstorm_dots
		C.screen += tint
		C.screen += dots
		screen_objs += tint
		screen_objs += dots

	proc/Dismiss()
		if(admin_sandstorm_active == src)
			admin_sandstorm_active = null
		for(var/obj/screen/S in screen_objs)
			if(istype(S, /obj/screen/sandstorm_dots_emitter))
				var/obj/screen/sandstorm_dots_emitter/D = S
				D.particles = null
			for(var/client/C)
				C.screen -= S
			del S
		screen_objs.Cut()

/mob/Admin2/verb/Summon_Sandstorm()
	set category = "Admin"
	set name = "Summon Sandstorm"

	if(admin_sandstorm_active)
		admin_sandstorm_active.Dismiss()
		src << "The sandstorm dies down and the air clears."
		Log("Admin", "[ExtractInfo(src)] ended the admin sandstorm.")
		return

	var/turf/T = get_turf(src)
	if(!T)
		src << "You need a valid turf."
		return

	admin_sandstorm_active = new /datum/sandstorm_controller(T)
	src << "A heavy sandstorm rolls in, stinging the air with grit and dust."
	Log("Admin", "[ExtractInfo(src)] summoned the admin sandstorm at [T.x],[T.y],[T.z].")
