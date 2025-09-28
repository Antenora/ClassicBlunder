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
		HitEffect(var/atom/movable/m, var/UnarmedAttack, var/SwordAttack, var/SecondStrike, var/ThirdStrike, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8))
			if(!m) return
			if(src.AttackQueue&&src.AttackQueue.HitSparkIcon)
				var/obj/Effects/HE=new(src.AttackQueue.HitSparkIcon, src.AttackQueue.HitSparkX, src.AttackQueue.HitSparkY, src.AttackQueue.HitSparkTurns, src.AttackQueue.HitSparkSize)
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
			else if(HitScanHitSpark)
				var/AMT = 1
				var/icon=src.HitScanHitSpark
				var/iconx=src.HitScanHitSparkX
				var/icony=src.HitScanHitSparkY
				while(AMT)
					AMT--
					var/obj/Effects/HE=new(icon, iconx, icony, 0, 1, 3)
					HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
					HE.dir=src.dir
					HE?.pixel_z=m?.pixel_z
					if(ismob(m))
						HE.Target=m
					else
						HE.loc=m
					m.vis_contents += HE
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
					var/obj/Effects/HE=new(icon, iconx, icony, turns, size, life)
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
					sleep(delay)
			else if(src.BuffHitSparkIcon)
				var/obj/Effects/HE=new(src.BuffHitSparkIcon, src.BuffHitSparkX, src.BuffHitSparkY, src.BuffHitSparkTurns, src.BuffHitSparkSize)
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
			else
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Sword/s2=src.EquippedSecondSword()
				var/obj/Items/Sword/s3=src.EquippedThirdSword()
				if(SwordAttack)
					if(!s)
						Slash(m)
					if(s&&!s2)
						Slash(m, s)
					else
						if(s&&!SecondStrike&&!ThirdStrike)
							Slash(m, s)
						if(s2&&SecondStrike&&!ThirdStrike)
							Slash(m, s2)
						if(s3&&SecondStrike&&ThirdStrike)
							Slash(m, s3)
				else
					Hit_Effect(m)
proc
	Slash(atom/movable/M, var/obj/Items/Sword/S, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8))
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
			P.Target=M
			M.vis_contents += P
			P.pixel_z=M.pixel_z
			P.pixel_x+=DisperseX
			P.pixel_y+=DisperseY
	Hit_Effect(atom/movable/M, var/Size=1, var/DisperseX=rand(-8,8), var/DisperseY=rand(-8,8))
		if(M)
			var/obj/Effects/HitEffect/P = new
			P.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			P.transform*=Size
			P.Target=M
			M.vis_contents += P
			P.pixel_z=M.pixel_z
			P.pixel_x+=DisperseX
			P.pixel_y+=DisperseY
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
				LightningStrike(M)
			if(2)
				LightningStrike2(M, Offset=Offset)
			if(3)
				LightningStrikeRed(M, Offset=Offset)

