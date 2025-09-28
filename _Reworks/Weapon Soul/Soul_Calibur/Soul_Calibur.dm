obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order // SOUL CALIBUR
	name="Blade of Order"
	icon='SoulCalibur.dmi'
	Element="Silver"
	var/caliburLight = TRUE

obj/Skills/Buffs/SlotlessBuffs/Defrost
	passives = list("Unstoppable" = 1, "LifeGeneration" = 5, "LifeSteal" = 10, "Chilling" = 2)
	WoundCost = 10
	TimerLimit = 60
	Cooldown = 160
	ActiveMessage = "has crystals grow up their sword arm as frost hovers in the air...!"
	OffMessage = "is released from the whims of Soul Calibur..."
	adjust(mob/p)
		TimerLimit = 60 + (p.SagaLevel * 5)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Frozen Crystal")
			passives = list("Unstoppable" = 1, "LifeGeneration" = 5, "LifeSteal" = 20, "Chilling" = 4)
		else
			passives = list("Unstoppable" = 1, "LifeGeneration" = 3, "LifeSteal" = 10, "Chilling" = 2)

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
	passives = list("Flow" = 2, "VoidField" = 5, "DeathField" = 5, "Void" = 1, "SoftStyle" = 3)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s orderly treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their orderly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)