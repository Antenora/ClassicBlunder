/obj/Skills/Buffs/NuStyle/EnergyStyle
	stage_flags = list(\
		list(),\
		list(),\
		list(),\
		list())

	Beam_Duelist
		StyleActive = "Beam Duelist"
		MenuIcon = "Kamehameha"
		passives = list("BeamHoldMastery" = 1, "MovingCharge" = 1)
		stage_passives = list(\
			list("BeamHoldMastery" = 1, "MovingCharge" = 1),\
			list("BeamHoldMastery" = 1, "MovingCharge" = 1, "SuperCharge" = 1),\
			list("BeamHoldMastery" = 2, "MovingCharge" = 1, "SuperCharge" = 2),\
			list("BeamHoldMastery" = 2, "MovingCharge" = 1, "SuperCharge" = 2, "Atomizer" = 1))
		verb/Beam_Duelist_Style()
			set hidden = 1
			src.Trigger(usr)

	Barrage
		StyleActive = "Barrage"
		MenuIcon = "RapidBarrage"
		passives = list("Volley" = 1, "Scatter" = 1)
		stage_passives = list(\
			list("Volley" = 1, "Scatter" = 1),\
			list("Volley" = 1, "Scatter" = 1, "Hail" = 1),\
			list("Volley" = 2, "Scatter" = 2, "Hail" = 2),\
			list("Volley" = 2, "Scatter" = 2, "Hail" = 2, "Saturation" = 1))
		verb/Barrage_Style()
			set hidden = 1
			src.Trigger(usr)

	Marksman
		StyleActive = "Marksman"
		MenuIcon = "SpiritGun"
		passives = list("BetterAim" = 2, "Ki Range" = 1)
		stage_passives = list(\
			list("BetterAim" = 2, "Ki Range" = 1),\
			list("BetterAim" = 2, "Ki Range" = 1, "Charged Shot" = 1),\
			list("BetterAim" = 4, "Ki Range" = 2, "Charged Shot" = 2),\
			list("BetterAim" = 4, "Ki Range" = 2, "Charged Shot" = 2, "Long Shot" = 1))
		verb/Marksman_Style()
			set hidden = 1
			src.Trigger(usr)

	Demolitions
		StyleActive = "Demolitions"
		MenuIcon = "BigBangAttack"
		passives = list("Blast Radius" = 1, "Shockwave" = 1)
		stage_passives = list(\
			list("Blast Radius" = 1, "Shockwave" = 1),\
			list("Blast Radius" = 1, "Shockwave" = 1, "Aftershock" = 1),\
			list("Blast Radius" = 2, "Shockwave" = 2, "Aftershock" = 2),\
			list("Blast Radius" = 2, "Shockwave" = 2, "Aftershock" = 2, "Concussive" = 1))
		verb/Demolitions_Style()
			set hidden = 1
			src.Trigger(usr)

	Ki_Fighter
		StyleActive = "Ki Fighter"
		MenuIcon = "NovaStrike"
		passives = list("Point Blank" = 1, "Setup" = 1)
		stage_passives = list(\
			list("Point Blank" = 1, "Setup" = 1),\
			list("Point Blank" = 1, "Setup" = 1, "AmuletBeaming" = 1),\
			list("Point Blank" = 2, "Setup" = 2, "AmuletBeaming" = 1),\
			list("Point Blank" = 2, "Setup" = 2, "AmuletBeaming" = 1, "BulletKill" = 1))
		verb/Ki_Fighter_Style()
			set hidden = 1
			src.Trigger(usr)
