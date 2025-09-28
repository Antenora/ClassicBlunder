/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Move_Duplication
		BuffName = "Copy Wheel"
		Copyable = 0
		SagaSignature = 1
		passives = list("SwordPunching" = 1)
		NeedsSword = 0
		StyleActive = "Copy Wheel"
		adjust(mob/p)
			StyleOff = 1.1 + (0.05 * p.SagaLevel)
			StyleDef = 1.1 + (0.05 * p.SagaLevel)
			StyleSpd = 1.1 + (0.05 * p.SagaLevel)
		verb/Move_Duplication()
			set hidden=1
			src.Trigger(usr)
		
		Finisher="/obj/Skills/Queue/Finisher/Early_Sacrifice"


/obj/Skills/Queue/Finisher/Early_Sacrifice

	FollowUp="/obj/Skills/AutoHit/Shackling_Stakes"
	BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Sharingan_Perception"
	BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Genjutsud"
	DamageMult = 2
	HitMessage = "leaps over their enemy, then proceeds to unleash a combo!"
/obj/Skills/AutoHit/Shackling_Stakes
	AdaptRate = 1
	Stunner = 6
	Area="Target"
	DamageMult = 3
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Sharingan_Perception
	adjust(mob/p)
		passives = list("TechniqueMastery" = p.SagaLevel , "Godspeed" = round(p.SagaLevel/2,0.5), "ComboMaster" = 1, \
			"FluidForm" = round(p.SagaLevel / 3, 1) )
		DefMult = 1 + (0.05 * p.SagaLevel)
		OffMult = 1 + (0.05 * p.SagaLevel)
		SpdMult = 1 + (0.1 * p.SagaLevel)
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Genjutsud
	BuffName = "Gunjutsu'd"
	CrippleAffected = 3
	StunAffected = 3
	TimerLimit = 15