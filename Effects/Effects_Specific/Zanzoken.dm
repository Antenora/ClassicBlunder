mob
	var
		ActiveZanzo=0//Is the user using Zanzoken?
		AfterImageStrike=0
		Dodging=0
	Move()//May need to be edited, etc to fit into your Move() proc if you're calling one

		if(ActiveZanzo)
			var/Original_Direction=src.dir
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
			while(ActiveZanzo>0)
				ActiveZanzo=round(ActiveZanzo)
				ActiveZanzo--
				step(src,src.dir)
			src.dir=Original_Direction//Player retains direction after using Zanzo [Blast Kiting?]

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
		else
			I.loc=forceloc
		I.Owner=m
		if(m.CheckSpecial("Time Alter"))
			I.appearance_flags+=16
	AfterImageA(mob/m, var/forceloc=0)
		var/obj/AfterimageA/I = new
		if(!m) return
		I.appearance = m.appearance
		I.dir = m.dir
		if(!forceloc)
			I.loc=m.loc
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
			I.pixel_z=m.pixel_z
			I.name=m.name
			I.Owner=m
			if(prob(25))
				I.color=rgb(14, 229, 237)
			else if(prob(25))
				I.color=rgb(5, 183, 121)
			else
				I.color=rgb(30, 18, 167)

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
	New()
		animate(src,alpha=0,transform=matrix()*3,time=8)
		spawn(8)
			animate(src)
			loc = null
obj/DashImage
	Grabbable=0
	Destructable=0
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


obj/coolImage
	Grabbable=0
	Destructable=0
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
		if(!A.Dodging&&!Target.Dodging)
			A.Dodging=1
			Target.Dodging=1
			var/Zanzes=4
			var/StartA=A.loc
			var/StartT=Target.loc
			if(Target.AfterImageStrike||(locate(/obj/Skills/Zanzoken, Target))&&prob(20))
				if(glob.AISCLASHLOCKSMOVEMENT && Target.client)
					Target?:move_disabled = TRUE
					A?:move_disabled = TRUE
				animate(A,alpha=0,time=2, flags=ANIMATION_END_NOW )
				animate(Target,alpha=0,time=2, flags=ANIMATION_END_NOW )
				sleep(1)
				VanishImage(A)
				VanishImage(Target)
				sleep(1)
				while(Zanzes)
					Zanzes--
					if(Zanzes<=0)
						A.loc=StartA
						Target.loc=StartT
						step_away(A,Target,4,256)
						step_away(Target,A,4,256)
						A.dir=get_dir(A,Target)
						Target.dir=get_dir(Target,A)
						if(Target.AfterImageStrike)
							Target.AfterImageStrike--
					else
						A.Move(locate((A.x+pick(-5,-3,3,5)),(A.y+pick(-5,-3,3,5)),A.z))
						Target.Move(locate((A.x+pick(-1,1)),(A.y+pick(-1,1)),A.z))
						A.dir=get_dir(A,Target)
						AfterImageA(A)
						AfterImageA(Target)
						KenShockwave(Target,icon='KenShockwave.dmi',Size=max(A.GetIntimidation()+Target.GetIntimidation()*GoCrand(0.04,0.4),0.2),PixelX=((Target.x-A.x)*(-16)+pick(-12,-8,8,12)),PixelY=((Target.y-A.y)*(-16)+pick(-12,-8,8,12)), Time=6)
						sleep(5)
				if(glob.AISCLASHLOCKSMOVEMENT)
					if(Target)
						Target?:move_disabled = FALSE
					A?:move_disabled = FALSE
				A.loc = StartA
				if(Target)
					Target.loc = StartT
				animate(A,alpha=255, time=1, flags=ANIMATION_END_NOW | ANIMATION_PARALLEL)
				animate(Target,alpha=255, time=1, flags=ANIMATION_END_NOW | ANIMATION_PARALLEL)
			else
				AfterImage(A)
				A.Comboz(Target)
				A.dir=get_dir(A,Target)
				if(Striking)
					A.NextAttack=0
					A.Melee1(1, 5, SureKB=1)
			A.Dodging=0
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
			if(A.filters.len > 0)
				if(A.filters[A.filters.len])
					animate(A.filters[A.filters.len], x=changeX/4, y=changeY/4, time=2, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			animate(A,pixel_x=changeX, pixel_y=changeY, time=2, flags=ANIMATION_RELATIVE)
			sleep(2)
			animate(A,pixel_x=-changeX, pixel_y=-changeY, time=1, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			if(A.filters.len > 0) // why
				if(A.filters[A.filters.len])
					animate(A.filters[A.filters.len], x=0, y=0, time=1)
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
	UltraPrediction(mob/A,mob/Target)
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
			A.Melee1(1, 5, accmulti=1.25, SureKB=15)
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
