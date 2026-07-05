

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Thrill_of_the_Hunt
	AlwaysOn = 1
	NeedsPassword = 1
	TimerLimit = 30
	Crippling = 15
	passives = list("Brutalize" = 1.5, "Afterimages" = 2, "Crippling" = 5)
	adjust(mob/p)
		Crippling= 5 + 5 * p.AscensionsAcquired
		passives = list("Brutalize" = 1.25 + (0.5 * p.AscensionsAcquired), "Godspeed" = p.AscensionsAcquired,  "Afterimages" = 2, "Crippling" = 5 + 5 * p.AscensionsAcquired)
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage
	TooMuchHealth = 35
	NeedsHealth = 10
	passives = list("Undying Rage" = 1)
	Cooldown = -1
	SpdMult=1.5
	DefMult=0.5
	EndMult=0.9
	ActiveMessage = "is too angry to die!"
	adjust(mob/p)
		TooMuchHealth = 35
		TimerLimit = 10 + (glob.racials.UNDYINGRAGE_DURATION * (p.AscensionsAcquired))
		var/wT = 1.5 - p.passive_handler["Wrathful Tenacity"]
		passives = list("Undying Rage" = 1, "Fury" = 1 + p.AscensionsAcquired, "Godspeed" = 3, "Relentlessness" = 1, "ShearImmunity" = 1, "Adrenaline" = 3, "LifeSteal" = 50 + (25 * p.AscensionsAcquired), \
						"Enrage" = p.AscensionsAcquired, "Rage" = p.AscensionsAcquired, "Wrathful Tenacity" = wT) // 150% of str as end
	Trigger(mob/User, Override)
		. = ..()
		if(!User.BuffOn(src))
			adjust(User)
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Feather_Cowl
	EnergyCost = 5
	WoundCost = 1
	Cooldown = 180
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		VaizardHealth = ((100-p.Health) * (0.1 + (glob.racials.COWLSHIELDVAL * asc) ) )
		passives = list("Harden" = clamp(asc, 1, 5), "Deflection" = 0.5 + (asc * 0.5), "Reversal" = 0.1 + (asc * 0.1))
		VaizardShatter = 1
		Cooldown = 180 - (asc * 15)

	verb/Feather_Cowl()
		set category = "Skills"
		Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Clean_Cuts
	IconLock = 'Innovator Wings.dmi'
	HitScanIcon = 'feathers.dmi'
	HitScanHitSpark = 'Slash_-_Ragna.dmi'
	EnergyCost = 3
	EnergyDrain = 0.05
	TimerLimit = 30
	Cooldown = 120
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		passives = list("Hit Scan" = 1 + (asc/2), "Momentum" = 2 + asc/2, "Fury" = 1 + asc/2, "Relentlessness" = 1, "Tossing" = clamp(asc/2, 0, 2.5),"AttackSpeed" = 1+asc,"BlurringStrikes" = 3+asc, "Flow" = asc, "Instinct" = asc)
		TimerLimit = 30 + (glob.racials.FEATHERDUR * asc)
		Cooldown = 120 - ((glob.racials.FEATHERDUR*2) * asc)
		EnergyDrain = 0.05 - (asc/100)
		if(EnergyDrain<0)
			EnergyDrain=0
	verb/Clean_Cuts()
		set category = "Skills"
		Trigger(usr)

/obj/Skills/AutoHit/Haymaker
    Copyable=0
    NeedsSword=0
    Area="Arc"
    StrOffense=1
    DamageMult=2
    Cooldown=5
    Distance=2
    Size=1
    FlickAttack=1
    ShockIcon='KenShockwave.dmi'
    Shockwave=2
    Shockwaves=1
    PostShockwave=1
    PreShockwave=0
    WindUp=0.25
    Earthshaking=20
    Instinct=1
    Icon='roundhouse.dmi'
    IconX=-16
    IconY=-16
    HitSparkIcon='Hit Effect.dmi'
    HitSparkX=-32
    HitSparkY=-32
    HitSparkTurns=1
    HitSparkSize=1.5
    HitSparkDispersion=1
    TurfStrike=1
    TurfShift='Dirt1.dmi'
    TurfShiftDuration=1
    ActiveMessage="unleashes a vacuum powered slash!"
    adjust(mob/p, dmg)
        var/asc = p.AscensionsAcquired
        DamageMult = dmg * 0.5 + (0.25*asc)
        Size = 3 + (1*asc)
        Distance = 4 + (1*asc)


