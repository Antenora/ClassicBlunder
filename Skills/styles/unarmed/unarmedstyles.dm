/obj/Skills/Buffs/NuStyle/UnarmedStyle
	stage_flags = list(\
		list("NoSword" = 1, "NoStaff" = 1),\
		list("NoSword" = 1, "NoStaff" = 1),\
		list("NoSword" = 1, "NoStaff" = 1),\
		list("NoSword" = 1, "NoStaff" = 1))

	Grappler
		StyleActive = "Grappler"
		passives = list("Grippy" = 1, "Scoop" = 1)
		stage_passives = list(\
			list("Grippy" = 1, "Scoop" = 1),\
			list("Grippy" = 1, "Scoop" = 1, "Muscle Power" = 1),\
			list("Grippy" = 2, "Scoop" = 2, "Muscle Power" = 2),\
			list("Grippy" = 2, "Scoop" = 2, "Muscle Power" = 2, "Pile Driver" = 1))
		verb/Grappler_Style()
			set hidden = 1
			src.Trigger(usr)

	Interceptor
		StyleActive = "Interceptor"
		passives = list("Interception" = 1, "SoftStyle" = 1)
		stage_passives = list(\
			list("Interception" = 1, "SoftStyle" = 1),\
			list("Interception" = 1, "SoftStyle" = 1, "Sunyata" = 1),\
			list("Interception" = 2, "SoftStyle" = 2, "Sunyata" = 2),\
			list("Interception" = 2, "SoftStyle" = 2, "Sunyata" = 2, "CounterMaster" = 1))
		verb/Interceptor_Style()
			set hidden = 1
			src.Trigger(usr)

	Fa_Jin_Striker
		StyleActive = "Fa Jin Striker"
		passives = list("Fa Jin" = 1, "Gum Gum" = 1)
		stage_passives = list(\
			list("Fa Jin" = 1, "Gum Gum" = 1),\
			list("Fa Jin" = 1, "Gum Gum" = 1, "HardStyle" = 1),\
			list("Fa Jin" = 2, "Gum Gum" = 2, "HardStyle" = 2),\
			list("Fa Jin" = 2, "Gum Gum" = 2, "HardStyle" = 2, "Dim Mak" = 1))
		verb/Fa_Jin_Striker_Style()
			set hidden = 1
			src.Trigger(usr)

	Warp_Striker
		StyleActive = "Warp Striker"
		passives = list("Warping" = 2, "Backstabber" = 1)
		stage_passives = list(\
			list("Warping" = 2, "Backstabber" = 1),\
			list("Warping" = 2, "Backstabber" = 1, "Backshot" = 1),\
			list("Warping" = 3, "Backstabber" = 2, "Backshot" = 2),\
			list("Warping" = 3, "Backstabber" = 2, "Backshot" = 2, "Flying Thunder God" = 1))
		verb/Warp_Striker_Style()
			set hidden = 1
			src.Trigger(usr)

	Battlemage
		StyleActive = "Battlemage"
		passives = list("MartialMagic" = 1, "Spell Fist" = 1)
		stage_passives = list(\
			list("MartialMagic" = 1, "Spell Fist" = 1),\
			list("MartialMagic" = 1, "Spell Fist" = 1, "Chain Cast" = 1),\
			list("MartialMagic" = 1, "Spell Fist" = 2, "Chain Cast" = 2),\
			list("MartialMagic" = 1, "Spell Fist" = 2, "Chain Cast" = 2, "Deflection" = 1))
		verb/Battlemage_Style()
			set hidden = 1
			src.Trigger(usr)
