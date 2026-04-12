// Angel Magic

/obj/Skills/Projectile/Magic/AngelMagic
	MagicNeeded = 0

/obj/Skills/Projectile/Magic/AngelMagic/Radiant_Lance
	name = "Radiant Lance"
	Cooldown = 60
	AngelMagicCompatible = 1
	EndRate = 0.8
	Distance = 20
	DamageMult = 2.5
	ManaCost = 5
	IconLock = 'HolyBeam.dmi'
	AccMult = 4
	Speed = 1
	Homing = 1
	HyperHoming = 1
	verb/Radiant_Lance()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Magic/AngelMagic
	AdaptRate = 1

/obj/Skills/AutoHit/Magic/AngelMagic/Consecration
	name = "Consecration"
	Cooldown = 60
	AngelMagicCompatible = 1
	ApplyJudged = 1
	Area = "Cone"
	Distance = 15
	DamageMult = 1.5
	AdaptRate = 1
	HolyMod = 1.5
	ManaCost = 6
	EnergyCost = 8
	Rounds = 1
	SpecialAttack = 1
	ActiveMessage = "unleashes a wave of sacred flames!"
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		if(Using || cooldown_remaining)
			return FALSE
		var/aaa = User.Activate(src)
		return aaa

/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Verdict
	name = "Divine Verdict"
	Area = "Around Target"
	AdaptRate = 1.5
	DamageMult = 0.5
	HolyMod = 2.5
	Distance = 5
	DistanceAround = 3
	EnergyCost = 10
	Rounds = 20
	TurfErupt = 1.25
	TurfEruptOffset = 6
	DelayTime = 1
	Stunner = 3
	ComboMaster = 1
	Icon = 'SwordHugeHolyJustice.dmi'
	Size = 0.5
	IconX = -159
	IconY = 0
	Falling = 1
	ActiveMessage = "gives their divine verdict."
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	color = rgb(255,241,135)
	alpha = 150
	Cooldown = 75
	AngelMagicCompatible = 1
	NeedsSword = 1
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		if(Using || cooldown_remaining)
			return FALSE
		var/aaa = User.Activate(src)
		return aaa
	verb/Divine_Verdict()
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic
	// placeholder

/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Revelation
	name = "Revelation"
	Cooldown = 60
	TimerLimit = 60
	OffMult = 1.2
	DefMult = 1.2
	passives = list("NoWhiff" = 1)
	ActiveMessage = "gains a divine revelation!"
	OffMessage = "ends their revelation."
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		return ..()

/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Zeal
	name = "Zeal"
	Cooldown = 60
	TimerLimit = 60
	StrMult = 1.2
	ForMult = 1.2
	passives = list("HybridStrike" = 1, "SpiritSword" = 1, "SpiritHand" = 1)
	ActiveMessage = "is filled with holy zeal!"
	OffMessage = "feels their zeal subside."
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		return ..()

/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Aegis
	name = "Aegis"
	Cooldown = 60
	TimerLimit = 60
	EndMult = 1.25
	passives = list("PureReduction" = 3)
	ActiveMessage = "shields themselves with divine aegis!"
	OffMessage = "releases their aegis."
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		return ..()

/obj/Skills/AutoHit/Magic/AngelMagic/Dazzle
	name = "Dazzle"
	Area = "Circle"
	AdaptRate = 1
	DamageMult = 0
	Flash = 18
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded"
	ActiveMessage = "releases a blinding burst of light!"
	Cooldown = 60
	ManaCost = 5
	EnergyCost = 5
	Rounds = 1
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		if(Using || cooldown_remaining)
			return FALSE
		var/aaa = User.Activate(src)
		return aaa
	verb/Dazzle()
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Magic/AngelMagic/Chains_of_Purity
	name = "Chains of Purity"
	Area = "Target"
	Distance = 12
	AdaptRate = 1
	Snaring = 5
	SnaringOverlay = 'root.dmi'
	ApplyJudged = 1
	DamageMult = 0.3
	ActiveMessage = "binds the target in chains of purity!"
	Cooldown = 60
	ManaCost = 6
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		if(Using || cooldown_remaining)
			return FALSE
		User.Activate(src)
		return TRUE
	verb/Chains_of_Purity()
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Sentence
	name = "Divine Sentence"
	Area = "Target"
	Distance = 12
	AdaptRate = 1
	ApplySentenced = 1
	DamageMult = 0.2
	ActiveMessage = "passes divine sentence upon the target!"
	Cooldown = 60
	ManaCost = 8
	Trigger(mob/User, Override = 0)
		if(!altered)
			adjust(User)
		if(Using || cooldown_remaining)
			return FALSE
		var/aaa = User.Activate(src)
		return aaa
	verb/Divine_Sentence()
		set category = "Skills"
		usr.Activate(src)
