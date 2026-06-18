client/proc/PlaySwoon()
	var/obj/ScreenFX/SWOON/fx = new

	screen += fx

	sleep(30)

	fx.icon_state = "2"
	sleep(4)
	fx.icon_state = "3"
	sleep(20)

	if(fx)
		screen -= fx
		del fx

obj/ScreenFX
	SWOON
		icon = 'SWOON.dmi'
		icon_state = "1"
		screen_loc = "CENTER-8,CENTER-8"
		mouse_opacity = 0
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE