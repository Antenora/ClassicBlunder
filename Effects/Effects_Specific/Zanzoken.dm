


mob
	var
		ActiveZanzo=0//Is the user using Zanzoken?
		AfterImageStrike=0
		Dodging=0
	Move()//May need to be edited, etc to fit into your Move() proc if you're calling one

		if(ActiveZanzo)
			var/Original_Direction=src.dir
			var/turf/zanzo_from=get_turf(src)
			//Zanzoken flick() ?
			if(ActiveZanzo==3)//Safety net, so only one afterimage is produced since the step() proc below calls Move()
				AfterImage(usr)
			if(ActiveZanzo==6)
				AfterImage(usr)
				ActiveZanzo=3.1
			if(ActiveZanzo==4)
				VanishImage(usr)
				ActiveZanzo=3.9
			..() //Usual Move() procedure goes through
			var/zss = step_size
			step_size = 32
			while(ActiveZanzo>0)
				ActiveZanzo=round(ActiveZanzo)
				ActiveZanzo--
				step(src,src.dir)
			step_size = zss
			src.dir=Original_Direction//Player retains direction after using Zanzo [Blast Kiting?]
			ZanzoBlink(src, zanzo_from, 1)

		else
			..()
//		if(usr.Shadow)
//			Shadow_Chase(usr)//Makes the Shadow follow

