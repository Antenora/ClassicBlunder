/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
//T1 style buffs start here
	Awareness_Resonance//sword buff
		IconLock = 'SweatDrop.dmi'
		IconApart = 1
		StrMult = 1.15
		OffMult = 1.15
		DefMult = 1.1
		SpdMult = 1.25
		passives = list("Parry" = 2, "Deflection" = 2, "CounterMaster" = 2, "Momentum" = 2, "Flow" = 2, "LikeWater" = 2, "Duelist" = 1, "TensionLock" = 1)
		ActiveMessage = "moves in harmony with their sword, beyond thought."
		OffMessage = "releases their focused awareness."

	Flow_State//grapple buff
		IconLock = 'SweatDrop.dmi'
		IconApart = 1
		StrMult = 1.2
		EndMult = 1.2
		DefMult = 1.15
		SpdMult = 1.15
		passives = list("LikeWater" = 2, "Momentum" = 2, "Reversal" = 2, "CounterMaster" = 1, "Grippy" = 1, "Flow" = 2, "TensionLock" = 1)
		ActiveMessage = "moves with seamless instinct, every motion flowing into the next."
		OffMessage = "lets the rhythm of combat fade from their senses."

	Prismatic_Trance//mystic buff
		IconLock = 'SweatDrop.dmi'
		IconApart = 1
		ForMult = 1.25
		OffMult = 1.2
		SpdMult = 1.15
		DefMult = 1.1
		passives = list("SpiritFlow" = 2, "Amplify" = 1.5, "LikeWater" = 2, "Flow" = 2, "ManaStats" = 1, "Momentum" = 1, "TensionLock" = 1)
		ActiveMessage = "enters a prismatic trance, channeling balanced elemental instinct!"
		OffMessage = "lets the mirrored lights fade into stillness."

	Stillness_of_Motion//martial buff
		IconLock = 'SweatDrop.dmi'
		IconApart = 1
		StrMult = 1.2
		SpdMult = 1.15
		DefMult = 1.15
		EndMult = 1.1
		passives = list("Flow" = 2, "LikeWater" = 2, "Pressure" = 1.5, "Momentum" = 2, "Interception" = 2, "CounterMaster" = 2, "Deflection" = 1, "Reversal" = 1, "TensionLock" = 1)
		ActiveMessage = "enters total stillness - every strike guided by perfect awareness."
		OffMessage = "lets go of their centered calm."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff
	Overwhelmed//sword debuff
		TimerLimit = 30
		IconLock = 'Stun.dmi'
		IconApart = 1
		DefMult = 0.85
		EndMult = 0.9
		SpdMult = 0.9
		passives = list("ConfuseAffected" = 3, "Deflection" = -1)
		ActiveMessage = "is overwhelmed by the opponent's precision!"
		OffMessage = "steadies their resolve."

	Thrown_Off_Balance//grapple debuff
		TimerLimit = 15
		IconLock = 'Stun.dmi'
		IconApart = 1
		StrMult = 0.85
		DefMult = 0.9
		EndMult = 0.9
		SpdMult = 0.85
		passives = list("Instinct" = -2, "NoDodge" = 1, "Momentum" = -1)
		ActiveMessage = "loses their footing and composure!"
		OffMessage = "regains their stance."

	Disoriented_Aura//mystic debuff
		TimerLimit = 20
		IconLock = 'Stun.dmi'
		IconApart = 1
		SpdMult = 0.85
		ForMult = 0.85
		DefMult = 0.9
		passives = list("ConfuseAffected" = 3, "ManaLeak" = 1)
		ActiveMessage = "staggers as their elemental flow collapses!"
		OffMessage = "re-centers their aura."

	Disrupted_Flow//martial debuff
		TimerLimit = 30
		IconLock = 'Stun.dmi'
		IconApart = 1
		SpdMult = 0.9
		OffMult = 0.9
		DefMult = 0.9
		passives = list("Flow" = -1)
		ActiveMessage = "stumbles as their fighting rhythm falters!"
		OffMessage = "regains their composure."