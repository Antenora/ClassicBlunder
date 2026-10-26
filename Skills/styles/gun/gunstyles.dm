/obj/Skills/Buffs/NuStyle/GunStyle
	MenuIconFile = GUN_STYLE_ICON
	stage_flags = list(\
		list("NeedsGun" = 1),\
		list("NeedsGun" = 1),\
		list("NeedsGun" = 1),\
		list("NeedsGun" = 1))

	Trigger(mob/User, Override = 0)
		. = ..()
		if(User)
			User.GunStyleSync()

	StageChanged(mob/p)
		..()
		if(p)
			p.GunStyleSync()

	Deadeye
		StyleActive = "Deadeye"
		MenuIcon = "PSG"
		passives = list("Cold Barrel" = 1, "Living Turret" = 1)
		stage_passives = list(\
			list("Cold Barrel" = 1, "Living Turret" = 1),\
			list("Cold Barrel" = 1, "Living Turret" = 1, "Last Round" = 1),\
			list("Cold Barrel" = 2, "Living Turret" = 2, "Last Round" = 1),\
			list("Cold Barrel" = 2, "Living Turret" = 2, "Last Round" = 1, "Headhunter" = 1))
		verb/Deadeye_Style()
			set hidden = 1
			src.Trigger(usr)

	Lead_Storm
		StyleActive = "Lead Storm"
		MenuIcon = "SMG"
		passives = list("Rolling Thunder" = 1, "Trigger Discipline" = 1)
		stage_passives = list(\
			list("Rolling Thunder" = 1, "Trigger Discipline" = 1),\
			list("Rolling Thunder" = 1, "Trigger Discipline" = 1, "Belt Fed" = 1),\
			list("Rolling Thunder" = 2, "Trigger Discipline" = 2, "Belt Fed" = 1),\
			list("Rolling Thunder" = 2, "Trigger Discipline" = 2, "Belt Fed" = 1, "Marked for Death" = 1))
		verb/Lead_Storm_Style()
			set hidden = 1
			src.Trigger(usr)

	Breacher
		StyleActive = "Breacher"
		MenuIcon = "Shotgun"
		passives = list("Point Blank" = 1, "Full Spread" = 1)
		stage_passives = list(\
			list("Point Blank" = 1, "Full Spread" = 1),\
			list("Point Blank" = 1, "Full Spread" = 1, "Gun Melee" = 1),\
			list("Point Blank" = 2, "Full Spread" = 2, "Gun Melee" = 1),\
			list("Point Blank" = 2, "Full Spread" = 2, "Gun Melee" = 1, "Trigger Happy" = 1))
		verb/Breacher_Style()
			set hidden = 1
			src.Trigger(usr)

	Gun_Runner
		StyleActive = "Gun Runner"
		MenuIcon = "TMP"
		passives = list("Run and Gun" = 1, "Quick Hands" = 1)
		stage_passives = list(\
			list("Run and Gun" = 1, "Quick Hands" = 1),\
			list("Run and Gun" = 1, "Quick Hands" = 1, "Strafe" = 1),\
			list("Run and Gun" = 2, "Quick Hands" = 2, "Strafe" = 1),\
			list("Run and Gun" = 2, "Quick Hands" = 2, "Strafe" = 1, "Intercept" = 1))
		verb/Gun_Runner_Style()
			set hidden = 1
			src.Trigger(usr)

	Close_Quarters
		StyleActive = "Close Quarters"
		MenuIcon = "Punisher"
		passives = list("Setup" = 1, "Gun Melee" = 1)
		stage_passives = list(\
			list("Setup" = 1, "Gun Melee" = 1),\
			list("Setup" = 1, "Gun Melee" = 1, "Point Blank" = 1),\
			list("Setup" = 2, "Gun Melee" = 2, "Point Blank" = 1),\
			list("Setup" = 2, "Gun Melee" = 2, "Point Blank" = 1, "Headhunter" = 1))
		verb/Close_Quarters_Style()
			set hidden = 1
			src.Trigger(usr)

	Spellslinger
		StyleActive = "Spellslinger"
		MenuIcon = "Photon Pistol"
		passives = list("Charged Rounds" = 1, "Arcane Rhythm" = 1)
		stage_passives = list(\
			list("Charged Rounds" = 1, "Arcane Rhythm" = 1),\
			list("Charged Rounds" = 1, "Arcane Rhythm" = 1, "Quick Hands" = 1),\
			list("Charged Rounds" = 2, "Arcane Rhythm" = 2, "Quick Hands" = 1),\
			list("Charged Rounds" = 2, "Arcane Rhythm" = 2, "Quick Hands" = 1, "Marked for Death" = 1))
		verb/Spellslinger_Style()
			set hidden = 1
			src.Trigger(usr)
