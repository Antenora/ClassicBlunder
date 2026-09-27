/obj/Skills/Buffs/NuStyle/GunStyle
	MenuIconFile = GUN_STYLE_ICON
	stage_finisher = list(1, 1, 2, 2)

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
		StyleOff = 1.1
		passives = list("Cold Barrel" = 1, "Living Turret" = 1)
		Finisher = "/obj/Skills/Projectile/GunFinisher/Dead_Center"
		Finisher2 = "/obj/Skills/Projectile/GunFinisher/Dead_Center/Empowered"
		stage_passives = list(\
			list("Cold Barrel" = 1, "Living Turret" = 1),\
			list("Cold Barrel" = 1, "Living Turret" = 1, "Last Round" = 1),\
			list("Cold Barrel" = 2, "Living Turret" = 2, "Last Round" = 1),\
			list("Cold Barrel" = 2, "Living Turret" = 2, "Last Round" = 1, "Headhunter" = 1))
		stage_stats = list(\
			list(1, 1, 1, 1, 1.1, 1),\
			list(1, 1, 1, 1, 1.15, 1),\
			list(1, 1, 1, 1, 1.2, 1),\
			list(1, 1, 1, 1, 1.25, 1))
		verb/Deadeye_Style()
			set hidden = 1
			src.Trigger(usr)

	Lead_Storm
		StyleActive = "Lead Storm"
		MenuIcon = "SMG"
		StyleStr = 1.05
		StyleDef = 0.95
		passives = list("Rolling Thunder" = 1, "Trigger Discipline" = 1)
		Finisher = "/obj/Skills/Projectile/GunFinisher/Lead_Curtain"
		Finisher2 = "/obj/Skills/Projectile/GunFinisher/Lead_Curtain/Empowered"
		stage_passives = list(\
			list("Rolling Thunder" = 1, "Trigger Discipline" = 1),\
			list("Rolling Thunder" = 1, "Trigger Discipline" = 1, "Belt Fed" = 1),\
			list("Rolling Thunder" = 2, "Trigger Discipline" = 2, "Belt Fed" = 1),\
			list("Rolling Thunder" = 2, "Trigger Discipline" = 2, "Belt Fed" = 1, "Marked for Death" = 1))
		stage_stats = list(\
			list(1.05, 1, 1, 1, 1, 0.95),\
			list(1.1, 1, 1, 1, 1, 0.95),\
			list(1.15, 1, 1, 1, 1, 0.95),\
			list(1.2, 1, 1, 1, 1, 0.95))
		verb/Lead_Storm_Style()
			set hidden = 1
			src.Trigger(usr)

	Breacher
		StyleActive = "Breacher"
		MenuIcon = "Shotgun"
		StyleStr = 1.05
		StyleEnd = 1.1
		StyleSpd = 0.9
		passives = list("Point Blank" = 1, "Full Spread" = 1)
		Finisher = "/obj/Skills/Projectile/GunFinisher/Doorbuster"
		Finisher2 = "/obj/Skills/Projectile/GunFinisher/Doorbuster/Empowered"
		stage_passives = list(\
			list("Point Blank" = 1, "Full Spread" = 1),\
			list("Point Blank" = 1, "Full Spread" = 1, "Gun Melee" = 1),\
			list("Point Blank" = 2, "Full Spread" = 2, "Gun Melee" = 1),\
			list("Point Blank" = 2, "Full Spread" = 2, "Gun Melee" = 1, "Trigger Happy" = 1))
		stage_stats = list(\
			list(1.05, 1, 1.1, 0.9, 1, 1),\
			list(1.08, 1, 1.13, 0.9, 1, 1),\
			list(1.12, 1, 1.17, 0.9, 1, 1),\
			list(1.15, 1, 1.2, 0.9, 1, 1))
		verb/Breacher_Style()
			set hidden = 1
			src.Trigger(usr)

	Gun_Runner
		StyleActive = "Gun Runner"
		MenuIcon = "TMP"
		StyleSpd = 1.15
		StyleDef = 0.9
		passives = list("Run and Gun" = 1, "Quick Hands" = 1)
		Finisher = "/obj/Skills/Projectile/GunFinisher/Fusillade"
		Finisher2 = "/obj/Skills/Projectile/GunFinisher/Fusillade/Empowered"
		stage_passives = list(\
			list("Run and Gun" = 1, "Quick Hands" = 1),\
			list("Run and Gun" = 1, "Quick Hands" = 1, "Strafe" = 1),\
			list("Run and Gun" = 2, "Quick Hands" = 2, "Strafe" = 1),\
			list("Run and Gun" = 2, "Quick Hands" = 2, "Strafe" = 1, "Intercept" = 1))
		stage_stats = list(\
			list(1, 1, 1, 1.15, 1, 0.9),\
			list(1, 1, 1, 1.18, 1, 0.9),\
			list(1, 1, 1, 1.22, 1, 0.9),\
			list(1, 1, 1, 1.25, 1, 0.9))
		verb/Gun_Runner_Style()
			set hidden = 1
			src.Trigger(usr)

	Close_Quarters
		StyleActive = "Close Quarters"
		MenuIcon = "Punisher"
		StyleStr = 1.05
		StyleSpd = 1.05
		passives = list("Setup" = 1, "Gun Melee" = 1)
		Finisher = "/obj/Skills/AutoHit/GunFinisher/Muzzle_Kick"
		Finisher2 = "/obj/Skills/AutoHit/GunFinisher/Muzzle_Kick/Empowered"
		stage_passives = list(\
			list("Setup" = 1, "Gun Melee" = 1),\
			list("Setup" = 1, "Gun Melee" = 1, "Point Blank" = 1),\
			list("Setup" = 2, "Gun Melee" = 2, "Point Blank" = 1),\
			list("Setup" = 2, "Gun Melee" = 2, "Point Blank" = 1, "Headhunter" = 1))
		stage_stats = list(\
			list(1.05, 1, 1, 1.05, 1, 1),\
			list(1.08, 1, 1, 1.07, 1, 1),\
			list(1.12, 1, 1, 1.08, 1, 1),\
			list(1.15, 1, 1, 1.1, 1, 1))
		verb/Close_Quarters_Style()
			set hidden = 1
			src.Trigger(usr)

	Spellslinger
		StyleActive = "Spellslinger"
		MenuIcon = "Photon Pistol"
		StyleFor = 1.1
		passives = list("Charged Rounds" = 1, "Arcane Rhythm" = 1)
		Finisher = "/obj/Skills/Projectile/GunFinisher/Arcane_Volley"
		Finisher2 = "/obj/Skills/Projectile/GunFinisher/Arcane_Volley/Empowered"
		stage_passives = list(\
			list("Charged Rounds" = 1, "Arcane Rhythm" = 1),\
			list("Charged Rounds" = 1, "Arcane Rhythm" = 1, "Quick Hands" = 1),\
			list("Charged Rounds" = 2, "Arcane Rhythm" = 2, "Quick Hands" = 1),\
			list("Charged Rounds" = 2, "Arcane Rhythm" = 2, "Quick Hands" = 1, "Marked for Death" = 1))
		stage_stats = list(\
			list(1, 1.1, 1, 1, 1, 1),\
			list(1, 1.15, 1, 1, 1, 1),\
			list(1, 1.2, 1, 1, 1, 1),\
			list(1, 1.25, 1, 1, 1, 1))
		verb/Spellslinger_Style()
			set hidden = 1
			src.Trigger(usr)
