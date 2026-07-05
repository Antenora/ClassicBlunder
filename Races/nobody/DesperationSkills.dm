obj/Skills/AutoHit/Desperation
	FatalEnding
		NeedsSword=1
		Distance=15
		Gravity=5
		WindUp=1
		WindupMessage="readies their Desperation Move...!"
		DamageMult=15
		StrOffense=1.5
		ActiveMessage="slashes through their enemy in the blink of an eye, aiming to mortally wound them!"
		Area="Target"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain"
		BuffSelfDelay=20
		GuardBreak=1
		PassThrough=1
		MortalBlow=1
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-16
		HitSparkY=-16
		HitSparkTurns=1
		HitSparkSize=3
		Cooldown=300
		EnergyCost=15
		Instinct=1
		NeedsHealth=30
		verb/Fatal_Ending()
			var/asc = usr.AscensionsAcquired
			set category="Skills"
			DamageMult=(15 * (1+asc))
			StrOffense=(1.5 * (1+asc))
			Cooldown=300-(10*(asc))
			usr.Activate(src)
	Deathscythe
		Area="Target"
		Distance=60
		WindUp=3
		WindupMessage="summons a massive scythe of dripping petals, slowly descending towards their target..."
		WindupIcon='SparkleRed.dmi'
		WindupIconY=32
		WindupColor=rgb(255, 100, 180)
		DamageMult=1
		FixedDamage=6.5
		NeedsHealth=20
		StrOffense=1
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain"
		BuffSelfDelay=30
		Cooldown=300
		EnergyCost=10
		Instinct=1
		MortalBlow=1
		HitSparkIcon='SparkleRed.dmi'
		HitSparkX=-16
		HitSparkY=-16
		HitSparkSize=2
		HitSparkTurns=1
		ActiveMessage="commands the scythe to strike, reaping the life from their target in a flurry of pink petals!"
		verb/Deathscythe()
			set category="Skills"
			var/asc = usr.AscensionsAcquired
			FixedDamage = 6.5 + (1 * asc)
			WindUp = max(1, 3 - (0.25 * asc))
			Cooldown = 300 - (10 * asc)
			usr.Activate(src)
/obj/Skills/Projectile/Zone_Attacks/Desperation
	UltimaLasers
		EnergyCost=20
		Speed = 0.10
		Distance=20
		Blasts=50
		Charge=1
		DamageMult=0.8
		ComboMaster=1
		Stunner= 3
		Instinct=1
		AccMult=2
		HyperHoming=1
		Deflectable=1
		Homing=3
		Explode=1
		ZoneAttackX=5
		ZoneAttackY=5
		IconLock='UltimaLaser.dmi'
		LockX=0
		LockY=0
		Hover=7
		Variation=0
		Cooldown = 300
		NeedsHealth=30
		ActiveMessage="fires off an impossible amount of energy bolts!"
		verb/Ultima_Lasers()
			set category="Skills"
			var/asc = usr.AscensionsAcquired
			DamageMult=0.5*(1+asc/2)
			Cooldown=300-(10*(asc))
			if (usr.HasTarget() && src.cooldown_start == 0)
				spawn(40)
					usr.buffSelf("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain")
			usr.UseProjectile(src)

	MagicHour
		IconLock='Blast2.dmi'
		Variation=4
		Blasts=20
		Speed = 0.5
		Distance=20
		HyperHoming=1
		Homing=3
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain"
		BuffSelfDelay=40
		NeedsSword=1
		Stunner=1.5
		ProjAuraOnCast='SweepingKick.dmi'
		ProjAuraUnder=1
		ProjAuraSize=1
		ProjAuraX=-32
		ProjAuraY=-32
		ProjAuraTime=10
		Deflectable = FALSE
		DamageMult=1.25
		ZoneAttackX=3
		ZoneAttackY=3
		FollowUp="/obj/Skills/Queue/Desperation/MagicFinale"
		FollowUpDelay=-1
		Cooldown=300
		EnergyCost=5
		NeedsHealth=30
		ActiveMessage="activates their Desperation Move, Magic Hour!"
		adjust(mob/p)
			if(!altered)
				var/asc = usr.AscensionsAcquired
				DamageMult=1.25*(1+asc/2)
				Cooldown=300-(10*(asc))
		verb/MagicHour()
			set category="Skills"
			if (usr.HasTarget() && src.cooldown_start == 0 && usr.EquippedSword())
				spawn()LeaveImage(User=usr, Image='SweepingKick.dmi', PX=usr.pixel_x+ProjAuraX, PY=usr.pixel_y+ProjAuraY, PZ=usr.pixel_z+ProjAuraZ, Size=ProjAuraSize, Under=ProjAuraUnder, Time=(max(1,ProjAuraTime)), AltLoc=0)
			usr.UseProjectile(src)



/obj/Skills/Queue/Desperation
	LunarRave
		name="Lunar Rave"
		ActiveMessage="is imbued with pure Lunar Wrath!"
		DamageMult=0.5
		AccuracyMult = 1.25
		KBMult=0.00001
		KBAdd=2
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Void_Drain"
		BuffSelfDelay=40
		Combo=12
		NeedsHealth=30
		Warp=3
		Duration=5
		Cooldown=380 //once per fight
		Decider=1
		Instinct=4
		EnergyCost=5
		HitSparkIcon='Slash - Power.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=1.1
		HitStep=/obj/Skills/Queue/Desperation/LunarRave2
		verb/Lunar_Rave()
			set category="Skills"
			var/asc = usr.AscensionsAcquired
			DamageMult=0.5*(1+asc/2)
			Cooldown=300-(10*(asc))
			usr.SetQueue(src)
	LunarRave2
		ActiveMessage="goes for the finishing blow!"
		DamageMult=12
		AccuracyMult = 1.25
		KBMult=10
		Warp=5
		Duration=5
		Decider=1
		Instinct=4
		EnergyCost=10
		NeedsHealth=30
		IconLock='UltraInstinctSpark.dmi'
		HitSparkIcon='Slash - Power.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=0
		HitSparkSize=2
		verb/Lunar_Rave()
			set category="Skills"
			var/asc = usr.AscensionsAcquired
			DamageMult=12*(1+asc/2)
			usr.SetQueue(src)

	MagicFinale
		name="Magic Finale"
		ActiveMessage="continues their assault!"
		DamageMult=0.5
		AccuracyMult = 1.25
		KBMult=0.00001
		KBAdd=2
		Combo=12
		Warp=50
		Duration=5
		Cooldown=-1 //once per fight
		Decider=1
		Instinct=4
		EnergyCost=5
		HitSparkIcon='Slash - Power.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=1.1
		adjust(mob/p)
			if(!altered)
				var/asc = usr.AscensionsAcquired
				DamageMult=0.5*(1+asc/2)
				Cooldown=300-(10*(asc))


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Void_Drain
		SpdMult=0.75
		StrMult=0.75
		EndMult=0.75
		TimerLimit = 20
		IconLock='SweatDrop.dmi'
		ActiveMessage="feels the exhaustion..."