/mob/var/in_grapple
/client/var/tmp/obj/client_plane_master/client_plane_master
proc
	LeaveImage(var/mob/Players/User=0, var/Image, var/PX=0, var/PY=0, var/PZ=0, var/Size=1, var/Under=0, var/Time, var/turf/AltLoc=0, var/Dir=SOUTH)
		var/image/i
		if(User&&!AltLoc)
			if(Under)
				i=image(loc=User, icon=Image, pixel_x=PX-User.pixel_x, pixel_y=PY-User.pixel_y, pixel_z=PZ, layer=User.layer-1, dir=User.dir)
			else
				i=image(loc=User, icon=Image, pixel_x=PX-User.pixel_x, pixel_y=PY-User.pixel_y, pixel_z=PZ, layer=EFFECTS_LAYER, dir=User.dir)
			if(User.CheckSlotless("Great Ape"))
				i.transform*=3
		if(AltLoc&&!User)
			if(Under)
				i=image(loc=AltLoc, icon=Image, pixel_x=PX, pixel_y=PY, pixel_z=PZ, layer=MOB_LAYER-1, dir=Dir)
			else
				i=image(loc=AltLoc, icon=Image, pixel_x=PX, pixel_y=PY, pixel_z=PZ, layer=EFFECTS_LAYER, dir=Dir)
			i.appearance_flags=KEEP_APART | RESET_COLOR | RESET_ALPHA
		i.transform*=Size
		i.alpha=0
		world << i
		animate(i, alpha=255, time=2)
		sleep(Time)
		animate(i, alpha=0, time=2)
		sleep(2)
		del i
	LeaveDescendingImage(var/mob/Players/User=0, var/Image, var/PX=0, var/PY=0, var/PZ=0, var/Size=1, var/Under=0, var/Time, var/turf/AltLoc=0, var/Dir=SOUTH)
		var/image/i
		if(User&&!AltLoc)
			if(Under)
				i=image(loc=User, icon=Image, pixel_x=PX-User.pixel_x, pixel_y=PY-User.pixel_y, pixel_z=PZ, layer=User.layer-1, dir=User.dir)
			else
				i=image(loc=User, icon=Image, pixel_x=PX-User.pixel_x, pixel_y=PY-User.pixel_y, pixel_z=PZ, layer=EFFECTS_LAYER, dir=User.dir)
			if(User.CheckSlotless("Great Ape"))
				i.transform*=3
		if(AltLoc&&!User)
			if(Under)
				i=image(loc=AltLoc, icon=Image, pixel_x=PX, pixel_y=PY, pixel_z=PZ, layer=MOB_LAYER-1, dir=Dir)
			else
				i=image(loc=AltLoc, icon=Image, pixel_x=PX, pixel_y=PY, pixel_z=PZ, layer=MOB_LAYER+1, dir=Dir)
			i.appearance_flags=KEEP_APART | RESET_COLOR | RESET_ALPHA
		i.transform*=Size
		i.alpha=0
		world << i

		animate(i, alpha=255, time=2)
		animate(i, pixel_z=0, time=Time)
		sleep(Time)
		animate(i, alpha=0, time=2)
		sleep(2)
		del i

	WaveTrail(trail, p_x, p_y, Dir, turf/location, time, size, state)
		var/image/i=image(trail, pixel_x=p_x, pixel_y=p_y, dir=Dir, icon_state=state)
		var/image/i2=image(trail, pixel_x=p_x, pixel_y=p_y, dir=Dir, icon_state=state)
		var/image/i3=image(trail, pixel_x=p_x, pixel_y=p_y, dir=Dir, icon_state=state)
		i.loc=location
		i2.loc=location
		i3.loc=location
		switch(Dir)
			if(NORTH)
				i2.pixel_x -= 32
				i3.pixel_x += 32
			if(SOUTH)
				i2.pixel_x -= 32
				i3.pixel_x += 32
			if(WEST)
				i2.pixel_y -= 32
				i3.pixel_y += 32
			if(EAST)
				i2.pixel_y -= 32
				i3.pixel_y += 32
			if(NORTHEAST)
				i2.pixel_x -= 32
				i2.pixel_y += 32
				i3.pixel_x += 32
				i3.pixel_y -= 32
			if(NORTHWEST)
				i2.pixel_x -= 32
				i2.pixel_y -= 32
				i3.pixel_x += 32
				i3.pixel_y += 32
			if(SOUTHEAST)
				i2.pixel_x += 32
				i2.pixel_y += 32
				i3.pixel_x -= 32
				i3.pixel_y -= 32
			if(SOUTHWEST)
				i2.pixel_x -= 32
				i2.pixel_y += 32
				i3.pixel_x += 32
				i3.pixel_y -= 32

		i.transform*=size
		i2.transform*=size
		i3.transform*=size
		world << i
		world << i2
		world << i3
		spawn(time)
			animate(i, alpha=0, time=2)
			animate(i2, alpha=0, time=2)
			animate(i3, alpha=0, time=2)
			sleep(2)
			del i
			del i2
			del i3


	LeaveTrail(var/Trail, var/PX=0, var/PY=0, var/Dir, var/turf/Location, var/Time, var/Size, var/State)
		if(Trail=='Icons/Turfs/GalSpace.dmi') //ill add in a variable for randomization later
			State = "[rand(1,25)]"
		var/image/i=image(Trail, pixel_x=PX, pixel_y=PY, dir=Dir, icon_state=State)
		i.transform*=Size
		world << i
		i.loc=Location
		spawn(Time)
			animate(i, alpha=0, time=2)
			sleep(2)
			del i

	Jump(var/mob/User, var/UpTime=3, var/FloatTime=0, var/DownTime=2)
		set waitfor = 0
		animate(User,pixel_z=48,time=UpTime, easing=BACK_EASING, flags=ANIMATION_END_NOW | ANIMATION_RELATIVE)
		sleep(UpTime)
		if(FloatTime)
			sleep(FloatTime*10)
		animate(User,pixel_z=-48,time=DownTime, easing=QUAD_EASING, flags=ANIMATION_END_NOW | ANIMATION_RELATIVE)

	SuplexEffect(var/mob/User, var/mob/Target) //MATTHEEEEEEEEW
		if(!User || !Target || User.loc == null || Target.loc == null)
			return
		User.Frozen=2
		Target.Frozen=2
		animate(Target, pixel_z=24, time=5, flags=ANIMATION_RELATIVE)
		sleep(5)
		animate(User, transform=turn(User.transform, -45), time=3)
		animate(Target, pixel_x=-32, pixel_z=-24, time=2, flags=ANIMATION_RELATIVE)
		animate(Target, transform=turn(Target.transform, -135), time=2, flags=ANIMATION_PARALLEL)
		spawn(2)
			KenShockwave(Target,Size=2)
		sleep(7)
		animate(User, transform= turn(User.transform, 45))
		animate(Target, pixel_x=32, flags=ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(Target, transform= turn(Target.transform, 135), flags=ANIMATION_PARALLEL)
		User.Frozen=0
		Target.Frozen=0

	RozanEffect(var/mob/User, var/mob/Target, var/TimeMod=1)
		set waitfor=0
		if(!User || !Target || User.loc == null || Target.loc == null)
			return
		User.Frozen=2
		Target.Frozen=2
		var/obj/Effects/RozanEffect/SE=new
		SE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		SE.Target=Target
		Target.vis_contents += SE
		animate(SE,alpha=0)
		animate(SE,alpha=185,time=10)
		flick("Appear",SE)
		var/ShoryukenTime=4*TimeMod
		var/DelayTime=1
		var/NewZ=Target.pixel_z
		while(ShoryukenTime>0)
			animate(Target,pixel_z=NewZ+15,DelayTime)
			User.HitEffect(Target)
			sleep(DelayTime)
			NewZ=Target.pixel_z
			ShoryukenTime--
		if(SE)
			flick("Vanish",SE)
			animate(SE,alpha=0,time=3)
			spawn(3)
				SE.EffectFinish()
		animate(Target,pixel_z=NewZ+4,time=5)
		sleep(5)
		animate(Target,pixel_z=0,time=5)
		User.Frozen=0
		Target.Frozen=0
	ShoryukenEffect(var/mob/User, var/mob/Target, var/TimeMod=1)
		set waitfor=0
		if(!User || !Target || User.loc == null || Target.loc == null)
			return
		User.Frozen=2
		Target.Frozen=2
		var/obj/Effects/ShoryukenEffect/SE=new
		SE.loc=User.loc
		animate(SE,alpha=0)
		animate(SE,alpha=185,time=10)
		flick("Appear",SE)
		var/ShoryukenTime=4*TimeMod
		var/DelayTime=1
		var/NewZ=Target.pixel_z
		spawn()
			Turn(User, ShoryukenTime)
		while(ShoryukenTime>0)
			animate(Target,pixel_z=NewZ+15,DelayTime)
			animate(User,pixel_z=NewZ+13,DelayTime)
			animate(SE,pixel_z=NewZ,DelayTime)
			if(TimeMod>2)
				User.HitEffect(Target)
			sleep(DelayTime)
			User.dir=turn(User.dir,90)
			NewZ=Target.pixel_z
			ShoryukenTime--
		if(SE)
			flick("Vanish",SE)
			animate(SE,alpha=0,time=3)
			spawn(3)
				SE.EffectFinish()
		animate(Target,pixel_z=NewZ+4,time=5)
		animate(User,pixel_z=NewZ+2,time=5)
		sleep(5)
		animate(Target,pixel_z=0,time=7)
		animate(User,pixel_z=0,time=5)
		User.Frozen=0
		Target.Frozen=0
		//Target.isGrabbed = FALSE
	GoshoryukenEffect(var/mob/User, var/mob/Target, var/TimeMod=1)
		set waitfor=0
		if(!User || !Target || User.loc == null || Target.loc == null)
			return
		User.Frozen=2
		Target.Frozen=2
		var/obj/Effects/GoshoryukenEffect/SE=new
		SE.loc=User.loc
		animate(SE,alpha=0)
		animate(SE,alpha=185,time=10)
		flick("Appear",SE)
		var/ShoryukenTime=4*TimeMod
		var/DelayTime=1
		var/NewZ=Target.pixel_z
		spawn()
			Turn(User, ShoryukenTime)
		while(ShoryukenTime>0)
			animate(Target,pixel_z=NewZ+15,DelayTime)
			animate(User,pixel_z=NewZ+13,DelayTime)
			animate(SE,pixel_z=NewZ,DelayTime)
			if(TimeMod>2)
				User.HitEffect(Target)
			sleep(DelayTime)
			User.dir=turn(User.dir,90)
			NewZ=Target.pixel_z
			ShoryukenTime--
		if(SE)
			flick("Vanish",SE)
			animate(SE,alpha=0,time=3)
			spawn(3)
				SE.EffectFinish()
		animate(Target,pixel_z=NewZ+4,time=5)
		animate(User,pixel_z=NewZ+2,time=5)
		sleep(5)
		animate(Target,pixel_z=0,time=7)
		animate(User,pixel_z=0,time=5)
		User.Frozen=0
		Target.Frozen=0
		//Target.isGrabbed = FALSE

	MuscleBusterEffect(mob/p, mob/t, TimeMod=1)
		if(!t || !p || p.loc == null || t.loc == null)
			return
		p.loc = t.loc
		p.dir = EAST
		t.dir = WEST
		p.Frozen = 2
		t.Frozen = 2
		animate(t, pixel_z=8, time = 5)
		animate(t, transform=turn(t.transform,225), time=5,flags=ANIMATION_LINEAR_TRANSFORM)
		sleep(5)
		animate(t,pixel_z=t.pixel_z +(4*TimeMod*20),time=5)
		animate(p,pixel_z=4*TimeMod*20,time=5)
		sleep(5)
		var/fallTime = TimeMod
		animate(t, pixel_z=8, time = fallTime,flags=ANIMATION_END_NOW)
		animate(p, pixel_z=0, time = fallTime,flags=ANIMATION_END_NOW)
		sleep(fallTime)
		Dust(t.loc,2)
		spawn()Crater(t,TimeMod/2)
		animate(t, transform=t.transform.Turn(-315), time=TimeMod/2,flags=ANIMATION_END_NOW||ANIMATION_LINEAR_TRANSFORM||ANIMATION_PARALLEL)
		animate(t, pixel_z=0, time=TimeMod/2,flags=ANIMATION_LINEAR_TRANSFORM||ANIMATION_PARALLEL)
		step(t,WEST)
		sleep(fallTime)
		t.transform=turn(t.transform, 90)
		t.Frozen=0
		p.Frozen=0


	PotemkinBusterEffect(mob/p, mob/t, TimeMod=1)
		if(!t || !p || p.loc == null || t.loc == null)
			return
		p.loc = t.loc
		p.dir = EAST
		t.dir = WEST
		p.Frozen = 2
		t.Frozen = 2
		var/matrix/ogTrans = t.transform
		animate(t, pixel_z=8, time = 5)
		animate(t, transform=turn(t.transform,90), time=5,flags=ANIMATION_LINEAR_TRANSFORM)
		sleep(5)
		animate(t,pixel_z=t.pixel_z +(4*TimeMod*20),time=5)
		animate(p,pixel_z=4*TimeMod*20,time=5)
		sleep(5)
		var/fallTime = TimeMod*3
		KenShockwave(p,icon='KenShockwaveGold.dmi',Size=5, Blend=2,  Time=fallTime*3)
		KenShockwave(p,icon='KenShockwaveGold.dmi',Size=3, Blend=2,  Time=fallTime*2)
		KenShockwave(p,icon='KenShockwaveGold.dmi',Size=2, Blend=2,  Time=fallTime*1.5)
		KenShockwave(p,icon='KenShockwaveGold.dmi',Size=1, Blend=2,  Time=fallTime)
		KenShockwave(p,icon='KenShockwaveGold.dmi',Size=0.5, Blend=2, Time=fallTime*0.5)
		sleep(3)
		animate(t, pixel_z=8, time = fallTime,flags=ANIMATION_END_NOW)
		animate(p, pixel_z=0, time = fallTime,flags=ANIMATION_END_NOW)
		sleep(fallTime)
		Dust(t.loc,2)
		Bang(t.loc, Size = 3, Vanish = 4)
		spawn()Crater(t,TimeMod/2)
		animate(t, transform=t.transform.Turn(-90), time=TimeMod/2,flags=ANIMATION_END_NOW||ANIMATION_LINEAR_TRANSFORM||ANIMATION_PARALLEL)
		animate(t, pixel_z=0, time=TimeMod/2,flags=ANIMATION_LINEAR_TRANSFORM||ANIMATION_PARALLEL)
		sleep(fallTime)
		t.transform=ogTrans
		t.Frozen=0
		p.Frozen=0


	LotusEffect(var/mob/User, var/mob/Target, var/TimeMod=1)
		if(!User || !Target || User.loc == null || Target.loc == null)
			return
		User.loc=Target.loc
		User.Frozen=2
		Target.Frozen=2
		animate(Target,pixel_z=4*TimeMod*20,time=5)
		animate(User,pixel_z=4*TimeMod*20,time=5)
		sleep(5)
		animate(User, transform=turn(User.transform,90), time=5, flags=ANIMATION_LINEAR_TRANSFORM)
		animate(Target, transform=turn(Target.transform,90), time=5, flags=ANIMATION_LINEAR_TRANSFORM)
		animate(User, transform=turn(User.transform,90), time=5, flags=ANIMATION_LINEAR_TRANSFORM+ANIMATION_END_NOW)
		animate(Target, transform=turn(Target.transform,90), time=5, flags=ANIMATION_LINEAR_TRANSFORM+ANIMATION_END_NOW)
		sleep(5)
		var/ShoryukenTime=3*TimeMod
		animate(Target,pixel_z=0,time=ShoryukenTime,flags=ANIMATION_END_NOW)
		animate(User,pixel_z=0,time=ShoryukenTime,flags=ANIMATION_END_NOW)
		spawn()
			Turn(Target, ShoryukenTime)
		spawn()
			Turn(User, ShoryukenTime)
		sleep(ShoryukenTime)
		Dust(Target.loc,2)
		Dust(Target.loc,2)
		Dust(Target.loc,2)
		if(TimeMod>=3)
			spawn()Crater(Target,TimeMod/3)
		User.transform=turn(User.transform, -180)
		Target.transform=turn(Target.transform, -180)
		User.Frozen=0
		Target.Frozen=0


	SpinTornado(mob/a, mob/d,  time = 5)
		if(!d || !a || d.loc == null || a.loc == null)
			return
		d.loc=a.loc
		d.dir = SOUTH
		a.Frozen=2
		d.Frozen=2
		var/image/im = image('TornadoDirected.dmi', a, "", FLY_LAYER, NORTH, -8,-8)
		a.overlays += im
		for(var/i in 1 to time)
			d.SpinAnimation2(speed = 8 - i/2, a = a)
		a.overlays -= im
		animate(a, pixel_z = 0, time = 4, flags=ANIMATION_PARALLEL)
		animate(d, pixel_z = 0, pixel_y = 0, time = 3, flags=ANIMATION_PARALLEL)
		a.Frozen=0
		d.Frozen=0


	Stomp(mob/atk, mob/def, _time = 1, repeat = 0)
		if(!atk || !def || atk.loc == null || def.loc == null)
			return
		atk.Frozen=2
		def.Frozen=2
		var/orgdir = atk.dir
		atk.dir = SOUTH
		atk.loc=def.loc
		def.icon_state = "KO"
		def.layer = MOB_LAYER-0.25
		animate(atk, pixel_z = 26, time=1)
		sleep(1)
		for(var/x in 1 to repeat)
			animate(atk, pixel_z = 46, time=_time)
			animate(pixel_z = 24, time=_time)
			KenShockwave(def,Size=1)
			Dust(def.loc,_time)
			for(var/turf/t in Turf_Circle(def, 2))
				TurfShift('Dirt1.dmi', t, 1, atk)
			sleep(_time*2)
		def.icon_state = ""
		flick("Attack", atk)
		atk.dir = orgdir
		atk.pixel_x = 0
		atk.pixel_z = 0
		def.layer = MOB_LAYER
		def.pixel_x = 0
		atk.Frozen = 0
		def.Frozen = 0



	Turn(var/mob/a, var/Time=1)
		while(Time>=0)
			animate(a,dir=turn(a.dir,90),time=1, flags=ANIMATION_PARALLEL)
			Time--
			sleep(1)
	turnDynamic(mob/p, angle = 90,t = 1, amount = 1)
		while(amount >=0)
			animate(p, transform=matrix().Turn(angle), time = t, flags=ANIMATION_PARALLEL)
			amount--
			sleep(1)
	WarpEffect(var/mob/Target, var/EffectType)
		if(EffectType==1)
			Target.Stasis=100
			animate(Target, alpha=0, time=30)
			spawn(30)
				var/z=11
				for(var/mob/m in view(10,Target))
					m<<"[Target] was cast out to another dimension!"
				Target.loc=locate(Target.x,Target.y,z)
				spawn(5)
					animate(Target, alpha=255, time=5)
					Target.Stasis=0
		else if(EffectType==2)
			Target.Stasis=100
			animate(Target, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1),time=2)
			spawn(3)
				animate(Target, color=null, time=1)
				Target.Stasis=0
				if(Target.z!=12)
					Target.PrevX=Target.x
					Target.PrevY=Target.y
					Target.PrevZ=Target.z
					Target.loc=locate(144,50,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Hell)
					sleep(10)
					Target.loc=locate(116,82,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Spectres)
					sleep(10)
					Target.loc=locate(144,82,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Beasts)
					sleep(10)
					Target.loc=locate(171,82,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Humans)
					sleep(10)
					Target.loc=locate(116,50,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Demons)
					sleep(10)
					Target.loc=locate(171,50,12)
					Target.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Punishment_of_Heaven)
					sleep(10)
					Target.loc=locate(Target.PrevX,Target.PrevY,Target.PrevZ)
		else if(EffectType==3)
			spawn()
				RecoverImage(Target)
			spawn(2)
				RecoverImage(Target)
			spawn(4)
				RecoverImage(Target)
			sleep(12)
			Target.Leave_Body(ForceVoid=1.5)
		else if(EffectType==4)
			Target.Stasis=100
			sleep(30)
			animate(Target, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=3)
			sleep(3)
			animate(Target, alpha=0, time=2)
			var/z=pick(2,3,5,6,11,12)
			for(var/mob/m in view(10,Target))
				m<<"[Target] was cast out to another dimension!"
			Target.loc=locate(Target.x,Target.y,z)
			spawn(5)
				animate(Target, color=Target.MobColor, alpha=255)
				Target.Stasis=0


	FusionEffect(var/mob/User, var/mob/Target)
		User.Frozen=2
		Target.Frozen=2
		var/x=(User.x-Target.x)/2
		var/y=(User.y-Target.y)/2
		animate(User, pixel_x=x*(-32), pixel_y=y*(-32), color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=15)
		animate(Target, pixel_x=x*(32), pixel_y=y*(32), color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=15)
		sleep(20)
		if(User)
			User.Frozen=0
			animate(User, pixel_x=0, pixel_y=0, color=null)
		Target.Frozen=0
		animate(Target, pixel_x=0, pixel_y=0, color=null)

	PowerGathering(var/mob/m) //Handles shiny transes
		sleep(1)
		spawn(10)
			PowerGathering(m)
			KKTShockwave(m, icon='fevKiai.dmi', Size=0.5)

	TurfShift(var/Shift, var/turf/t, var/Time=30, var/mob/m, var/layer=MOB_LAYER-0.5, var/Spawn=10, var/Despawn=10,var/state, _piX, piY)
		if(!m) return
		var/image/i=image(icon=Shift, layer=layer, loc=t, dir = m.dir, pixel_x = _piX, pixel_y = piY)
		i.dir = m.dir
		i.mouse_opacity = 0
		animate(i, alpha=0)
		world << i
		if(Shift=='Icons/Turfs/GalSpace.dmi')
			i.icon_state = "[rand(1,25)]"
		if(Shift=='StarPixel.dmi')
			i.icon_state="[rand(1,2500)]"
		else if(state)
			i.icon_state=state
		else if(Shift=='Mandala.dmi')
			if(i.loc==m.loc||(get_dist(m.loc,i.loc)==1&&(i.x==m.x||i.y==m.y)))
				i.icon_state="2"
			else if(get_dist(m.loc,i.loc)==1)
				i.icon_state="3"
			else
				i.icon_state="[pick(4,1)]"
		else if(Shift=='amaterasu.dmi')
			i.layer=MOB_LAYER
			i.icon_state="[rand(1,13)]"
		flick(i.icon_state, i)
		animate(i, alpha=255, time=Spawn)
		spawn(10+Time)
			animate(i, alpha=0, time=Despawn)
			sleep(10)
			del i

	Crater(atom/A, Size=1)
		set waitfor=0
		if(!locate(/obj/Effects/Crater) in A.loc)
			var/obj/Effects/Crater/C=new
			C.loc=A.loc
			animate(C, transform=matrix()*Size, time=3)
			spawn(rand(30,90))  // kill
				animate(C, transform=matrix(), time = 1)
				spawn(3)  // me 
					del C
		else
			for(var/obj/Effects/Crater/B in A.loc)
				animate(B, transform=matrix()*Size, time=3)
				spawn(rand(30,90)) // kill 
					animate(B, transform=matrix(), time = 1)
					spawn(3) // me 
						del B
		
					
			

	Dust(turf/A, var/Size=1, var/Layer=EFFECTS_LAYER)
		set waitfor=0
		var/obj/Effects/Dust/D=new
		D.loc=A
		D.layer=Layer
		animate(D, transform=matrix()*Size, time=2)
		spawn(2)
			animate(D, alpha = 0, transform=D.transform*2, time = rand(15, 25), pixel_x = rand(-16*Size, 16*Size), pixel_y = rand(-16*Size, 16*Size))

	Bang(turf/A, var/Size=1, var/Layer=EFFECTS_LAYER, var/Offset=1, var/Vanish=4, var/PX=0, var/PY=0, var/icon_override)
		set waitfor=0
		var/obj/Effects/Explosion/E=new
		E.loc=A
		if(icon_override) E.icon = icon_override
		E.layer=Layer
		E.pixel_x+=PX
		E.pixel_y+=PY
		animate(E, transform=matrix()*Size, time=2)
		spawn(2)
			animate(E, alpha = 0, transform=E.transform*2, time = Vanish, pixel_x = rand(-16*Offset*Size, 16*Offset*Size), pixel_y = rand(-16*Offset*Size, 16*Offset*Size))
			sleep(Vanish)
			E.EffectFinish()

