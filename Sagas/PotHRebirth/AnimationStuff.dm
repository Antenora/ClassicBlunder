#define SWOON_ART 544

client/proc/PlaySwoon()
	set waitfor = 0
	var/obj/ScreenFX/SWOON/fx = new

	SetupCutsceneDisplay()
	FitSwoon(fx)
	screen += fx

	sleep(30)
	EndCutsceneDisplay()
	FitSwoon(fx)
	fx.icon_state = "2"
	sleep(4)
	fx.icon_state = "3"
	sleep(20)
	if(fx)
		screen -= fx

client/proc/FitSwoon(obj/ScreenFX/SWOON/fx)
	if(!fx) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/vw = text2num(v[1]) * world.icon_size
	var/vh = text2num(v[2]) * world.icon_size
	if(!vw || !vh) return
	fx.screen_loc = "1:[round(vw / 2) - SWOON_ART / 2],1:[round(vh / 2) - SWOON_ART / 2]"
	var/k = max(vw, vh) / SWOON_ART
	fx.transform = k > 1 ? matrix().Scale(k) : matrix()

obj/ScreenFX
	SWOON
		icon = 'SWOON.dmi'
		icon_state = "1"
		screen_loc = "CENTER-8,CENTER-8"
		mouse_opacity = 0
		layer = FLOAT_LAYER
		plane = FX_RELAY_PLANE
		appearance_flags = PIXEL_SCALE


mob/Players
	var/tmp
		atom/anti_last_loc
		anti_last_x = 0
		anti_last_y = 0
		anti_last_z = 0
		anti_last_move = 0
		anti_next_idle = 0

	proc/AntiIdleTick()
		if(loc != anti_last_loc || step_x != anti_last_x || step_y != anti_last_y || pixel_z != anti_last_z)
			anti_last_move = world.time
		anti_last_loc = loc
		anti_last_x = step_x
		anti_last_y = step_y
		anti_last_z = pixel_z
		if(!client) return
		if(world.time < anti_last_move + 4 || world.time < anti_next_idle) return
		if(passive_handler.Get("AfterImageSkin") != "Anti") return
		if(passive_handler.Get("AfterImages") <= 0) return
		anti_next_idle = world.time + 4
		AntiAfterImage(src, 1, TRUE)