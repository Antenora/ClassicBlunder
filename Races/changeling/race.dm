race
	changeling
		locked = TRUE
		name = "Changeling"
		icon_neuter	=	list('Chilled1.dmi')
		gender_options = list("Neuter")
		desc	=	"A race that carries immense inherent strength and potential, but finds it difficult to control. They are, however, capable of suppressing their power to make it easier to manage."
		visual	=	'Changeling.png'

		passives = list("Xenobiology" = 1, "Juggernaut" = 1, "CriticalBlock" = 0.25)
		statPoints 	= 10
		power = 3;
		strength	=	0.25
		endurance	=	0.25
		force	=	0.25
		offense	=	0.25
		defense	=	0.25
		speed	=	1.75
		anger	=	1.15
		vitality = 4
		growth = 3
		anger_message = "will not stand for this mockery!!"

		onFinalization(mob/user)
			. = ..()

		onAnger(mob/user)
			. = ..()
			user.GetAndUseSkill(/obj/Skills/AutoHit/Imperial_Wrath, user.AutoHits, TRUE)
			StunClear(user)
			user.passive_handler.Increase("TeamHater", 1)
			if(user.Launched)
				LaunchEnd(user)

		onCalm(mob/user)
			user.passive_handler.Decrease("TeamHater", 1)