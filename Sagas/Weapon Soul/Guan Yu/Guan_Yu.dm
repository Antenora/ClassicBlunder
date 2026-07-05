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
	passives = list("Zornhau" = 2, "Steady" = 2, "LikeWater" = 2, "Iaijutsu" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s warful treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their warful luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)

/obj/Skills/Queue/Finisher/Descending_Dragon
	DamageMult = 4
	HitSparkIcon='Slash - Zan.dmi'
	HitSparkX=-32
	HitSparkY=-32
	BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Strength_of_Guan_Yu"
	BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Reeling_Blow"
	HitMessage = "channels the wisdom of Guan Gong"

/obj/Skills/Buffs/NuStyle/SwordStyle/Gong_Bu
	StyleActive="Gong Bu"
	passives = list("Reversal" = 0.1, "Brutalize" = 0.5, "Parry" = 0.25)
	StyleEnd=1.1
	StyleStr=1.1
	Finisher="/obj/Skills/Queue/Finisher/Descending_Dragon"
	adjust(mob/p)
		StyleStr = 1.05 + (0.05 * p.SagaLevel)
		StyleEnd = 1.05 + (0.05 * p.SagaLevel)
		passives["Reversal"] = 0.1 + (0.2 * p.SagaLevel)
		passives["Brutalize"] = 0.5 + (0.5 * p.SagaLevel)
		passives["Parry"] = 0.25 + (0.25 * p.SagaLevel)
	verb/Gong_Bu()
		set hidden=1
		adjust(usr)
		Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Strength_of_Guan_Yu
	StrMult=1.3
	DefMult=1.15
	OffMult=1.15
	passives = list("Brutalize" = 2, "Disarm" = 2, "Iajutsu" = 2)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Reeling_Blow
	IconLock='SweatDrop.dmi'
	IconApart=1
	OffMult=0.8
	DefMult=0.8
	ActiveMessage="has their stance broken apart!"
	OffMessage="realigns themselves!"

/obj/Skills/AutoHit/Crushing_Dragon_Strike
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	Area="Arc"
	Rush = 2
	ControlledRush = 1
	MortalBlow=1
	StrOffense=1
	DamageMult=12
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
	EnergyCost=5
	Cooldown=30
	Instinct=1
	Earthshaking=5
	ActiveMessage="slams the Green Dragon Crescent Blade directly in front of them with immense might!"
	verb/CrushingDragonStrike()
		set name = "Crushing Dragon Strike"
		set category="Skills"
		usr.Activate(src)
	adjust(mob/p)
		DamageMult = 12 + p.SagaLevel