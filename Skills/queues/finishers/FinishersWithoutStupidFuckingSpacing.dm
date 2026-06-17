/obj/Skills/Queue/Finisher
//t3
	Winds_Of_The_King
		DamageMult = 4
		Grapple=1
		FollowUp="/obj/Skills/AutoHit/Choukyuu_Haou_Deneidan"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/The_East_is_Burning_Red"

	Hyper_Goner
		FollowUp="/obj/Skills/Projectile/Zone_Attacks/Super_Hyper_Goner_Attack"
		DamageMult = 4
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Boss_Monster_Form"


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	The_East_is_Burning_Red
		IconLock='SweatDrop.dmi'
		StrMult=1.3
		EndMult=1.3
		passives = list("CallousedHands"=0.25, "Harden"=3, "Speed Force" = 2, "BlurringStrikes"=2)
	Boss_Monster_Form
		IconLock='SweatDrop.dmi'
		StrMult=1.3
		ForMult=1.3
		passives = list("SpiritFlow"=1, "SpiritSword"=1, "ManaStats" = 1)



/obj/Skills/AutoHit
	Choukyuu_Haou_Deneidan
		Area="Circle"
		DamageMult=1.1
		Rounds=10
		Knockback = 1
		ComboMaster=1
		Stunner=3
		Size=4
		StrOffense=1
		GuardBreak=1
		Rush=5
		PullIn=2
		ControlledRush=8
		Instinct=1
		TurfStrike=4
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=1
		ObjIcon = 1
		Icon='drill.dmi'
		IconX = -8
		IconY = -8
		ChargeTech = 1
		ActiveMessage="launches themselves forward, enveloping their entire body in a twister!!!"
/obj/Skills/Projectile
	Zone_Attacks
		ZoneAttack=1
		Super_Hyper_Goner_Attack
			Blasts=25
			Charge=2
			DamageMult=4
			Instinct=1
			AccMult=2
			Explode=1
			Distance=100
			ZoneAttackX=1
			ZoneAttackY=3
			Hover=10
			Variation=0
			ComboMaster=1
			IconLock='ChaosBlast.dmi'