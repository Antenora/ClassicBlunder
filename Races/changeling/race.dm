race
	changeling
		locked = FALSE
		name = "Changeling"
		icon_neuter	=	list('Chilled1.dmi')
		gender_options = list("Neuter")
		desc	=	"A race that carries immense inherent strength and potential, but finds it difficult to control. They're born with a series of transformations that allow them to unleash more of this latent potential."
		visual	=	'Changeling.png'

		passives = list()
		statPoints 	= 10
		power = 3;
		strength	=	0.25
		endurance	=	0.25
		force	=	0.25
		offense	=	1
		defense	=	1
		speed	=	1.75
		anger	=	1.15
		vitality = 5
		growth = 3
		anger_message = "will not stand for this mockery!!"

		onFinalization(mob/user)
			. = ..()
			user.transUnlocked=3

		onAnger(mob/user)
			. = ..()
			user.GetAndUseSkill(/obj/Skills/AutoHit/Imperial_Wrath, user.AutoHits, TRUE)
			StunClear(user)
			user.passive_handler.Increase("TeamHater", 1)
			if(user.Launched)
				LaunchEnd(user)

		onCalm(mob/user)
			user.passive_handler.Decrease("TeamHater", 1)