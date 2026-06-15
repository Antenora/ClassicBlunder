obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order // SOUL CALIBUR
	name="Blade of Order"
	icon='SoulCalibur.dmi'
	Element="Silver"
	Ascended=6
	Destructable=0
	ShatterTier=0
	var/caliburLight = TRUE

obj/Skills/Buffs/SlotlessBuffs/Defrost
	passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 5, "LifeSteal" = 10, "Chilling" = 2)
	WoundCost = 10
	TimerLimit = 60
	Cooldown = 160
	ActiveMessage = "has crystals grow up their sword arm as frost hovers in the air...!"
	OffMessage = "is released from the whims of Soul Calibur..."
	adjust(mob/p)
		TimerLimit = 60 + (p.SagaLevel * 5)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Frozen Crystal")
			passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 5, "LifeSteal" = 20, "Chilling" = 4)
		else
			passives = list("Unstoppable" = 1, "ShearImmunity" = 1, "LifeGeneration" = 3, "LifeSteal" = 10, "Chilling" = 2)

	verb/Defrost()
		set category = "Skills"
		adjust(usr)
		Trigger(usr)

obj/Skills/AutoHit/Crystal_Luminescene
	AllOutAttack=1
	Area="Circle"
	Distance=10
	StrOffense=0
	ForOffense=1
	DamageMult=2
	Flash=35
	SpecialAttack=1
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	TurfShift='BrightDay2.dmi'
	TurfShiftLayer=EFFECTS_LAYER
	TurfShiftDuration=-10
	TurfShiftDurationSpawn=0
	TurfShiftDurationDespawn=5
	ActiveMessage="raises Soul Calibur into the air to unleash a blinding glint of light from the crystals!"
	Cooldown=150
	EnergyCost=5
	adjust(mob/p)
		DamageMult = 2 + p.SagaLevel
		Flash = 35 + (p.SagaLevel*5)
	verb/Crystal_Luminescene()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Calibur
	name = "Heavenly Regalia: Frozen Crystal"
	DefMult=1.5
	EndMult=1.5
	passives = list("Flow" = 3, "VoidField" = 5, "DeathField" = 5, "Void" = 1, "SoftStyle" = 3, "TrueAbsorb"=1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s orderly treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their orderly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Soul_Conviction
		StyleActive="Soul Conviction"
		passives = list("LifeSteal" = 5,"Flow" = 2)
		StyleEnd=1.25
		StyleDef=1.25
		Finisher="/obj/Skills/Queue/Finisher/Geist_Destroyer"
		adjust(mob/p)
			StyleEnd = 1.05 + (0.05 * p.SagaLevel)
			StyleDef = 1.05 + (0.05 * p.SagaLevel)
			passives["LifeSteal"] = 5 + (5*p.SagaLevel)
			passives["Flow"] = 2 + (p.SagaLevel/2)
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
