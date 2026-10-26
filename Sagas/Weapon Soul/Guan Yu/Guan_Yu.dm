obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War // "Green Dragon Crescent Blade" / Guan Yu
	pixel_x = -16
	pixel_y = -16
	name = "Spear of War"
	icon = 'GreenDragonCrescentBlade_NoTrain.dmi'
	Destructable=0
	ShatterTier=0
	Ascended=6
	passives = list("SweepingStrike" = 1)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Guan_Yu
	name = "Heavenly Regalia: War King"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("CriticalChance" = 10, "CriticalDamage" = 0.15)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s warful treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their warful luster..."
	adjust(mob/p)
		if(p.SagaLevel >= 5)
			passives["TechniqueMastery"] = 2
			passives["SwordAscension"] = 1
			passives["LifeGeneration"] = 1
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)


/obj/Skills/AutoHit/Crushing_Dragon_Strike
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	Area="Arc"
	Rush = 2
	ControlledRush = 1
	MortalBlow=1
	StrScaling=1
	DamageMult=1.95
	Distance=1
	Shattering = 30
	Crippling=20
	GuardBreak=1
	ComboMaster=1
	Icon='roundhouse.dmi'
	IconX=-16
	IconY=-16
	HitSparkIcon='Slash.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	TurfShift='Dirt1.dmi'
	TurfShiftDuration=1
	EnergyCost=2
	Cooldown=8
	Instinct=1
	Earthshaking=5
	ActiveMessage="slams the Green Dragon Crescent Blade directly in front of them with immense might!"
	verb/CrushingDragonStrike()
		set name = "Crushing Dragon Strike"
		set category="Skills"
		usr.Activate(src)
	adjust(mob/p)
		DamageMult = (12 + p.SagaLevel) * 0.1147

/obj/Skills/AutoHit/War_God_Descent
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	Distance=15
	Gravity=5
	WindUp=1
	WindupMessage="prepares to cut through the very space around them in defiance of everything..."
	DamageMult = 2.33
	StrScaling=1
	Stunner = 1
	ActiveMessage="slashes through the very concept of space, breaking reality to force their desires onto the world with the might of War!"
	Area="Target"
	GuardBreak=1
	PassThrough=1
	MortalBlow=2
	Shattering = 70
	Shocking = 70
	Crippling = 30
	HitSparkIcon='Slash - Zan.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkTurns=1
	HitSparkSize=3
	Cooldown= 15
	EnergyCost=3
	Instinct=1
	adjust(mob/p)
		DamageMult= 2.33 + p.SagaLevel*0.33
		WindUp = 1
	verb/WarGodDescent()
		set name = "War God's Descent"
		set category="Skills"
		usr.Activate(src)