mob/proc
	ForceField()
		var/image/FF=image('Force Field.dmi',pixel_x=0,pixel_y=0, loc = src)
		FF.blend_mode=2
		world << FF
		animate(FF, alpha=0, time=0)
		animate(FF, alpha=175, time=5)
		sleep(10)
		animate(FF, alpha=0, time=5)
		sleep(5)
		del FF
		src.Shielding=0
	AvalonField()
		var/image/FF=image('AvalonMode.dmi',pixel_x=0,pixel_y=0, loc = src)
		FF.blend_mode=2
		world << FF
		animate(FF, alpha=0, time=0)
		animate(FF, alpha=175, time=5)
		sleep(10)
		animate(FF, alpha=0, time=5)
		sleep(5)
		del FF
		src.Shielding=0

	FlickeringGlow(var/mob/m, var/list/Glow=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)) //Handles shiny transes
		if(m.FlickeringGlow) return
		m.FlickeringGlow=1
		while(m.FlickeringGlow)
			animate(m, color=Glow, time=10, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
			sleep(10)
			animate(m, color=src.MobColor, time=10, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
			sleep(10)
		animate(m, color=src.MobColor, time=10, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
		m.FlickeringGlow=0
		return

	WindupGlow(var/mob/m) //Handles shiny transes
		if(m.WindingUp<1) return
		for(var/x in 1 to m.WindingUp+1)
			animate(m, color=list(1,0,0, 0.5,0.5,0, 0.5,0,0.5, 0,0,0), time=2, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
			sleep(2)
			animate(m, color=src.MobColor, time=2, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
			sleep(2)
		animate(m, color=src.MobColor, time=2, flags=ANIMATION_RELATIVE || ANIMATION_PARALLEL)
		return

	Kyoukaken(var/Z)
		var/image/MI
		var/mob/User=src
		var/mob/Target=src.Target
		if(Z=="On")
			Kyoukaken("Off")
			MI=image(Target.appearance, pixel_x=Target.pixel_x, pixel_y=Target.pixel_x)
			MI.alpha=100
			MI.transform*=1.6
			User.MirrorIcon=MI
			User.underlays+=User.MirrorIcon
		if(Z=="Off")
			User.underlays-=User.MirrorIcon
			User.MirrorIcon=null

	StasisEffect(var/Z)
		var/image/i=image('ice aura.dmi', pixel_x=-8, pixel_y=-2, layer=EFFECTS_LAYER, loc=src)
		var/image/i2=image('ice aura.dmi', pixel_x=-8, pixel_y=-2, layer=EFFECTS_LAYER, loc=src)
		i.appearance_flags=KEEP_APART | RESET_ALPHA | RESET_COLOR
		i.icon_state="Form"
		i2.appearance_flags=KEEP_APART | RESET_ALPHA | RESET_COLOR
		i2.icon_state=""
		world << i
		animate(i, alpha=0)
		if(Z=="Form")
			src.overlays-=i2
			src.StasisFrozen=1
			animate(i, alpha=255)
			spawn(9)
				src.overlays+=i2
				del i
		if(Z=="Thaw")
			src.overlays-=i2
			animate(i, alpha=255)
			i.icon_state="Thaw"
			spawn(6)
				del i
				src.StasisFrozen=0

	flash(dur, _color, rampup)
		set waitfor = 0
		if(!src.client) return
		animate(src.client, color = _color, time = rampup, easing = ELASTIC_EASING)
		sleep(rampup)
		animate(src.client, color = null, time = dur)

	drunkeffect(dur)
		set waitfor = 0
		if(!client) return
		if(!client.client_plane_master)
			client.client_plane_master = new()
			client.screen += client.client_plane_master
		client.client_plane_master.filters = filter(type="blur", size=1)
		sleep(dur)
		client.client_plane_master.filters = null

	Blind(var/duration=1000, startup = 2)
		if(!src.client) return
		animate(src.client, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=startup)
		sleep(startup)
		animate(src.client, color = null, time=duration)
	
	Darkness(duration=100, affect = 5)
		animate(src.client, color = list(-1,-1,-1, -1,-1,-1, -1,-1,-1, -1,-1,-1), time=affect)
		sleep(affect)
		animate(src.client, color = null, time=duration)