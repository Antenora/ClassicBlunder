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
					if(M.HasMaouKi())
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


obj/Effects
	layer=EFFECTS_LAYER
	Grabbable=0
	//quick light pulse at the strike point, tinted from the bolt's own art
	proc/StrikeFlash(size = 3.4)
		FxLightPulse(get_turf(src), size, FxEffectColor(src))
	Stun
		icon='Stun.dmi'
	RPMode
		icon='RPMode.dmi'
	fevLightningStrike
		icon='Lightning2.dmi'
		pixel_x=-16
		Lifetime=-1 //skip the base fade, Strike() finishes itself
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				StrikeFlash()
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrike2
		icon='Lightning3.dmi'
		pixel_x=-16
		Lifetime=-1
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				StrikeFlash()
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrikeBlackPurple
		icon='LightningBlackPurple.dmi'
		pixel_x=-16
		Lifetime=-1
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=0 //keep at 0, ADD eats the black core and leaves a purple wireframe
				StrikeFlash()
				spawn(2)
					KenShockwave(M=src,Size=0.5)
				spawn(3)
					KenShockwave(M=src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrikeRed
		icon='LightningRed.dmi'
		pixel_x=-16
		Lifetime=-1
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				StrikeFlash()
				spawn(2)
					KenShockwave(M=src,Size=0.5)
				spawn(3)
					KenShockwave(M=src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrikeVFX5
		icon='Lightning VFX4.dmi'
		pixel_x=-64
		Lifetime=-1
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				StrikeFlash()
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevLightningStrikeHyperDeath
		icon='LightningHyperdeath.dmi'
		pixel_x=-64
		Lifetime=-1
		proc
			Strike()
				src.icon_state="Strike"
				src.blend_mode=2
				StrikeFlash()
				spawn(2)
					KenShockwave(src,Size=0.5)
				spawn(3)
					KenShockwave(src,Size=1)
				spawn(3.5)
					EffectFinish()
	fevPriestErupt
		icon='Priest VFX2.dmi'
		pixel_x=-16
		pixel_y=-21
		Lifetime=-1
		proc
			Strike()
				src.blend_mode=2
				StrikeFlash(2.6)
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
	New(loc, var/CustomIcon=0, var/CustomX=0, var/CustomY=0, var/CustomTurn=0, var/CustomSize=1, var/Life=0, overwrite_alpha=0)
		..()
		var/matrix/SizeState=matrix()
		if(CustomIcon && isfile(CustomIcon))
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
			src.transform = SizeState
		if(src.Turns)
			var/ang = pick(45,-45,0,-90,90,135,-135,180)
			SizeState.Turn(ang)
			fx_rot = ang
			src.transform = SizeState
		fx_size = src.Size ? src.Size : 1
		fx_t0 = world.time
		if(Life)
			src.Lifetime=Life
		else if(!Lifetime)
			src.Lifetime=10

		if(src.Lifetime > 0) //Lifetime<=0 opts out of the fade, persistent props stay put
			spawn(1)
				animate(src,alpha=overwrite_alpha,time=src.Lifetime)
			spawn(src.Lifetime+1)
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

	DarkBang
		icon='fevExplosion - Hellfire.dmi'
		pixel_x=-32
		pixel_y=-32
		Lifetime=8
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

//motes for every Dust puff - one shared instance world-wide
particles/dust_motes
	icon = 'dust.dmi'
	icon_state = "dust1"
	width = 96
	height = 96
	count = 7
	spawning = 1
	lifespan = 18
	fade = 6
	fadein = 2 //particles POP into existence without it
	position = generator("box", list(-8,-2), list(8,8))
	scale = generator("num", 0.06, 0.14, NORMAL_RAND)
	drift = generator("circle", 0, 0.4)
	friction = 0.1
	gravity = list(0, -0.05)
var/particles/dust_motes/FxDustMotes = new

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
				src.transform = matrix()*0.1
				spawn(1000) if(src) EffectFinish()
		Dust
			name=""
			layer=EFFECTS_LAYER
			icon='dust.dmi'
			Lifetime=-1 //no base fade chain
			var/tmp/matrix/baked //animate() commits its end state, wrappers restage alpha and grow from this
			New()
				icon_state = "dust[rand(1, 4)]"
				pixel_x=-16
				pixel_y=-16
				pixel_x += rand(-16, 16)
				pixel_y += rand(-16, 16)
				particles = FxDustMotes
				//turn and scale go in one matrix or the next animate wipes the rotation
				var/ang = pick(0, 45, 90, 135, 180, 225, 270, 315)
				transform = turn(matrix()*0.5, ang)
				baked = transform
				animate(src, transform = turn(matrix()*0.85, ang + rand(-25, 25)), pixel_x = pixel_x + gauss(5), pixel_y = pixel_y + rand(2, 7), alpha = 0, time = 26, easing = QUAD_EASING|EASE_OUT)
				spawn(26) if(src) EffectFinish()
		Explosion
			layer=EFFECTS_LAYER
			icon='explosion.dmi'
			New()
				icon_state = "[rand(1, 4)]"
				pixel_x=-16
				pixel_y=-16
				pixel_x += rand(-16, 16)
				pixel_y += rand(-16, 16)
				var/ang = pick(0, 45, 90, 135, 180, 225, 270, 315)
				fx_rot = ang
				transform = turn(matrix()*0.5, ang)


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
			animate(src,alpha=0,time=Lifetime,transform=matrix()*Size,easing=QUAD_EASING|EASE_OUT)//Enlarges overtime and then fades away
			spawn(Lifetime)
				EffectFinish()
proc
	KenShockwave(atom/M,icon='Icons/Effects/KenShockwave.dmi',Size=1,PixelX=0,PixelY=0,Blend=0, Time=12)  //M is the person that makes t
		set waitfor=0
		if(Size>5)
			Size=5
		var/obj/Effects/KenShockwave/S=new
		. = S
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
		if(PmActive() && ismovable(M)) //mid-tile mobs: mirror the real offsets
			var/atom/movable/AM = M
			S.step_x = AM.step_x
			S.step_y = AM.step_y
		FxDistortRing(M, Size)

obj/Effects/KenShockwave2
	icon='KenShockwave.dmi'
	pixel_x=-105
	pixel_y=-105
	Grabbable=0
	mouse_opacity=0
	layer=EFFECTS_LAYER
	New()
		animate(src,transform=matrix()*Size)
		//contracts instead of expanding, so EASE_IN
		spawn(1)
			animate(src,alpha=0,time=Lifetime,transform=matrix()*0.1,easing=QUAD_EASING|EASE_IN)
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
		if(PmActive() && ismovable(M))
			var/atom/movable/AM = M
			S.step_x = AM.step_x
			S.step_y = AM.step_y
		FxDistortRing(M, min(Size, 5)) //Size here is a contraction start scale, can be huge - the ring needs the cap

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
			animate(src,alpha=0,time=Lifetime,transform=matrix()*Size,easing=QUAD_EASING|EASE_OUT)//Enlarges overtime and then fades away
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
		if(PmActive() && ismovable(M)) //mirror mid-tile offsets, like KenShockwave
			var/atom/movable/AM = M
			S.step_x = AM.step_x
			S.step_y = AM.step_y
		FxDistortRing(M, Size)


//Proc definitions for object types


/obj/screen/glass_shard
	icon = 'Icons/Effects/GlassEffect.dmi'
	plane = FX_RELAY_PLANE
	layer = 20
	mouse_opacity = 0
	appearance_flags = KEEP_TOGETHER
	var/rel_x = 0
	var/rel_y = 0

/proc/ScreenShatter(mob/target)
	set waitfor = 0
	if(!target?.client)
		return

	var/client/C = target.client

	var/vw = 15
	var/vh = 15
	if(isnum(C.view))
		vw = C.view * 2 + 1
		vh = vw
	else
		var/view_text = "[C.view]"
		var/x_pos = findtext(view_text, "x")
		if(x_pos)
			vw = text2num(copytext(view_text, 1, x_pos))
			vh = text2num(copytext(view_text, x_pos + 1))

	var/eff_w = min(vw, 31)
	var/eff_h = min(vh, 31)
	var/off_x = round((vw - eff_w) / 2)
	var/off_y = round((vh - eff_h) / 2)
	var/cx = round(eff_w / 2) + 1
	var/cy = round(eff_h / 2) + 1

	var/obj/flash_overlay = new
	flash_overlay.screen_loc = "CENTER"
	flash_overlay.plane = FX_RELAY_PLANE
	flash_overlay.layer = 21
	flash_overlay.mouse_opacity = 0
	flash_overlay.appearance_flags = PIXEL_SCALE
	flash_overlay.alpha = 0
	var/icon/flash_icon = new('Icons/Effects/GlassEffect.dmi', "1")
	flash_icon.DrawBox("#FFFFFF", 1, 1, 32, 32)
	flash_overlay.icon = flash_icon
	var/matrix/flash_scale = matrix()
	flash_scale.Scale(35, 35)
	flash_overlay.transform = flash_scale
	C.screen += flash_overlay

	animate(flash_overlay, alpha = 255, time = 12)
	sleep(12)

	if(!target?.client)
		C.screen -= flash_overlay
		return //refcount frees these at proc end, never del

	var/list/all_tiles = list()
	var/list/cached_overlays = list()
	for(var/sn = 2 to 8)
		cached_overlays += image('Icons/Effects/GlassEffect.dmi', icon_state = "[sn]")

	for(var/tx = 1 to eff_w)
		for(var/ty = 1 to eff_h)
			var/sx = tx + off_x
			var/sy = ty + off_y
			var/tile_rot = pick(0, 90, 180, 270)
			var/matrix/T = matrix()
			if(prob(50))
				T.Scale(-1, 1)
			if(tile_rot)
				T.Turn(tile_rot)
			var/obj/screen/glass_shard/tile = new
			tile.icon_state = "1"
			tile.screen_loc = "[sx],[sy]"
			tile.rel_x = tx - cx
			tile.rel_y = ty - cy
			tile.transform = T
			tile.overlays += cached_overlays
			all_tiles += tile

	C.screen += all_tiles

	sleep(5)

	if(!target?.client)
		C.screen -= all_tiles
		C.screen -= flash_overlay
		return

	var/list/all_shards = list()
	var/list/new_pieces = list()
	for(var/obj/screen/glass_shard/tile in all_tiles)
		tile.overlays.Cut()
		tile.appearance_flags = 0
		all_shards += tile
		for(var/sn = 2 to 8)
			var/obj/screen/glass_shard/piece = new
			piece.icon_state = "[sn]"
			piece.screen_loc = tile.screen_loc
			piece.transform = tile.transform
			new_pieces += piece
			all_shards += piece

	C.screen += new_pieces

	animate(flash_overlay, alpha = 0, time = 10)

	sleep(5)

	if(!target?.client)
		C.screen -= all_shards
		C.screen -= flash_overlay
		return

	for(var/obj/screen/glass_shard/shard in all_shards)
		var/fly_angle = rand(0, 359)
		var/fly_dist = rand(500, 1100)
		var/fly_x = cos(fly_angle) * fly_dist
		var/fly_y = sin(fly_angle) * fly_dist - rand(100, 250)
		var/spin = rand(-2880, 2880)
		var/matrix/rot_matrix = matrix()
		rot_matrix.Turn(spin)
		animate(shard, pixel_x = fly_x, pixel_y = fly_y, alpha = 0, transform = rot_matrix, time = rand(6, 14), easing = QUAD_EASING | EASE_IN)

	sleep(10)

	if(target?.client)
		C.screen -= flash_overlay

	sleep(10)

	if(target?.client)
		target.client.screen -= all_shards
	//shards free by refcount once off screen, never del these