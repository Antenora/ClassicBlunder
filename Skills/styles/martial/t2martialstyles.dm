/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Ubermensch_Style
		SignatureTechnique=2
		Copyable=0
		StyleEnd=1.3
		StyleStr=1.3
		passives = list("Muscle Power" = 4, "Grippy" = 5, "Scoop" = 2, "Iron Grip" = 1, "DeathField" = 3)
		StyleActive="Ubermensch"
		Finisher="/obj/Skills/Queue/Finisher/Command_Grab"
		verb/Ubermensch_Style()
			set hidden=1
			src.Trigger(usr)
	Mantis_And_Crane_Style
		passives = list("Acupuncture" = 2, "Interception" = 2, "Flow" = 2, "Soft Style" = 1, "FluidForm" = 1)
		StyleDef=1.45
		StyleEnd=1.45
		StyleStr=0.85
		StyleOff=0.85
		SignatureTechnique=2
		Copyable=0
		StyleActive="Mantis Style"
		Finisher="/obj/Skills/Queue/Finisher/Zetsuei"
		proc/swap_stance()
			if(StyleActive == "Mantis Style")
				StyleActive = "Crane Style"
				StyleDef=0.85
				StyleEnd=0.85
				StyleStr=1.45
				StyleOff=1.45
				passives = list("Fa Jin" = 3, "Momentum" = 2,"Fury" = 1, "BlurringStrikes" = 0.5, "Instinct" = 2)
				Finisher="/obj/Skills/Queue/Finisher/Teiga" // Ryukoha grapple follow up
			else
				StyleActive = "Mantis Style"
				StyleDef=1.45
				StyleEnd=1.45
				StyleStr=0.85
				StyleOff=0.85
				passives = list("Acupuncture" = 2, "Interception" = 2, "Flow" = 2, "Soft Style" = 1, "FluidForm" = 1)
				Finisher="/obj/Skills/Queue/Finisher/Zetsuei" // Shitenketsu, follow up
		verb/Swap_Stance()
			set category="Skills"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance()
			Trigger(usr, 1)
			giveBackTension(usr)
		verb/Mantis_And_Crane_Style()
			set hidden=1
			src.Trigger(usr)
	Long_Fist_Style
		passives = list("Fa Jin" = 2, "Gum Gum" = 1, "Acupuncture" = 1.5, "Flow" = 1, \
						"Momentum" = 1.5, "Hardening" = 1.5, "Pressure" = 1)
		StyleEnd=1.3
		StyleOff=1.15
		StyleDef=1.15
		SignatureTechnique=2
		Copyable=0
		StyleActive="Long Fist Style"
		Finisher="/obj/Skills/Queue/Finisher/Jarret_Jarret"
		verb/Long_Fist_Style()
			set hidden=1
			src.Trigger(usr)