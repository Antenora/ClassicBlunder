/obj/Skills/Buffs/NuStyle/SwordStyle
	Fist_of_Khonshu
		SignatureTechnique=1
		Copyable=0
		SwordPunching=1
		NeedsSword=0
		StyleOff=1.15
		StyleStr=1.15
		StyleDef=1.15
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Phalanx_Style", \
		"/obj/Skills/Buffs/NuStyle/SwordStyle/Kunst_des_Fechtens"="/obj/Skills/Buffs/NuStyle/SwordStyle/Witch_Hunter",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Divine_Arts_of_The_Heavenly_Demon",\
		"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style"="/obj/Skills/Buffs/NuStyle/UnarmedStyle/Phoenix_Eye_Fist")
		passives = list("HybridStyle" = "UnarmedStyle", "SwordPunching" = 1, "Secret Knives" = "Khonshu", "Tossing" = 1, "Extend" = 1)
		StyleActive="Fist of Khonshu"
		Finisher="/obj/Skills/Queue/Finisher/Moon_Fall"
		adjust(mob/p)
			passives = list("HybridStyle" = "UnarmedStyle", "SwordPunching" = 1, "Secret Knives" = "Khonshu", "Tossing" = 1, "Extend" = 1)
		verb/Fist_of_Khonshu()
			set hidden=1
			src.Trigger(usr)
	Nito_Ichi_Style
		SignatureTechnique=1
		Copyable=0
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu")
		passives = list("Fury" = 1, "DoubleStrike" = 1, "NeedsSecondSword" = 1, "Musoken" = 1)
		StyleActive="Two Swords as One"
		StyleOff=1.3
		StyleSpd=1.15
		NeedsSecondSword = 1
		Finisher="/obj/Skills/Queue/Finisher/Rashomon"
		verb/Nito_Ichi_Style()
			set hidden=1
			src.Trigger(usr)
	Iaido_Style
		SignatureTechnique=1
		Copyable=0
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu")
		passives = list("Iaijutsu" = 1, "Musoken" = 1, "BlurringStrikes" = 0.5)
		StyleActive="Seitei Iaido"
		StyleSpd=1.3
		StyleOff=1.15
		Finisher="/obj/Skills/Queue/Finisher/Roppon_me_Morote_Tsuki"
		verb/Iaido_Style()
			set hidden=1
			src.Trigger(usr)
	Dardi_Style
		SignatureTechnique=1
		Copyable=0
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu"="/obj/Skills/Buffs/NuStyle/SwordStyle/Phalanx_Style")
		passives = list("Parry" = 2, "Disarm" = 1.5, "Hardening" = 1, "Deflection" = 0.5)
		StyleActive="Dardi School"
		StyleOff=1.15
		StyleEnd=1.3
		Finisher="/obj/Skills/Queue/Finisher/Behemoth_Typhoon"
		verb/Dardi_Style()
			set hidden=1
			src.Trigger(usr)
	Kunst_des_Fechtens
		SignatureTechnique=1
		Copyable=0
		StyleComboUnlock=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu"="/obj/Skills/Buffs/NuStyle/SwordStyle/Witch_Hunter",
							"/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style"="/obj/Skills/Buffs/NuStyle/SwordStyle/Berserk")
		passives = list("Half-Sword" = 1.5, "Zornhau" = 1)
		StyleActive="Art of Fighting"
		StyleStr=1.3
		StyleOff=1.3
		StyleEnd=0.85
		Finisher="/obj/Skills/Queue/Finisher/Zwerchhau"
		verb/Kunst_des_Fechtens()
			set hidden=1
			src.Trigger(usr)