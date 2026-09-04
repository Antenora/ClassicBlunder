mob
	var
		BuffHitSparkIcon//Icon that will display when striking
		BuffHitSparkX=0//x offset
		BuffHitSparkY=0//y offset
		BuffHitSparkLife=5//How many miliseconds it lasts before fading
		BuffHitSparkTurns=0//Does it turn? ala sword slash.
		BuffHitSparkSize=1//Size multiplier to the icon

		HitSparkIcon//Used for Autos
		HitSparkX=0
		HitSparkY=0
		HitSparkTurns=0
		HitSparkSize=1
		HitSparkCount=1
		HitSparkDispersion=8
		HitSparkDelay=0
		HitSparkLife=10
mob
	proc
		//New hit effect proc; src inflicts the effect on m.
		//src is kept track of to determine if they have a sword, or whatever.
		HitEffect(var/atom/movable/m, var/UnarmedAttack, var/SwordAttack, var/SecondStrike, var/ThirdStrike, var/AsuraStrike, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8), var/PX=0, var/PY=0, var/Weight=0, var/RawWeight=null, var/obj/AutoHitter/ink_root=null, var/ink_group=0)
			if(!m) return
			Weight = clamp(Weight, 0, 1)
			var/wsize = 1 + Weight*0.6 //hit weight: identity at 0, heavies read bigger
			var/wlife = round(Weight*3)
			var/gateWeight = isnull(RawWeight) ? Weight : clamp(RawWeight, 0, 1)
			var/obj/Skills/Queue/if_q = src.AttackQueue
			if((if_q && if_q.ImpactFrame) || gateWeight >= 0.99)
				FxHeavyImpact(m, if_q)
			if(glob.FLASH_RALLY && ismob(m) && Weight > 0.05)
				var/mob/bloomv = m
				if(world.time >= bloomv._flash_bloom_next)
					bloomv._flash_bloom_next = world.time + glob.FLASH_BLOOM_CD_DS
					FlashContactBloom(bloomv, Weight)
			if(src.AttackQueue&&src.AttackQueue.HitSparkIcon)
				var/obj/Effects/HE=new(null, src.AttackQueue.HitSparkIcon, src.AttackQueue.HitSparkX, src.AttackQueue.HitSparkY, src.AttackQueue.HitSparkTurns, src.AttackQueue.HitSparkSize*wsize)
				HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
				HE.dir=src.dir
				HE.pixel_z=m.pixel_z
				if(istype(m, /mob))
					HE.Target=m
				else
					HE.loc=m
				HE.Target=m
				m.vis_contents += HE
				HE.pixel_x+=DisperseX
				HE.pixel_y+=DisperseY
				if(ink_root && !ismob(m))
					ink_root.InkRegisterSpark(HE, ink_group)
			else if(HitScanHitSpark)
				var/AMT = 1
				var/icon=src.HitScanHitSpark
				var/iconx=src.HitScanHitSparkX
				var/icony=src.HitScanHitSparkY
				while(AMT)
					AMT--
					var/obj/Effects/HE=new(null, icon, iconx, icony, 0, wsize, 3+wlife)
					HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
					HE.dir=src.dir
					HE?.pixel_z=m?.pixel_z
					if(ismob(m))
						HE.Target=m
					else
						HE.loc=m
					m.vis_contents += HE
					if(ink_root && !ismob(m))
						ink_root.InkRegisterSpark(HE, ink_group)
					sleep(1)

			else if(src.HitSparkIcon)//used by autos
				var/AMT=src.HitSparkCount
				var/icon=src.HitSparkIcon
				var/iconx=src.HitSparkX
				var/icony=src.HitSparkY
				var/turns=src.HitSparkTurns
				var/size=src.HitSparkSize
				var/dispersion=src.HitSparkDispersion
				var/delay=src.HitSparkDelay
				var/life=src.HitSparkLife
				while(AMT)
					AMT--
					var/obj/Effects/HE=new(null, icon, iconx, icony, turns, size*wsize, life+wlife)
					HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
					HE.dir=src.dir
					HE?.pixel_z=m?.pixel_z
					if(istype(m, /mob))
						HE.Target=m
					else
						HE.loc=m
					m.vis_contents += HE
					HE.pixel_x+=rand((-1)*dispersion,dispersion)
					HE.pixel_y+=rand((-1)*dispersion,dispersion)
					if(!ismob(m)) //turf placement: apply the caller's sub-tile offset (a mob target already tracks it via vis_contents)
						HE.pixel_x+=PX
						HE.pixel_y+=PY
						if(ink_root)
							ink_root.InkRegisterSpark(HE, ink_group)
					sleep(delay)
			else if(src.BuffHitSparkIcon)
				var/obj/Effects/HE=new(null, src.BuffHitSparkIcon, src.BuffHitSparkX, src.BuffHitSparkY, src.BuffHitSparkTurns, src.BuffHitSparkSize*wsize)
				HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
				HE.dir=src.dir
				HE.pixel_z=m.pixel_z
				if(istype(m, /mob))
					HE.Target=m
				else
					HE.loc=m
				m.vis_contents += HE
				HE.pixel_x+=DisperseX
				HE.pixel_y+=DisperseY
				if(ink_root && !ismob(m))
					ink_root.InkRegisterSpark(HE, ink_group)
			else
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Sword/s2=src.EquippedSecondSword()
				var/obj/Items/Sword/s3=src.EquippedThirdSword()
				if(SwordAttack)
					if(!s)
						Slash(m, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
					if(s&&!s2)
						Slash(m, s, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
					else
						if(s&&!SecondStrike&&!ThirdStrike)
							Slash(m, s, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
						if(s2&&SecondStrike&&!ThirdStrike)
							Slash(m, s2, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
						if(s3&&SecondStrike&&ThirdStrike)
							Slash(m, s3, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
						if(s&&SecondStrike&&ThirdStrike&&AsuraStrike)
							Slash(m, s, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
				else
					Hit_Effect(m, Weight=Weight, ink_root=ink_root, ink_group=ink_group)
proc
	Slash(atom/movable/M, var/obj/Items/Sword/S, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8), var/Weight=0, var/obj/AutoHitter/ink_root=null, var/ink_group=0)
		if(M)
			var/obj/Effects/Slash/P = new
			P.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			if(S)
				if(S.HitSparkIcon)
					P.icon=S.HitSparkIcon
					if(S.HitSparkX)
						P.pixel_x=S.HitSparkX
					else
						P.pixel_x=0
					if(S.HitSparkY)
						P.pixel_y=S.HitSparkY
					else
						P.pixel_y=0
				P.transform*=S.HitSparkSize
				P.fx_size = S.HitSparkSize ? S.HitSparkSize : 1
			if(Weight > 0)
				P.transform *= 1 + min(Weight, 1)*0.6 //hit weight
				P.fx_size *= 1 + min(Weight, 1)*0.6
			P.Target=M
			M.vis_contents += P
			P.pixel_z=M.pixel_z
			P.pixel_x+=DisperseX
			P.pixel_y+=DisperseY
			if(ink_root && !ismob(M))
				ink_root.InkRegisterSpark(P, ink_group)
	Hit_Effect(atom/movable/M, var/Size=1, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8), var/Weight=0, var/obj/AutoHitter/ink_root=null, var/ink_group=0)
		if(M)
			var/obj/Effects/HitEffect/P = new
			P.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			P.transform*=Size
			P.fx_size = Size ? Size : 1
			if(Weight > 0)
				P.transform *= 1 + min(Weight, 1)*0.6 //hit weight
				P.fx_size *= 1 + min(Weight, 1)*0.6
			P.Target=M
			M.vis_contents += P
			P.pixel_z=M.pixel_z
			P.pixel_x+=DisperseX
			P.pixel_y+=DisperseY
			if(ink_root && !ismob(M))
				ink_root.InkRegisterSpark(P, ink_group)
	Scratch(atom/movable/M,Direc, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8))
		var/obj/Effects/Scratch/P = new
		P.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		P.dir=Direc
		P.Target=M
		M.vis_contents += P
		P.pixel_z=M.pixel_z
		P.pixel_x+=DisperseX
		P.pixel_y+=DisperseY
	LightningBolt(atom/movable/M, var/type=1, var/Offset)
		set waitfor=0
		switch(type)
			if(1)
				. = LightningStrike(M)
			if(2)
				. = LightningStrike2(M, Offset=Offset)
			if(3)
				. = LightningStrikeRed(M, Offset=Offset)
			if(4)
				. = LightningStrikeVFX5(M, Offset=Offset)
			if(5)
				. = LightningStrikeHyperdeath(M, Offset=Offset)
	EruptEffect(atom/movable/M, var/type=1, var/Offset=0)
		set waitfor=0
		switch(type)
			if(1)
				. = PriestErupt(M, Offset=Offset)

//HitBend: lean off the blow
var/list/_hb_cellh = list() //icon -> cell half-height: big-form icons (64px+) pin feet lower than 16
proc/_HbHalfHeight(f)
	if(!f) return 16
	var/k = "\ref[f]"
	var/h = _hb_cellh[k]
	if(!h)
		var/icon/I = new(f)
		h = I ? max(I.Height() / 2, 1) : 16
		_hb_cellh[k] = h
	return h
mob
	var/tmp
		_hitbend //debounce: one lean at a time keeps flurries subtle
	proc
		HitBend(weight = 0, hitdir = 0)
			if(_hitbend) return
			var/matrix/M = transform
			if(!M) M = matrix()
			if(M.b || M.d) return //rotating/thrown - leave the spin alone
			var/hh = _HbHalfHeight(icon) * abs(M.e) //half-height in screen px, tracks a live Enlarge
			if(!hh) return
			var/L = 1.5 + 4 * min(weight, 1) //head lean: 1.5px normals -> 5.5px max
			if(hitdir & WEST)
				L = -L
			else if(!(hitdir & EAST))
				_hb_flip = !_hb_flip
				if(_hb_flip)
					L = -L
			_hitbend = 1
			//feet stay pinned; PARALLEL so the bend doesn't cancel a pending hop or Enlarge
			var/matrix/bent = M * matrix(1, L/(2*hh), L/2, 0, 1, 0)
			animate(src, transform = bent, time = 1, flags = ANIMATION_PARALLEL)
			animate(transform = M, time = 5, easing = ELASTIC_EASING|EASE_OUT) //6 ticks total - outlives a 3ds HitStop freeze
			spawn(7)
				_hitbend = null

