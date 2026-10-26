race
	namekian
		name = "Namekian"
		icon_neuter = list('Namek1.dmi')
		gender_options = list("Neuter")
		desc = "Namekians are green-skinned beings from various clans. The Warrior clan fights, the Dragon clan heals and forges Dragon Balls, and the Demon clan bends the inner dragon to its own ends."
		visual = 'Namek.png'

		power = 2.4
		statPoints = 10
		regeneration = 2
		recovery = 2
		imagination = 2
		intellect = 1.25
		learning = 1
		growth = 0.75
		anger = 1.5

		classes = list(NAMEK_CLAN_WARRIOR, NAMEK_CLAN_DRAGON, NAMEK_CLAN_DEMON)
		class_info = list("Front-liners who grow giant in battle.", "The magic caste: healers, Dragon Ball makers and Poko egg summoners.", "Destroyers who bend the inner dragon to their own ends.")
		stats_per_class = list(NAMEK_CLAN_WARRIOR = NAMEK_STATS_WARRIOR, NAMEK_CLAN_DRAGON = NAMEK_STATS_DRAGON, NAMEK_CLAN_DEMON = NAMEK_STATS_DEMON)

		onFinalization(mob/user)
			..()
			if(!user)
				return
			user.EnhancedHearing = 1
			user.NamekEvoApplied = 0
			user.NamekPath = null
			user.NamekSyncAll()

		onChangeOut(mob/user)
			..()
			if(user)
				user.NamekReleaseAll()
