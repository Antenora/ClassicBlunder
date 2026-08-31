obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order // SOUL CALIBUR
	name="Blade of Order"
	icon='SoulCalibur.dmi'
	Element="Silver"
	Ascended=6
	Destructable=0
	ShatterTier=0
	var/caliburLight = TRUE
	var/caliburFinal = FALSE
	verb/Set_Sword_Class()
		if(usr.Saga != "Weapon Soul")
			usr << "Your soul does not resonate with Soul Calibur!"
			return
		Class = input("What form would you like the Blade of Order to take?") in list("Light", "Medium", "Heavy")
		usr << "Soul Calibur has transformed into a [Class] weapon!"
		setStatLine()

obj/Skills/Buffs/SlotlessBuffs/Defrost
	passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 3, "EnergyGeneration" = 3, "FatigueImmune" = 1)
	WoundCost = 10
	TimerLimit = 60
	Cooldown = 120
	ActiveMessage = "has crystals grow up their sword arm as frost hovers in the air...!"
	OffMessage = "is released from the whims of Soul Calibur..."
	adjust(mob/p)
		TimerLimit = 60 + (p.SagaLevel * 5)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Frozen Crystal")
			passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 6, "EnergyGeneration" = 6, "FatigueImmune" = 1)
		else
			passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 3, "EnergyGeneration" = 3, "FatigueImmune" = 1)
	verb/Defrost()
		set category = "Skills"
		adjust(usr)
		Trigger(usr)

obj/Skills/AutoHit/Crystal_Luminescence
	AllOutAttack=1
	Area="Circle"
	Distance=10
	ForScaling=2
	DamageMult=16.25
	Flash=6
	SpecialAttack=1
	HitSparkIcon='Blue_Effect.dmi'
	HitSparkX=-16
	HitSparkY=-16
	ActiveMessage="raises Soul Calibur into the air to unleash a blinding glint of light from the crystals!"
	Cooldown=40
	EnergyCost=18
	adjust(mob/p)
		DamageMult = (5 + p.SagaLevel) * 2.3214
		Flash = (35 + (p.SagaLevel*5)) * 0.1
		WoundRider = 0.1 * p.SagaLevel
	verb/Crystal_Luminescence()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/AutoHit/Crystal_Tomb
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	Distance=10
	WindUp=1
	WindupMessage="channels an oath of just order into Soul Calibur..."
	Area="Around Target"
	DistanceAround=7
	GuardBreak=1
	TurfStrike=1
	TurfShift='IceGround.dmi'
	TurfShiftDuration=500
	DamageMult=22.5
	ForScaling=2
	Executing=1
	Chilling=50
	ActiveMessage="encases their target in a tomb of soul-infused crystal!  They are forced into perfect stasis!"
	Stasis=6
	HitSparkIcon='Hit Effect Pearl.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=5
	HitSparkCount=9
	HitSparkDispersion=1
	Cooldown=40
	EnergyCost=25
	adjust(mob/p)
		DamageMult = (7 + p.SagaLevel) * 2.3214
		Chilling = 40 + (p.SagaLevel*10)
		Executing = 1 * p.SagaLevel
	verb/Crystal_Tomb()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Projectile/Crystal_Rose_Glass
	name = "Crystal Rose Glass"
	ElementalClass = "Water"
	SpellElement = "Water"
	IconLock = 'Ice.dmi'
	IconSize = 2
	LockX = -32
	LockY = -32
	Speed = 1.25
	Explode = 1
	Charge = 2
	Blasts = 1
	CounterShot = 1
	Delay = 0.1
	Distance = 15
	DamageMult = 5
	ForScaling = 1
	Shattering = 10
	Cooldown = 45
	verb/Crystal_Rose_Glass()
		set category = "Skills"
		if(!altered)
			DamageMult = 5 + (2 * usr.SagaLevel)
			Distance = 15 + (2 * usr.SagaLevel)
			Blasts = usr.SagaLevel
			Shattering = 3 * usr.SagaLevel
		usr.UseProjectile(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Calibur
	name = "Heavenly Regalia: Frozen Crystal"
	DefMult=1.5
	EndMult=1.5
	ForMult=1.5
	passives = list("VoidField" = 5, "DeathField" = 5, "SoulFire" = 5, "SoftStyle" = 5, "Freezing"= 5, "IceAge" = 50)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s orderly treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their orderly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Soul_Conviction
		StyleActive="Soul Conviction"
		passives = list("Crippling" = 5, "Chilling" = 5)
		StyleEnd=1.25
		StyleFor=1.25
		StyleDef=1.25
		Finisher="/obj/Skills/Queue/Finisher/Geist_Destroyer"
		adjust(mob/p)
			StyleEnd = 1.05 + (0.05 * p.SagaLevel)
			StyleFor = 1.05 + (0.05 * p.SagaLevel)
			StyleDef = 1.05 + (0.05 * p.SagaLevel)
			passives["Crippling"] = 5 + (5*p.SagaLevel)
			passives["Chilling"] = 5 + (5*p.SagaLevel)
		verb/Soul_Conviction()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Queue/Finisher
	Geist_Destroyer
		DamageMult=5
		InstantStrikes=2
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Eleusian_Initiation"
		HitMessage = "purifies the very world with the might of Soul Calibur!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Eleusian_Initiation
		StrMult=1.5
		EndMult=1.2
		passives = list("Extend" = 1, "LifeSteal" = 10, "SoftStyle" = 2)

/mob/Players/verb
	SoulCalignment()
		set name = "Soul Calibur Alignment"
		set category = "Roleplay"
		set hidden = 1
		if(!(world.time > src.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.ActiveBuff || usr.SpecialBuff || usr.SlotlessBuffs.len>0)
			usr << "Turn off all buffs before using this!"
			return
		for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order/soulc in usr.contents)
			if(soulc.caliburFinal == TRUE)
				usr << "You have made up your mind. You won't change your path again."
				return
			if(soulc.caliburLight == TRUE)
				if(alert("Your Weapon Soul hides a powerful darkness. Do you wish to embrace it?"))
					soulc.caliburLight = FALSE
					soulc.caliburFinal = TRUE
					soulc.icon= 'SoulCalibur-Crystal.dmi'
					usr << "You have been permanently subjugated into a thrall of authority!"
					return
			else if(soulc.caliburLight == FALSE)
				if(alert("You have yet to be completely subsumed by your Weapon Soul. Do you wish to live by your own terms again?"))
					soulc.caliburLight = TRUE
					soulc.caliburFinal = TRUE
					soulc.icon= 'SoulCalibur.dmi'
					usr << "You have been eternally freed to enforce your own will upon this world!"
			else
				usr << "Something went wrong. Contact an admin."
				return