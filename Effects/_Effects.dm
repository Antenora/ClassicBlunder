//Object definitions


obj/Effects
	var/Glass=0
	Health=1000000000000000000000000000000000000

	PDEffect
		Grabbable=0
		Savable=0
		density=1

	Tornado
		icon='Effects.dmi'
		icon_state="Tornado"
		Grabbable=0
		Savable=0
		Lifetime=-1
		New()
			var/image/A=image(icon='Effects.dmi',icon_state="Tornado",pixel_y=64)
			var/image/B=image(icon='Effects.dmi',icon_state="Tornado",pixel_y=32)
			overlays.Add(A,B)
			walk_rand(src,4)
			spawn(75) if(src) EffectFinish()

	DeadZone
		Grabbable=0
		Savable=0
		icon='Portal.dmi'
		icon_state="center"
		Lifetime=-1
		New()
			var/image/A=image(icon='Portal.dmi',icon_state="n")
			var/image/B=image(icon='Portal.dmi',icon_state="e")
			var/image/C=image(icon='Portal.dmi',icon_state="s")
			var/image/D=image(icon='Portal.dmi',icon_state="w")
			var/image/E=image(icon='Portal.dmi',icon_state="ne")
			var/image/F=image(icon='Portal.dmi',icon_state="nw")
			var/image/G=image(icon='Portal.dmi',icon_state="sw")
			var/image/H=image(icon='Portal.dmi',icon_state="se")
			A.pixel_y+=32
			B.pixel_x+=32
			C.pixel_y-=32
			D.pixel_x-=32
			E.pixel_y+=32
			E.pixel_x+=32
			F.pixel_y+=32
			F.pixel_x-=32
			G.pixel_y-=32
			G.pixel_x-=32
			H.pixel_y-=32
			H.pixel_x+=32
			overlays+=A
			overlays+=B
			overlays+=C
			overlays+=D
			overlays+=E
			overlays+=F
			overlays+=G
			overlays+=H
			spawn while(src)
				sleep(1)
				for(var/mob/M in oview(12,src)) if(prob(20))
					//M.move=1
					step_towards(M,src)
				for(var/mob/M in view(0,src))
					if(src.z==21)
						view(12,src)<<"[M] is sent back into the mortal plane!"
						M.loc=locate(450,100,5)
					else
						view(12,src)<<"[M] is damned to the depths of Hell!"
						M.loc=locate(113,255,21)
				if(prob(0.5)) EffectFinish()

	Blackhole
		Grabbable=0
		Savable=0
		icon='Portal.dmi'
		icon_state="center"
		Lifetime=-1
		New()
			var/image/A=image(icon='Portal.dmi',icon_state="n")
			var/image/B=image(icon='Portal.dmi',icon_state="e")
			var/image/C=image(icon='Portal.dmi',icon_state="s")
			var/image/D=image(icon='Portal.dmi',icon_state="w")
			var/image/E=image(icon='Portal.dmi',icon_state="ne")
			var/image/F=image(icon='Portal.dmi',icon_state="nw")
			var/image/G=image(icon='Portal.dmi',icon_state="sw")
			var/image/H=image(icon='Portal.dmi',icon_state="se")
			A.pixel_y+=32
			B.pixel_x+=32
			C.pixel_y-=32
			D.pixel_x-=32
			E.pixel_y+=32
			E.pixel_x+=32
			F.pixel_y+=32
			F.pixel_x-=32
			G.pixel_y-=32
			G.pixel_x-=32
			H.pixel_y-=32
			H.pixel_x+=32
			overlays+=A
			overlays+=B
			overlays+=C
			overlays+=D
			overlays+=E
			overlays+=F
			overlays+=G
			overlays+=H
			spawn while(src)
				sleep(1)
				for(var/mob/M in oview(20,src))
					if(prob(50)&&M!=Owner)
					//M.move=1
						step_towards(src,M)
						if(prob(50))
							step_towards(M,src)
				for(var/mob/M in view(1,src))
					if(M.HasGodKi())
						view(20,src)<<"[M]'s body is rejected by the black hole!"
						M.loc=locate(rand(25,250),rand(25,250),M.z)
					else
						view(20,src)<<"[M] disappears into the flurry..!"
						M.loc=locate(rand(25,250),rand(25,250),rand(1,8))
				if(prob(1))
					view(20,src)<<"The Black Hole dissipates..."
					EffectFinish()


	DividingField
		Grabbable=0
		Savable=0
		density=1
		Lifetime=-1

	PocketPortal
		Grabbable=0
		Savable=1
		density=1
		mouse_opacity=1
		Lifetime=-1
		icon='BlackHole.dmi'
		New(var/X, var/Y, var/Z)
			src.loc=locate(X, Y, Z)


	PocketExit
		Grabbable=1
		Savable=1
		density=0
		mouse_opacity=1
		Lifetime=-1
		icon='BlackHole.dmi'
		New()
			if(!src.Password)
				var/list/Nums=list()
				for(var/x=1, x<99, x++)
					Nums.Add(x)
				for(var/obj/Effects/PocketExit/PE in world)
					if(PE.Password in Nums)
						Nums.Remove(PE.Password)
				src.Password=pick(Nums)
		verb/Lock()
			set category=null
			set src in view(1, usr)
			if(src.Grabbable==1&&src.density==0)
				src.density=1
				src.Grabbable=0
				usr << "You've locked the portal exit; it's now usable."
			else
				usr << "You've already locked this exit in place."
				return

	Barrier
		Grabbable=0
		Savable=0
		density=1
		Glass=1
		Lifetime=-1
		icon='enchantmenticons.dmi'
		icon_state="Barrier"
		New()
			..()
			spawn(1200)
				EffectFinish()

	ForceField
		Grabbable=0
		Savable=1
		density=1
		Glass=1
		var/FieldPassword
		icon='Tech.dmi'
		icon_state="ForceField"

	Sparkles
		Grabbable=0
		Savable=0
		density=0
		icon='Special.dmi'
		icon_state="Special8"
		New()
			..()
			spawn(50)
				EffectFinish()

	PoisonGas
		Grabbable=0
		Savable=0
		density=0
		Lifetime=-1
		icon='Dust.dmi'
		icon_state="dust1"
		pixel_x=-16
		pixel_y=-16

		New()
			..()
			icon+=rgb(0,100,0,125)
			spawn()
				while(src)
					sleep(5)
					for(var/mob/M in view(0,src))
						if(M==src.Owner)
							return
						else
							M.AddPoison(5)
					step_rand(src)
					spawn(150)
						EffectFinish()


	Dust
		name = ""
		mouse_opacity = 0
		layer = 5
		icon = 'Dust.dmi'
		icon_state = "dust1"
		pixel_x = -16
		pixel_y = -16
		Lifetime=-1
		var/disperse_speed=3

		New()
			..()
			icon+=rgb(0,0,0,255)
			icon_state = "dust[rand(1, 2)]"
			dir = pick(NORTH, WEST, EAST, SOUTH, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			pixel_x += rand(-8, 8)
			pixel_y += rand(-8, 8)
			disperse_speed=rand(1,5)

			disperse()

			spawn(rand(30, 60))
				EffectFinish()

		proc/disperse()
			switch(dir)
				if(NORTH)
					pixel_y++
				if(SOUTH)
					pixel_y--
				if(WEST)
					pixel_x--
				if(EAST)
					pixel_x++
				if(NORTHEAST)
					pixel_y++
					pixel_x++
				if(SOUTHEAST)
					pixel_y--
					pixel_x++
				if(NORTHWEST)
					pixel_y++
					pixel_x--
				if(SOUTHWEST)
					pixel_y--
					pixel_x--
			spawn(disperse_speed) .()


obj/Effects
	layer=EFFECTS_LAYER
	Grabbable=0
	Stun
		icon='Stun.dmi'
	RPMode
		icon='RPMode.dmi'
	fevLightningStrike
		icon='Lightning2.dmi'
		pixel_x=-16
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrike2
		icon='Lightning3.dmi'
		pixel_x=-16
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrikeRed
		icon='LightningRed.dmi'
		pixel_x=-16
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				spawn(2)
					KenShockwave(M=src,Size=0.5)
				spawn(3)
					KenShockwave(M=src,Size=1)
				spawn(3.5)
					EffectFinish()


obj/Effects
	var
		Target//Who got punched?
		Turns//This keeps track of if the icon can be turned, like a sword slash.
		//pixel_x
		//pixel_y
		Lifetime=10//This is how long it takes for the effect to fade.
		Size//Multiply icon size by this value
	New(var/CustomIcon=0, var/CustomX=0, var/CustomY=0, var/CustomTurn=0, var/CustomSize=1, var/Life=0, overwrite_alpha=0)
		var/matrix/SizeState=matrix()
		if(CustomIcon)
			src.icon=CustomIcon
			if(CustomX)
				src.pixel_x=CustomX
			else
				src.pixel_x=0
			if(CustomY)
				src.pixel_y=CustomY
			else
				src.pixel_y=0
			src.Turns=CustomTurn
			src.Size=CustomSize
		if(src.Size)
			SizeState.Scale(src.Size,src.Size)
			animate(src, transform=SizeState, time=0)
		if(src.Turns)
			SizeState.Turn(pick(45,-45,0,-90,90,135.-135,180))
			animate(src, transform =SizeState, time=0)
		if(Life)
			src.Lifetime=Life
		else if(!Lifetime)
			src.Lifetime=10
		spawn(1)
			animate(src,alpha=overwrite_alpha,time=src.Lifetime)

		if(Lifetime > 0)
			spawn(src.Lifetime+1)//Hopefully this doesn't fuck things up.
				//if it does, just make this spawn equal to Lifetime+1.
				//Hopefully it won't require any higher logic.
				EffectFinish()
	proc/EffectFinish()
		for(var/atom/movable/a in vis_locs)
			a.vis_contents -= src
		for(var/turf/t in vis_locs)
			t.vis_contents -= src
		for(var/i in vis_contents)
			vis_contents -= i
		animate(src)
		Target = null
		src.loc=null
/*		sleep(10)
		if(src)
			del src*/

	proc
		Target_Watch()
			Start
			spawn(1)
				if(Target)
					loc=Target:loc
					pixel_z=Target:pixel_z
					if(loc != null)
						goto Start
	Freeze
		icon='Icons/Effects/ice aura.dmi'
		Lifetime = 12
		pixel_x=-8
		pixel_y=-2
		alpha = 255

	Bang
		icon='fevExplosion.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=8
	Parry
		icon='wordeffects.dmi'
		icon_state = "parry"
		pixel_x=18
		pixel_y=18
		Lifetime=6
	crit
		icon='wordeffects.dmi'
		icon_state = "crit"
		pixel_x=18
		pixel_y=18
		Lifetime=6
	critB
		icon='wordeffects.dmi'
		icon_state = "critblock"
		pixel_x=18
		pixel_y=18
		Lifetime=6
	Iai
		icon='wordeffects.dmi'
		icon_state = "iai"
		pixel_x=18
		pixel_y=18
		Lifetime=6
	Interception
		icon='wordeffects.dmi'
		icon_state = "interception"
		pixel_x=18
		pixel_y=18
		Lifetime=6
	Dirt
		icon='fevExplosion - Dust.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=8
	SweepingKick
		icon='SweepingKick.dmi'
		pixel_x=-32
		pixel_y=-32
		Size=1.5
		Lifetime=5
	SweepingBlade
		icon='CircleWind.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=5
	Slash
		icon='Slash.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=5
		Turns=1
	Scratch
		icon='Scuratchu.dmi'
		pixel_x=0
		pixel_y=0
		Lifetime=5
		Turns=1
	HitEffect
		icon='Hit Effect.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=6

obj
	Effects
		density=0
		Grabbable=0
		Savable=0
		mouse_opacity=0
		RozanEffect
			pixel_x=-32
			icon='RozanNew2.dmi'
			New()
		ShoryukenEffect
			pixel_x=-32
			icon='UppercutEffect.dmi'
			New()
		GoshoryukenEffect
			pixel_x=-32
			icon='DarkUppercutEffect.dmi'
			New()
		LotusEffect
			pixel_x=-32
			icon='DropEffect.dmi'
			New()
		Crater
			layer=OBJ_LAYER+0.5
			icon='Crater.dmi'
			New()
				pixel_x=-32
				pixel_y=-32
				animate(src,transform=matrix()*0.1)
				spawn(1000) if(src) EffectFinish()
		Dust
			layer=EFFECTS_LAYER
			icon='dust.dmi'
			New()
				icon_state = "dust[rand(1, 4)]"
				transform = turn(transform, pick(0, 45, 90, 135, 180, 225, 270, 315))
				pixel_x=-16
				pixel_y=-16
				pixel_x += rand(-16, 16)
				pixel_y += rand(-16, 16)
				animate(src,transform=matrix()*0.5)
				spawn(26) if(src) EffectFinish()
		Explosion
			layer=EFFECTS_LAYER
			icon='explosion.dmi'
			New()
				icon_state = "[rand(1, 4)]"
				transform = turn(transform, pick(0, 45, 90, 135, 180, 225, 270, 315))
				pixel_x=-16
				pixel_y=-16
				pixel_x += rand(-16, 16)
				pixel_y += rand(-16, 16)
				animate(src,transform=matrix()*0.5)


obj/Effects/KenShockwave
	icon='KenShockwave.dmi'
	pixel_x=-105
	pixel_y=-105
	Grabbable=0
	mouse_opacity=0
	layer=EFFECTS_LAYER
	New()
		animate(src,transform=matrix()*0.1)//The Shockwave starts out small
		spawn(1)
			animate(src,alpha=0,time=Lifetime,transform=matrix()*Size)//Enlarges overtime and then fades away
			spawn(Lifetime)
				EffectFinish()
proc
	KenShockwave(atom/M,icon='KenShockwave.dmi',Size=1,PixelX=0,PixelY=0,Blend=0, Time=12)  //M is the person that makes t
		set waitfor=0
		if(Size>5)
			Size=5
		var/obj/Effects/KenShockwave/S=new
		S.icon=icon
		S.blend_mode=Blend
		if(isturf(M)&&M.density)
			S.loc=M
		else
			S?.loc=M?.loc
			S?.pixel_z=M?.pixel_z
		S.Size=Size
		S.Lifetime=Time
		S.pixel_x+=PixelX
		S.pixel_y+=PixelY
		/*S.step_x=M.step_x//Step X and Step Y are for pixel movement purposes; not needed in TileBased
		S.step_y=M.step_y*/

obj/Effects/KenShockwave2
	icon='KenShockwave.dmi'
	pixel_x=-105
	pixel_y=-105
	Grabbable=0
	mouse_opacity=0
	layer=EFFECTS_LAYER
	New()
		animate(src,transform=matrix()*Size)
		spawn(1)
			animate(src,alpha=0,time=Lifetime,transform=matrix()*0.1)
			spawn(Lifetime)
				EffectFinish()
proc
	KenShockwave2(atom/M,icon='KenShockwave.dmi',Size=1,PixelX=0,PixelY=0,Blend=0, Time=24)  //M is the person that makes t
		set waitfor=0
		var/obj/Effects/KenShockwave2/S=new
		S.icon=icon
		S.blend_mode=Blend
		if(isturf(M)&&M.density)
			S.loc=M
		else
			S.loc=M.loc
			S.pixel_z=0
		S.Size=Size
		S.Lifetime=Time
		S.pixel_x+=PixelX
		S.pixel_y+=PixelY
		/*S.step_x=M.step_x//Step X and Step Y are for pixel movement purposes; not needed in TileBased
		S.step_y=M.step_y*/

obj/Effects/KKTShockwave
	icon='KenShockwave.dmi'
	pixel_x=-105
	pixel_y=-105
	Grabbable=0
	mouse_opacity=0
	layer=MOB_LAYER-1
	appearance_flags=NO_CLIENT_COLOR
	New()
		animate(src,transform=matrix()*0.1)//The Shockwave starts out small
		spawn(1)
			animate(src,alpha=0,time=Lifetime,transform=matrix()*Size)//Enlarges overtime and then fades away
			spawn(Lifetime)
				EffectFinish()
proc
	KKTShockwave(atom/M,icon='KenShockwave.dmi',Size=1,PixelX=0,PixelY=0,Blend=0, Time=12)  //M is the person that makes t
		set waitfor=0
		if(Size>5)
			Size=5
		var/obj/Effects/KKTShockwave/S=new
		S.icon=icon
		S.blend_mode=Blend
		if(isturf(M)&&M.density)
			S.loc=M
		else
			S.loc=M.loc
			S.pixel_z=M.pixel_z
		S.Size=Size
		S.Lifetime=Time
		S.pixel_x+=PixelX
		S.pixel_y+=PixelY


//Proc definitions for object types