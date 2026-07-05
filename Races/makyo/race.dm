race
	makyo
		name = "Makyo" //PLACEHOLDER
		desc = "A mortal race said to have blood ties to the demonic."
		visual = 'Makyos.png'
		locked = FALSE
		strength = 2
		endurance = 2
		speed = 1
		force = 1 // 1.25?
		offense = 1 // 1.25?
		defense = 1
		imagination = 2
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Awaken_Star_Power, /obj/Skills/Buffs/SlotlessBuffs/Makyo/Unbreakable, /obj/Skills/Utility/ExpandSizeToggle, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Inner_Malevolence)
		passives = list("Juggernaut" = 0.5, "DemonicDurability" = 0.5, "HeavyHitter" = 0.5)
		onFinalization(mob/user)
			. = ..()