proc
	VanishImage(mob/m, var/forceloc=0)
		var/obj/Vanish/I = new
		I.appearance_flags=32
		if(m.VanishPersonal)
			I.icon=m.VanishPersonal
			I.lifetime=m.VanishDuration
		else
			I.icon='Dodge.dmi'
		I.icon_state=""
		I.transform=m.transform
		if(!forceloc)
			I.loc=m.loc
			if(PmActive())//mid-tile caster: ghost rides the sprite's true position, not the tile origin
				I.step_x=m.step_x
				I.step_y=m.step_y
		else
			I.loc=forceloc
		I.dir=m.dir
		I.name=m.name
		I.Owner=m

	AfterImage(mob/m, var/forceloc=0)
		var/obj/Afterimage/I = new
		if(!m) return
		I.appearance = m.appearance
		I.dir = m.dir
		if(!forceloc)
			I.loc=m.loc
			if(PmActive())//mid-tile caster: ghost rides the sprite's true position, not the tile origin
				I.step_x=m.step_x
				I.step_y=m.step_y
		else
			I.loc=forceloc
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16
		return I
	AfterImageA(mob/m, var/forceloc=0)
		var/obj/AfterimageA/I = new
		if(!m) return
		I.appearance = m.appearance
		I.dir = m.dir
		if(!forceloc)
			I.loc=m.loc
			if(PmActive())//mid-tile caster: ghost rides the sprite's true position, not the tile origin
				I.step_x=m.step_x
				I.step_y=m.step_y
		else
			I.loc=forceloc
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16
	AfterImagePrediction(mob/m,var/X,var/Y, var/forceloc=0)
		var/obj/AfterimageP/I = new
		if(!m) return
		I.appearance = m.appearance
		I.dir = m.dir
		I.alpha=200
		if(!forceloc)
			I.loc=m.loc
			if(PmActive())//mid-tile caster: ghost rides the sprite's true position, not the tile origin
				I.step_x=m.step_x
				I.step_y=m.step_y
		else
			I.loc=forceloc
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16
	AfterImageGhost(mob/m, var/forceloc=0)
		var/obj/AfterimageG/I = new
		if(!m) return
		I.appearance = m.appearance
		I.dir = m.dir
		if(!forceloc)
			I.loc=m.loc
			if(PmActive())//mid-tile caster: ghost rides the sprite's true position, not the tile origin
				I.step_x=m.step_x
				I.step_y=m.step_y
		else
			I.loc=forceloc
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16

	TrailImage(atom/location, icon, state, offset_x, offset_y, dir)
		var/obj/DashImage/I = new
		I.appearance_flags=32
		I.icon=icon
		I.icon_state=state
		I.alpha=135
		var/turf/t =location
		t.vis_contents += I
		I.dir=dir
		I.pixel_x=offset_x
		I.pixel_y=offset_y


	coolerFlashImage(mob/m, amt)
		var/baseAmount = amt
		for(var/x in 1 to baseAmount)
			var/obj/coolImage/I = new
			I.appearance_flags=32
			I.icon=m.icon
			I.alpha=135
			I.overlays=m.overlays
			I.icon_state=m.icon_state
			I.color=m.color
			I.transform=m.transform

			var/turf/t = m.loc
			t.vis_contents += I

			I.dir=m.dir
			switch(I.dir)
				if(NORTH)
					I.pixel_x=m.pixel_x + (rand(-8,8))
					I.pixel_y=m.pixel_y - (x * 16)
				if(NORTHWEST)
					I.pixel_x= m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y - (x * 16)
				if(NORTHEAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y - (x * 16)
				if(SOUTH)
					I.pixel_x=m.pixel_x + (rand(-8,8))
					I.pixel_y=m.pixel_y + (x * 16)
				if(EAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y + (rand(-8,8))
				if(SOUTHEAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y + (x * 16)
				if(SOUTHWEST)
					I.pixel_x=m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y + (x * 16)
				if(WEST)
					I.pixel_x=m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y + (rand(-8,8))
			if(PmActive())//vis-child of the turf: fold the sprite's mid-tile offset into pixel coords
				I.pixel_x+=m.step_x
				I.pixel_y+=m.step_y
			I.pixel_z=m.pixel_z
			I.name=m.name
			I.Owner=m
			if(prob(25))
				I.color=rgb(14, 229, 237)
			else if(prob(25))
				I.color=rgb(5, 183, 121)
			else
				I.color=rgb(30, 18, 167)

	rainbowFlashImage(mob/m, amt)
		var/baseAmount = amt
		for(var/x in 1 to baseAmount)
			var/obj/coolImage/I = new
			I.appearance_flags=32
			I.icon=m.icon
			I.alpha=230
			I.overlays=m.overlays
			I.icon_state=m.icon_state
			I.color=m.color
			I.transform=m.transform

			var/turf/t = m.loc
			t.vis_contents += I

			I.dir=m.dir
			switch(I.dir)
				if(NORTH)
					I.pixel_x=m.pixel_x + (rand(-8,8))
					I.pixel_y=m.pixel_y - (x * 16)
				if(NORTHWEST)
					I.pixel_x= m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y - (x * 16)
				if(NORTHEAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y - (x * 16)
				if(SOUTH)
					I.pixel_x=m.pixel_x + (rand(-8,8))
					I.pixel_y=m.pixel_y + (x * 16)
				if(EAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y + (rand(-8,8))
				if(SOUTHEAST)
					I.pixel_x=m.pixel_x - (x * 16)
					I.pixel_y=m.pixel_y + (x * 16)
				if(SOUTHWEST)
					I.pixel_x=m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y + (x * 16)
				if(WEST)
					I.pixel_x=m.pixel_x + (x * 16)
					I.pixel_y=m.pixel_y + (rand(-8,8))
			if(PmActive())//vis-child of the turf: fold the sprite's mid-tile offset into pixel coords
				I.pixel_x+=m.step_x
				I.pixel_y+=m.step_y
			I.pixel_z=m.pixel_z
			I.name=m.name
			I.Owner=m
			var/r=1
			var/g=0.20
			var/b=0.25
			var/prismaticColor

			if(m.passive_handler.Get("Prismatic"))
				prismaticColor=m.CurrentPrismaticGlowColor()

			if(prismaticColor)
				var/list/currentColor=rgb2num(prismaticColor)
				if(currentColor && currentColor.len>=3)
					r=currentColor[1]/255
					g=currentColor[2]/255
					b=currentColor[3]/255
			else
				m.rainbow_afterimage_index++
				if(m.rainbow_afterimage_index>8)
					m.rainbow_afterimage_index=1

				switch(m.rainbow_afterimage_index)
					if(1)
						r=1
						g=0.20
						b=0.25
					if(2)
						r=1
						g=0.50
						b=0.15
					if(3)
						r=1
						g=0.95
						b=0.15
					if(4)
						r=0.55
						g=0.90
						b=0.20
					if(5)
						r=0.10
						g=0.85
						b=0.65
					if(6)
						r=0.10
						g=0.60
						b=1
					if(7)
						r=0.20
						g=0.25
						b=1
					if(8)
						r=0.65
						g=0.15
						b=0.85

			var/list/rainbowColor = list(
				0, 0, 0, 0,
				0, 0, 0, 0,
				0, 0, 0, 0,
				0, 0, 0, 1,
				r, g, b, 0
			)

			I.color=null
			I.filters += filter(
				type = "color",
				color = rainbowColor
			)

	blueFlashImage(mob/m, amt)
		var/baseAmount = amt
		for(var/x in 1 to baseAmount)
			var/obj/coolImage/I = new
			I.appearance_flags = 32
			I.icon = m.icon
			I.alpha = 135
			I.overlays = m.overlays
			I.icon_state = m.icon_state
			I.transform = m.transform

			var/turf/t = m.loc
			t.vis_contents += I

			I.dir = m.dir
			switch(I.dir)
				if(NORTH)
					I.pixel_x = m.pixel_x + rand(-8, 8)
					I.pixel_y = m.pixel_y - (x * 16)
				if(NORTHWEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y - (x * 16)
				if(NORTHEAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y - (x * 16)
				if(SOUTH)
					I.pixel_x = m.pixel_x + rand(-8, 8)
					I.pixel_y = m.pixel_y + (x * 16)
				if(EAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y + rand(-8, 8)
				if(SOUTHEAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y + (x * 16)
				if(SOUTHWEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y + (x * 16)
				if(WEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y + rand(-8, 8)

			if(PmActive())
				I.pixel_x += m.step_x
				I.pixel_y += m.step_y

			I.pixel_z = m.pixel_z
			I.name = m.name
			I.Owner = m
			I.color = "#0000FF"


	orangeFlashImage(mob/m, amt)
		var/baseAmount = amt
		for(var/x in 1 to baseAmount)
			var/obj/coolImage/I = new
			I.appearance_flags = 32
			I.icon = m.icon
			I.alpha = 135
			I.overlays = m.overlays
			I.icon_state = m.icon_state
			I.transform = m.transform

			var/turf/t = m.loc
			t.vis_contents += I

			I.dir = m.dir
			switch(I.dir)
				if(NORTH)
					I.pixel_x = m.pixel_x + rand(-8, 8)
					I.pixel_y = m.pixel_y - (x * 16)
				if(NORTHWEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y - (x * 16)
				if(NORTHEAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y - (x * 16)
				if(SOUTH)
					I.pixel_x = m.pixel_x + rand(-8, 8)
					I.pixel_y = m.pixel_y + (x * 16)
				if(EAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y + rand(-8, 8)
				if(SOUTHEAST)
					I.pixel_x = m.pixel_x - (x * 16)
					I.pixel_y = m.pixel_y + (x * 16)
				if(SOUTHWEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y + (x * 16)
				if(WEST)
					I.pixel_x = m.pixel_x + (x * 16)
					I.pixel_y = m.pixel_y + rand(-8, 8)

			if(PmActive())
				I.pixel_x += m.step_x
				I.pixel_y += m.step_y

			I.pixel_z = m.pixel_z
			I.name = m.name
			I.Owner = m
			I.color = "#FF8000"


	FlashImage(mob/m)
		var/AMT=1
		while(AMT)
			AMT--
			var/obj/DashImage/I = new
			I.appearance_flags=32
			I.icon=m.icon
			I.alpha=135
			I.overlays=m.overlays
			I.icon_state=m.icon_state
			I.color=m.color
			I.transform=m.transform

			var/turf/t = m.loc
			t.vis_contents += I

			I.dir=m.dir
			I.pixel_x=m.pixel_x
			I.pixel_y=m.pixel_y
			if(PmActive())//vis-child of the turf: fold the sprite's mid-tile offset into pixel coords
				I.pixel_x+=m.step_x
				I.pixel_y+=m.step_y
			I.pixel_z=m.pixel_z
			I.name=m.name
			I.Owner=m
			if(m.CheckSpecial("Time Alter"))
				I.appearance_flags+=16
			else if(m.CheckSlotless("Chain Quasar"))
				I.color=list(0,0,1,0,0,1,0,0,1,0,0,0)
	RecoverImage(mob/m)
		var/obj/RecoveryImage/I = new
		I.appearance_flags=32
		I.icon=m.icon
		I.icon_state=m.icon_state
		I.alpha=135
		I.overlays=m.overlays
		I.color=m.color
		I.transform=m.transform
		I.loc=m.loc
		if(PmActive())//recovery burst tracks a mid-tile sprite
			I.step_x=m.step_x
			I.step_y=m.step_y
		I.dir=m.dir
		I.layer=EFFECTS_LAYER
		I.pixel_x=m.pixel_x
		I.pixel_y=m.pixel_y
		I.pixel_z=m.pixel_z
		I.name=m.name
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16

obj/Vanish
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	density=0
	var/lifetime=3
	New()
		spawn()
			animate(src,alpha=0,time=lifetime)
			spawn(lifetime)
				Owner = null
				src.loc = null
obj/Afterimage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		animate(src,alpha=195,time=4)
		spawn(4)
			animate(src,alpha=0,time=16)
			spawn(16)
				animate(src)
				Owner = null
				loc = null
obj/AfterimageA
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		animate(src,alpha=195,time=4)
		spawn(4)
			animate(src,alpha=0, icon_state="Attack", time=16)
			spawn(16)
				animate(src)
				Owner = null
				loc = null
obj/AfterimageP
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		spawn()
			animate(src,alpha=0,time=5)
			spawn(5)
				animate(src)
				Owner = null
				loc = null
obj/AfterimageG
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		spawn(20)
			animate(src,alpha=0,time=10)
			spawn(10)
				animate(src)
				Owner = null
				loc = null
obj/RecoveryImage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		animate(src,alpha=0,transform=matrix()*3,time=8)
		spawn(8)
			animate(src)
			loc = null
obj/DashImage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		spawn(2)
			animate(src,pixel_x=rand(-8,8),pixel_y=rand(-8,8))
			animate(src,alpha=0,time=8)
			spawn(8)
				for(var/turf/a in vis_locs)
					a.vis_contents -= src
				for(var/atom/movable/a in vis_locs)
					a.vis_contents -= src
				if(Owner)
					Owner.vis_contents -= src
				loc = null

obj/ProjectileAfterimage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	density=0
	mouse_opacity=0
	var/FadeDelay=1
	var/FadeDuration=8
	proc/BeginFade()
		set waitfor=0
		sleep(max(FadeDelay, 0))
		if(!src || !src.loc)
			return
		animate(src, alpha=0, time=max(FadeDuration, 1))
		sleep(max(FadeDuration, 1))
		if(src)
			src.loc=null


obj/coolImage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New()
		spawn(2)
			animate(src,alpha=0,time=8)
			spawn(8)
				for(var/turf/a in vis_locs)
					a.vis_contents -= src
				for(var/atom/movable/a in vis_locs)
					a.vis_contents -= src
				if(Owner)
					Owner.vis_contents -= src
				loc = null


obj/TrailImage
	Grabbable=0
	Destructable=0
	Savable=0
	gfx_transient_visual=1
	New(turf/new_loc, new_icon, new_state, duration=10, alpha=255, rand_x=8, rand_y=8)
		src.alpha=0
		src.icon = new_icon
		src.icon_state = new_state
		new_loc.vis_contents += src
		animate(src,pixel_x=rand(-rand_x,rand_x),pixel_y=rand(-rand_x,rand_y))
		animate(src,alpha=0,time=duration)
		spawn(duration)
			new_loc.vis_contents-=src
			loc = null

mob/Player
	Afterimage
		Health=100000
		density=1
		Grabbable=1

		New()
			spawn(2)
				density=0
				animate(src,alpha=0,time=8)
				spawn(8)
					del src
		Del()
			for(var/mob/m in players)
				if(m.Target==src)
					//m<<"Your target has been swapped from [src]([src.type]) to [Owner]([Owner.type])"
					m.SetTarget(Owner)
			..()

proc
	AfterImageStrike(mob/A,mob/Target,var/Striking=1)
		set waitfor=0
		if(!A || !Target)
			return
		if(!A.Dodging&&!Target.Dodging)
			A.SuppressPowerGlow = 1
			Target.SuppressPowerGlow = 1
			A.Dodging=1
			Target.Dodging=1
			var/StartA=A.loc
			var/StartT=Target.loc
			var/clash
			//both windows live = the cinematic. stack check stays for forced clashes (finisher-vs-finisher)
			clash = Target.aisArmed() || Target.AfterImageStrike > 0
			if(Target.aisArmed()) Target.aisConsume()
			if(clash)
				if(Target.client)
					if(istype(Target, /mob/Players))
						var/mob/Players/PT = Target
						PT.move_disabled = TRUE
					if(istype(A, /mob/Players))
						var/mob/Players/PA = A
						PA.move_disabled = TRUE
				A.dir = get_dir(A, Target) || A.dir
				Target.dir = get_dir(Target, A) || Target.dir
				animate(A,alpha=0,time=2, flags=ANIMATION_END_NOW )
				animate(Target,alpha=0,time=2, flags=ANIMATION_END_NOW )
				sleep(1)
//				VanishImage(A)
//				VanishImage(Target)
				VanishImage(A)
				VanishImage(Target)
				sleep(1)
				var/turf/SA = istype(StartA, /turf) ? StartA : get_step(A, 0)
				var/turf/ST = istype(StartT, /turf) ? StartT : get_step(Target, 0)
				if(A && Target && SA && ST && SA.z == ST.z)
					var/cmx = round((SA.x + ST.x) / 2)
					var/cmy = round((SA.y + ST.y) / 2)
					var/cdx = SA.x < ST.x ? 1 : (SA.x > ST.x ? -1 : 0)
					var/cdy = SA.y < ST.y ? 1 : (SA.y > ST.y ? -1 : 0)
					if(!cdx && !cdy)
						cdx = 1
					var/list/half = list(2, 1, 0)
					var/list/beat = list(4, 3, 2)
					for(var/i = 1, i <= 3, i++)
						if(!A || !Target)
							break
						var/h = half[i]
						var/jx = -cdy * pick(-1, 0, 1)
						var/jy = cdx * pick(-1, 0, 1)
						var/turf/PGA = locate(cmx - cdx * h + jx, cmy - cdy * h + jy, SA.z)
						var/turf/PGT = locate(cmx + cdx * h + jx, cmy + cdy * h + jy, SA.z)
						if(PGA) AfterImageA(A, PGA)
						if(PGT) AfterImageA(Target, PGT)
						KenShockwave(A, icon='KenShockwave.dmi', Size = 0.35 + 0.28 * i, PixelX = (cmx + jx - SA.x) * 32, PixelY = (cmy + jy - SA.y) * 32, Blend = 2, Time = 4)
						sleep(beat[i])
					if(A && Target)
						var/turf/MT = locate(cmx, cmy, SA.z)
						if(MT)
							FxHeavyImpact(MT, priority = 1)
						KenShockwave(A, Size = 1.2, PixelX = (cmx - SA.x) * 32, PixelY = (cmy - SA.y) * 32, Time = 5)
						HitStop(A, Target, 14)
						sleep(2)
				if(Target && Target.AfterImageStrike)
					Target.AfterImageStrike--
				if(Target && istype(Target, /mob/Players))
					var/mob/Players/PT = Target
					PT.move_disabled = FALSE
				if(A && istype(A, /mob/Players))
					var/mob/Players/PA = A
					PA.move_disabled = FALSE
				if(A)
					A.loc = StartA
					animate(A, alpha = 255, time = 3)
					A.SuppressPowerGlow = 0
				if(Target)
					Target.loc = StartT
					animate(Target, alpha = 255, time = 3)
					Target.SuppressPowerGlow = 0
				if(A && Target)
					A.dir = get_dir(A, Target) || A.dir
					Target.dir = get_dir(Target, A) || Target.dir
			else
				var/obj/Afterimage/hold_ghost = AfterImage(A)
				if(hold_ghost)
					animate(hold_ghost, alpha = 220, time = 3)
					animate(alpha = 0, time = 6)
				A.Comboz(Target, landDir = A.heldDir())	//held key picks the landing side
				A.dir=get_dir(A,Target)
				if(Striking)
					A.NextAttack=0
					A.Melee1(1, 5, SureKB=1)
					if(A && Target)
						FlashCounterMoment(A, Target)
				if(A)
					A.alpha = 255
					A.AfterImageStrike = 0
					A.ais_window_until = 0
			if(A)
				A.Dodging=0
			if(Target)
				Target.Dodging=0

	WildSense(mob/A,mob/Target,var/Striking=1)
		A.Comboz(Target)
		A.dir=get_dir(A,Target)
		if(Striking)
			A.NextAttack=0
			A.Melee1(1, 5, SureKB=15)

	Dodge(mob/A)
		var/changeX=pick(-8,-4,4,8)
		var/changeY=pick(-8,-4,4,8)
		if(!A.Dodging)
			A.Dodging=1
			if(glob.FLASH_MOVE)
				spawn() AfterImage(A)
				Footfall(A)
			if(A.filters["trail"]) //the motion_blur AppearanceOn puts on every mob - by name, not "whatever's last"
				animate(A.filters["trail"], x=changeX/4, y=changeY/4, time=2, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			animate(A,pixel_x=changeX, pixel_y=changeY, time=2, flags=ANIMATION_RELATIVE)
			sleep(2)
			animate(A,pixel_x=-changeX, pixel_y=-changeY, time=1, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			if(A.filters["trail"])
				animate(A.filters["trail"], x=0, y=0, time=1)
			A.Dodging=0
	Prediction(mob/A)
		var/changeX=pick(-16,-8,8,16)
		var/changeY=pick(-16,-8,8,16)
		if(!A.Dodging)
			A.Dodging=1
			spawn()
				AfterImagePrediction(A)
			animate(A,pixel_x=changeX, pixel_y=changeY, time=3, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			sleep(3)
			animate(A,pixel_x=-changeX, pixel_y=-changeY, time=2, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			A.Dodging=0
	UltraPrediction2(mob/A,mob/Target)
		var/changeX=pick(-16,-8,8,16)
		var/changeY=pick(-16,-8,8,16)
		if(!A.Dodging)
			A.Dodging=1
			spawn()
				AfterImagePrediction(A,changeX/8,changeY/8)
				sleep(1)
				AfterImagePrediction(A,changeX/4,changeY/4)
				sleep(2)
				AfterImagePrediction(A,changeX/2,changeY/2)
			sleep(2)
			animate(A,pixel_x=changeX, pixel_y=changeY, time=0, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			animate(A,pixel_x=-changeX, pixel_y=-changeY, time=3, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			sleep(3)
			A.dir=get_dir(A,Target)
			A.Melee1(1, 5, accmulti=1.15)
			A.Dodging=0
