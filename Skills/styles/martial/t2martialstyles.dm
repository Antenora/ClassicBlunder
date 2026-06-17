/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Ubermensch_Style
		SignatureTechnique=2
		Copyable=0
		StyleEnd=1.3
		StyleStr=1.3
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Red_Cyclone_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/All_Star_Wrestling",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Jeet_Kune_Do")
		passives = list("Muscle Power" = 4, "Grippy" = 5, "Scoop" = 2, "DeathField" = 3)
		StyleActive="Ubermensch"
		Finisher="/obj/Skills/Queue/Finisher/Command_Grab"
		verb/Ubermensch_Style()
			set hidden=1
			src.Trigger(usr)
	Futae_No_Kiwami
		SignatureTechnique=2
		Copyable=0
		StyleEnd=1.15
		StyleStr=1.45
		passives = list("DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 2, "HardStyle"=1, "Instinct"=2)
		StyleActive="Futae no Kiwami"
		Finisher="/obj/Skills/Queue/Finisher/Mastery_of_Two_Layers"
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Flying_Thunder_God",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Jeet_Kune_Do")
		verb/Futae_No_Kiwami()
			set hidden=1
			src.Trigger(usr)
	Mantis_And_Crane_Style
		passives = list("Acupuncture" = 2, "Interception" = 2, "Flow" = 2, "SoftStyle" = 1, "FluidForm" = 1)
		StyleDef=1.45
		StyleEnd=1.45
		StyleStr=0.85
		StyleOff=0.85
		SignatureTechnique=2
		Copyable=0
		StyleActive="Mantis Style"
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Flying_Thunder_God",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Jeet_Kune_Do")
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
				passives = list("Acupuncture" = 2, "Interception" = 2, "Flow" = 2, "SoftStyle" = 1, "FluidForm" = 1)
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
						"Momentum" = 1.5, "Harden" = 1.5, "Pressure" = 1)
		StyleEnd=1.3
		StyleOff=1.15
		StyleDef=1.15
		SignatureTechnique=2
		Copyable=0
		StyleActive="Long Fist Style"
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style" = "/obj/Skills/Buffs/NuStyle/UnarmedStyle/Jeet_Kune_Do")
		Finisher="/obj/Skills/Queue/Finisher/Jarret_Jarret"
		verb/Long_Fist_Style()
			set hidden=1
			src.Trigger(usr)