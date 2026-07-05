/obj/Skills/Queue/Finisher
	Sword_of_Awareness
		name = "Sword of Awareness"
		Warp = 4
		SpeedStrike = 3
		Decider = 2
		Instinct = 2
		InstantStrikes = 2
		DamageMult = 1.75
		KBAdd = 1
		KBDelayed = 1
		FollowUp = "/obj/Skills/AutoHit/Flash_Draw"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Awareness_Resonance"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Overwhelmed"
		HitMessage = "vanishes for a heartbeat, drawing their sword through pure instinct!"

	Instinct_Grapple
		name = "Instinct Grapple"
		Instinct = 2
		Grapple = 1
		KBMult = 0.001
		Opener = 2
		SweepStrike = 2
		InstantStrikes = 4
		Crushing = 20
		DamageMult = 1
		GrabTrigger = "/obj/Skills/Grapple/Instinct_Reversal"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Flow_State"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Thrown_Off_Balance"
		HitMessage = "reads their opponent’s intent and redirects their force in a perfect counter-grapple!"

	Dancing_Prism
		name = "Dancing Prism"
		Warp = 4
		Combo = 2
		InstantStrikes = 2
		DamageMult = 0.5
		Instinct = 2
		Shining = 2
		FollowUp = "/obj/Skills/AutoHit/Prismatic_Bloom"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Prismatic_Trance"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Disoriented_Aura"
		HitMessage = "spins in radiant motion, refracting their ki into a storm of dancing light!"

	Instinct_Palm
		name = "Instinct Palm"
		Warp = 2
		Combo = 4
		InstantStrikes = 2
		Stunner = 2
		DamageMult = 2
		Instinct = 2
		Quaking = 3
		PushOut = 1
		PushOutWaves = 1
		FollowUp = "/obj/Skills/AutoHit/Tranquil_Burst"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Stillness_of_Motion"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Disrupted_Flow"
		HitMessage = "meets their foe’s strike with perfect timing, a single palm erupting repeatedly with instinctive precision!"

//~~~~~~~~~~~~~~~~~~~~~~~~~~ Final Tier Finishers Beyond This Point!

	Sword_of_No_Thought
		name = "Sword of No Thought"
		Warp = 4
		SpeedStrike = 1
		Decider = 3
		Instinct = 3
		Combo = 4
		InstantStrikes = 2
		DamageMult = 0.5
		KBAdd = 2
		Shining = 2
		FollowUp = "/obj/Skills/AutoHit/Flash_Draw"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Awareness_Resonance"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Overwhelmed"
		HitMessage = "moves without intent, time and space itself yielding to their blade!"

	Heavenly_Suplex
		name = "Heavenly Suplex"
		Instinct = 3
		Grapple = 1
		KBMult = 0.001
		Opener = 2
		SweepStrike = 3
		InstantStrikes = 4
		Crushing = 30
		DamageMult =1
		GrabTrigger = "/obj/Skills/Grapple/Instinct_Reversal"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Flow_State"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Thrown_Off_Balance"
		HitMessage = "turns the opponent’s strength upon itself! Heaven and earth invert as they fall!"

	Prismatic_Samsara
		name = "Prismatic Samsara"
		Warp = 5
		Combo = 2
		InstantStrikes = 2
		DamageMult = 0.5
		Instinct = 3
		Shining = 3
		Explosive = 2
		FollowUp = "/obj/Skills/AutoHit/Prismatic_Bloom"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Prismatic_Trance"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Disoriented_Aura"
		HitMessage = "commands every element of ki to converge into an endless bloom of tranquil destruction!"

	Heavenly_Palm_Transcendence
		name = "Heavenly Palm: Transcendence"
		Warp = 3
		InstantStrikes = 10
		Stunner = 3
		DamageMult = 0.5
		Instinct = 3
		Quaking = 4
		PushOut = 2
		PushOutWaves = 1
		FollowUp = "/obj/Skills/AutoHit/Tranquil_Burst"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Stillness_of_Motion"
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Disrupted_Flow"
		HitMessage = "extends a single palm - stillness erupts, and all motion ceases!"
