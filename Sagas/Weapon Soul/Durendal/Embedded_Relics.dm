/*obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics
	NeedsSword = 1

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Tooth
	CantHaveTheseBuffs = list("Saints Blood", "Saints Hair", "Saints Raiment")
	HealthDrain = 0.05
	HealthThreshold = 1
	ManaGlow = "#dadada"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	passives = list("HolyMod" = 3)
	ActiveMessage = "'s legendary weapon edges itself with the Teeth of a Saint!"
	OffMessage = "'s legendary weapon no longer edges itself with teeth..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			HealthDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			HealthDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Tooth()
		set name = "Durendal: Saint's Tooth"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Blood
	EnergyDrain = 0.05
	EnergyThreshold = 10
	ManaGlow = "#cb2323"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	CantHaveTheseBuffs = list("Saints Tooth", "Saints Hair", "Saints Raiment")
	passives = list("EvilResist" = 3, "LifeGeneration" = 2)
	ActiveMessage = "'s legendary weapon drips with the Blood of a Saint."
	OffMessage = "'s legendary weapon no longer drips with holy blood..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			EnergyDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			EnergyDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Blood()
		set name = "Durendal: Saint's Blood"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Hair
	CantHaveTheseBuffs = list("Saints Blood", "Saints Tooth", "Saints Raiment")
	ManaDrain = 0.05
	ManaThreshold = 1
	ManaGlow = "#486edf"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	passives = list("EnergyGeneration" = 3, "SoftStyle" = 3, "HolyMod" = 2)
	ActiveMessage = "'s legendary weapon hardens with the Hair of a Saint."
	OffMessage = "'s legendary weapon no longer steels itself with holy fibers..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			ManaDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			ManaDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Hair()
		set name = "Durendal: Saint's Hair"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Raiment
	TimerLimit = 30
	Cooldown = 90
	ManaGlow = "#48df66"
	ManaGlowSize = 1
	CantHaveTheseBuffs = list("Saints Tooth", "Saints Blood", "Saints Hair")
	passives = list("PureDamage" = -5)
	ActiveMessage = "'s legendary weapon coils up their arm with the Raiment of a Saint."
	OffMessage = "'s legendary weapon releases their wielder's arm..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			Cooldown = 1
			TimerLimit = null
		else
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Raiment()
		set name = "Durendal: Saint's Raiment"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)*/

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Durendal_Relics
	NeedsSword = 1

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Durendal_Relics/Saints_Tooth
	CustomActive = "<b><font color='#dadada'>Your legendary weapon cuts with the Teeth of a Saint!</b></font>"
	ManaGlow = "#dadada"
	ManaGlowSize = 1
	BuffName = "Saint's Tooth"
	NeedsHealth = 90
	TooMuchHealth = 91
	HealthThreshold = 75
	EndMult = 1
	StrMult = 1
	AngerFloor = 50
	adjust(mob/p)
		if(altered) return
		passives = list("HolyMod" = 1, "Rage" = 1)
		StrMult = 1.15 + (p.SagaLevel/30)
		OffMult = 1.15 + (p.SagaLevel/30)
		EndMult = 1.15 + (p.SagaLevel/30)
		PowerMult = 1.05 + (p.SagaLevel/30)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
		// gain oozaru, but in base

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Durendal_Relics/Saints_Hair
	CustomActive = "<b><font color='#486edf'><font size=+1>Your legendary weapon hardens with the Hair of a Saint!</b></font size></font color>"
	ManaGlow = "#486edf"
	ManaGlowSize = 1
	BuffName = "Saint's Hair"
	NeedsHealth = 75
	TooMuchHealth = 76
	HealthThreshold = 50
	AngerFloor = 60
	adjust(mob/p)
		if(altered) return
		passives = list("Flicker" = 1 + round(p.SagaLevel/3,1), "Pursuer" = 1 + round(p.SagaLevel/3,1), "HolyMod" = 2, "Rage" = 2)
		StrMult = 1.2 + (p.SagaLevel/25)
		OffMult = 1.2 + (p.SagaLevel/25)
		EndMult = 1.2 + (p.SagaLevel/25)
		PowerMult = 1.075 + (p.SagaLevel/25)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Durendal_Relics/Saints_Raiment
	CustomActive = "<b><font color='#48df66'><font size=+1>Your legendary weapon coils up your arm with the Raiment of a Saint!</b></font size></font color>"
	ManaGlow = "#48df66"
	ManaGlowSize = 1
	BuffName = "Saint's Raiment"
	NeedsHealth = 50
	TooMuchHealth = 51
	HealthThreshold = 15
	AngerFloor = 70
	adjust(mob/p)
		if(altered) return
		passives = list("Powerhouse" = 1 + (p.SagaLevel/3), "Flicker" = 1 + round(p.SagaLevel/2,1), "Pursuer" = 1 + round(p.SagaLevel/2,1), "HolyMod" = 3, "Rage" = 3)
		StrMult = 1.25 + (p.SagaLevel/20)
		OffMult = 1.25 + (p.SagaLevel/20)
		EndMult = 1.25 + (p.SagaLevel/20)
		PowerMult = 1.1 + (p.SagaLevel/20)
		EnergyHeal = 0.005 * p.SagaLevel
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Durendal_Relics/Saints_Blood
	CustomActive = "<b><font color='#cb2323'><font size=+1>Your legendary weapon drips with the Blood of a Saint!</b></font size></font color>"
	OffMessage = "sets aside the legacy of a Saint, returning to being an ordinary mortal."
	ManaGlow = "#cb2323"
	ManaGlowSize = 1	
	BuffName = "Saint's Blood"
	NeedsHealth = 15
	TooMuchHealth = 16
	Enlarge = 2
	AngerFloor = 80
	adjust(mob/p)
		if(altered) return
		passives = list("Powerhouse" = 2 + (p.SagaLevel/2), "Flicker" = 1 + p.SagaLevel, "Pursuer" = 1 + p.SagaLevel, "HolyMod" = 4, "Rage" = 4)
		StrMult = 1.3 + (p.SagaLevel/10)
		OffMult = 1.3 + (p.SagaLevel/10)
		EndMult = 1.3 + (p.SagaLevel/10)
		PowerMult = 1.15 + (p.SagaLevel/10)
		EnergyHeal = 0.01 * p.SagaLevel
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()