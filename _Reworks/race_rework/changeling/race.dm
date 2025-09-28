race
	changeling
		locked = TRUE
		name = "Changeling"
		icon_neuter	=	list('Chilled1.dmi')
		gender_options = list("Neuter")
		desc	=	"A race with many transformations, their body is designed to handle the harshest of climates."
		visual	=	'Changeling.png'

		passives = list("Xenobiology" = 1, "Juggernaut" = 1, "CriticalBlock" = 0.25, "BlockChance" = 25, "PureReduction" = 3, "PureDamage" = -5, "AllOutAttack" = 1, "MovementMastery" = -8)
		statPoints 	= 8
		strength	=	0.25
		endurance	=	2
		force	=	0.25
		offense	=	1.5
		defense	=	1
		speed	=	1.75
		anger	=	1
		anger_point = 25
		anger_message = "will not stand for this mockery!!"

		onFinalization(mob/user)
			. = ..()
			user.Intimidation = 50
			user.BioArmorMax = 100
			user.BioArmor = user.BioArmorMax

		onAnger(mob/user)
			. = ..()
			user.GetAndUseSkill(/obj/Skills/AutoHit/Imperial_Wrath, user.AutoHits, TRUE)
			StunClear(user)
			user.passive_handler.Increase("TeamHater", 1)
			if(user.Launched)
				LaunchEnd(user)

		onCalm(mob/user)
			user.passive_handler.Decrease("TeamHater", 1)