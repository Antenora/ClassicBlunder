#define SWOON_ART 544

client/proc/PlaySwoon()
	set waitfor = 0
	var/obj/ScreenFX/SWOON/fx = new

	FitSwoon(fx)
	screen += fx

	sleep(30)

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
		plane = FLOAT_PLANE
		appearance_flags = PIXEL_SCALE