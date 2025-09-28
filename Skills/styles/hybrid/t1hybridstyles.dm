/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Circuit_Breaker_Style
		passives = list("HybridStyle" = "MysticStyle", "SoulTug" = 1.5, \
				"SpiritFlow" = 1, "SpiritHand" = 1,  "Poisoning" = 3, "Rusting" = 2,
					 "BlindingVenom" = 1, "CyberStigma" = 2)
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/_Any" = /obj/Skills/Buffs/NuStyle/UnarmedStyle/Psycho_Boxing)
		ElementalClass = "Poison"
		ElementalOffense = "Poison"
		ElementalDefense = "Poison"
		Finisher = "/obj/Skills/Queue/Finisher/Maxima_Press"
		StyleFor = 1.25
		StyleStr = 1.25
		StyleActive = "Circuit Breaker"
		verb/Circuit_Breaker_Style()
			set hidden=1
			src.Trigger(usr)