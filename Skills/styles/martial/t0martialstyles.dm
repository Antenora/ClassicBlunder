/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Lucha_Libre_Style
		Copyable = 0
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Red_Cyclone_Style", \
				"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shaolin_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style")
		StyleStr=1.15
		StyleEnd=1.15
		passives = list("Muscle Power" = 1, "Grippy" = 2, "Scoop" = 1)
		StyleActive="Lucha Libre"
		Finisher="/obj/Skills/Queue/Finisher/Hold"
		verb/Lucha_Libre_Style()
			set hidden=1
			src.Trigger(usr)
	Murim_Style
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shield_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style")
		StyleStr=1.1
		StyleEnd=1.1
		StyleSpd=1.1
		passives = list("Momentum" = 1)
		StyleActive="Heavenly"
		Finisher="/obj/Skills/Queue/Finisher/Heavenly_Storm_Dragon_Emergence"
		verb/Murim_Style()
			set hidden=1
			src.Trigger(usr)
	Shaolin_Style
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Lucha_Libre_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style")
		StyleStr=1.05
		StyleFor=1.05
		StyleEnd=1.05
		StyleSpd=1.05
		StyleOff=1.05
		StyleDef=1.05
		passives = list("Fa Jin" = 1)
		StyleActive="Shaolin"
		Finisher="/obj/Skills/Queue/Finisher/Merciful_Thousand_Leaves_Hand"
		verb/Shaolin_Style()
			set hidden=1
			src.Trigger(usr)
	Turtle_Style
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shaolin_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style",\
		"/obj/Skills/Buffs/NuStyle/MysticStyle/Fire_Weaving"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Black_Leg_Style")
		StyleStr=1.1
		StyleEnd=1.1
		StyleFor=1.1
		StyleActive="Turtle"
		passives = list("Flow" = 1, "Instinct" = 1 )
		Finisher="/obj/Skills/Queue/Finisher/Four_Virtues"
		verb/Turtle_Style()
			set hidden=1
			src.Trigger(usr)
	Shield_Style
		StyleEnd=1.2
		StyleSpd=0.9
		StyleStr=1.2
		StyleActive="Shield"
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Murim_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style")
		passives = list("Hardening" = 1)
		Finisher="/obj/Skills/Queue/Finisher/Shield_Bash"
		verb/Shield_Style()
			set hidden = 1
			src.Trigger(usr)