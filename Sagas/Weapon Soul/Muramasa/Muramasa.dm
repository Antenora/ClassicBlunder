obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades//Muramasa
	name="Bane of Blades"
	icon='Muramasa.dmi'
	pixel_x=-16
	pixel_y=-16
	passives = list("WeaponBreaker" = 1)
	Ascended=6
	Destructable=0
	ShatterTier=0

/obj/Skills/Buffs/NuStyle/SwordStyle
	Grimreaper_Endbringer
		StyleActive="Grimreaper"
		passives = list( "GoodResist" = 1)
		StyleOff=1.3
		StyleSpd=1.2
		StyleStr=1.1
		adjust(mob/p)
			StyleOff = 1.3 + (0.2 * p.SagaLevel)
			StyleSpd = 1.2 + (0.1 * p.SagaLevel)
			StyleStr = 1.1 + (0.1 * p.SagaLevel)
			passives["GoodResist"] = 1 + (0.25* p.SagaLevel)
		verb/Grimreaper_Endbringer()
			set hidden=1
			adjust(usr)
			Trigger(usr)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Muramasa
	name = "Heavenly Regalia: The Death"
	StrMult=1.3
	OffMult=1.3
	SpdMult=1.3
	passives = list("Shearing" = 4, "Serrated" = 2, "CheapShot" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s deadly treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their deadly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
	verb/Toggle_Weapon_Breaker()
		set category="Roleplay"
		set hidden = 1
		if(!usr.passive_handler.Get("WeaponBreakerQOL"))
			usr.passive_handler.Set("WeaponBreakerQOL", 1)
			OMsg(usr, "<b>[usr] toggles off their Weapon Breaker!</b>")
		else if(usr.passive_handler.Get("WeaponBreakerQOL"))
			usr.passive_handler.Set("WeaponBreakerQOL", 0)
			OMsg(usr, "<b>[usr] toggles on their Weapon Breaker!</b>")

obj/Skills/AutoHit/Deathbringer
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	Distance=50
	WindUp=2
	WindupMessage="evokes the power of death..."
	DamageMult=20.75
	StrScaling=1
	ActiveMessage="slashes through their enemy in the blink of an eye, mortally wounding them!"
	Area="Target"
	GuardBreak=1
	StopAtTarget=1
	MortalBlow=2
	PostShockwave=0
	PreShockwave=1
	Shockwave=5
	Shockwaves=3
	ShockIcon='DarkKiai.dmi'
	HitSparkIcon='Slash - Hellfire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=2
	Cooldown=45
	EnergyCost=16
	verb/Deathbringer()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Grapple/Executioner
	ABuffNeeded="Soul Resonance"
	NeedsSword=1
	DamageMult=4
	StrScaling=1.5
	TriggerMessage="drives Death into"
	Effect="Strike"
	EffectMult=2
	Stunner=3
	Cooldown=90
	adjust(mob/p)
		DamageMult = 4 + (p.SagaLevel)
		StrScaling = 1.5 + (p.SagaLevel * 0.25)
		Cooldown = 90 - (p.SagaLevel * 5)
	verb/Executioner()
		set category="Skills"
		adjust(usr)
		src.Activate(usr)

/obj/Skills/AutoHit/Masterful_Death
	NeedsSword=1
	Area="Arc"
	Distance=7
	StrScaling=1
	DamageMult=1.15
	RoundMovement=0
	ComboMaster=1
	Rounds=10
	Cooldown=30
	DarknessFlame = 1
	Toxic = 20
	Burning = 20
	Icon='MasterSlash.dmi'
	IconX=-16
	IconY=-16
	Size=1.5
	HitSparkIcon='Slash - Zero.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	EnergyCost=8
	Instinct=1
	ActiveMessage="strikes everything with an wave of inevitable, masterful death."
	adjust(mob/p)
		DamageMult = (4 + (p.SagaLevel/2)) * 0.1769
		Size = 1.5 + p.SagaLevel
		Toxic = 20 * p.SagaLevel
		Burning = 20 * p.SagaLevel
		Cooldown = 90 - (p.SagaLevel * 5)
	verb/Masterful_Death()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)