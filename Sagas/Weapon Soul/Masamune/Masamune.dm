obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity//Masamune
	name="Sword of Purity"
	icon='Masamune.dmi'
	passives = list("Purity" = 1)
	Ascended=6
	ShatterTier=0
	Destructable=0

obj/Skills/AutoHit/Divine_Cleansing
	NeedsSword = 1
	Area="Circle"
	Slow=0.5
	StrScaling=1
	HitSelf = TRUE
	DamageMult=3.15//set in adjust code
	Cleansing = 1//set in adjust code
	Cooldown=8
	Rounds=1
	Distance = 5
	RoundMovement=1
	Shockwaves=3
	Shockwave=2
	ShockIcon = 'ShockwaveIce.dmi'
	Icon='HitEffectSnow.dmi'
	IconX=-32
	IconY=-32
	Size=10
	TurfStrike=1
	HitSparkIcon='SparkleBlue.dmi'
	HitSparkX = 0;
	HitSparkY = 0;
	HitSparkCount = 2;
	HitSparkDispersion = 8;
	TurfShift='SnowFloor.dmi'
	TurfShiftDuration = 10
	EnergyCost=2
	ActiveMessage="cuts through debilitation with the power of Masamune's purity!"
	adjust(mob/p)
		DamageMult = p.SagaLevel * 0.63
		Cleansing = p.SagaLevel
		Size = 5
	verb/Divine_Cleansing()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Masamune
	name = "Heavenly Regalia: Blessed Blade"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("Momentum" = 2) // may god have mercy on my soul
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s soothing treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their healing luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/SwordStyle
	Forgemaster_Lifeblood
		StyleActive="Forgemaster"
		passives = list( "EvilResist" = 1)
		StyleOff=1
		StyleDef=1
		Finisher="/obj/Skills/Queue/Finisher/Snowfall"
		adjust(mob/p)
			StyleOff = 1.10 + (0.10 * p.SagaLevel)
			StyleDef = 1 + (0.10 * p.SagaLevel)
			passives["EvilResist"] = 1 + (0.25* p.SagaLevel)
		verb/Forgemaster_Lifeblood()
			set hidden=1
			adjust(usr)
			Trigger(usr)

/obj/Skills/Queue/Finisher
	Snowfall
		DamageMult=2
		HitSparkIcon='Slash - Future.dmi'
		HitSparkX=-32
		HitSparkY=-32
		InstantStrikes=5
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Refined_Fate"
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Weapon_Soul_Hunt"
		HitMessage = "purifies their path with a single, freezing stroke!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Refined_Fate
		ForMult=1.2
		StrMult=1.2
		passives = list("BulletKill" = 1)
	Weapon_Soul_Hunt
		IconLock='SweatDrop.dmi'
		IconApart=1
		DefMult=0.8
		StrMult=0.9
		ActiveMessage="is hunted by weapons given life..."
		OffMessage="is no longer hunted."