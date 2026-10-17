/proc/NamekPathType(path)
	switch(path)
		if(NAMEK_PATH_DARK_WARRIOR)
			return /ascension/sub_ascension/namekian/dark_warrior
		if(NAMEK_PATH_SHADOW_KNIGHT)
			return /ascension/sub_ascension/namekian/shadow_knight
		if(NAMEK_PATH_DENDE_PRIEST)
			return /ascension/sub_ascension/namekian/dende_priest
		if(NAMEK_PATH_POKO_PRIEST)
			return /ascension/sub_ascension/namekian/poko_priest
		if(NAMEK_PATH_DEMON_KING)
			return /ascension/sub_ascension/namekian/demon_king
		if(NAMEK_PATH_CONQUEROR)
			return /ascension/sub_ascension/namekian/conqueror
	return null

/proc/NamekPathChoices(clan)
	var/list/out = list()
	for(var/path in NamekClanPaths(clan))
		out[path] = NamekPathType(path)
	return out

/proc/NamekPathPrompt(clan)
	var/list/paths = NamekClanPaths(clan)
	if(!paths.len)
		return ""
	var/msg = "The elders ask which path your clan will walk."
	for(var/path in paths)
		msg += "\n\n[path]: [NamekPathBlurb(path)]"
	return msg

ascension
	namekian
		proc
			NamekIndex()
				return 0

			NamekApplyClanAdds(mob/owner)
				var/list/adds = NamekAscensionAdds(owner ? owner.Class : null, NamekIndex())
				strength = adds ? adds[1] : 0
				endurance = adds ? adds[2] : 0
				force = adds ? adds[3] : 0
				offense = adds ? adds[4] : 0
				defense = adds ? adds[5] : 0
				speed = adds ? adds[6] : 0

		simulateChoiceMutation(mob/owner)
			NamekApplyClanAdds(owner)
			if(NamekIndex() >= 2)
				passives = NamekPathPassives(owner ? owner.NamekPath : null, NamekIndex())

		onAscension(mob/owner)
			if(!applied && !pickingChoice)
				simulateChoiceMutation(owner)
			. = ..()

		revertAscension(mob/owner)
			var/was = applied && !pickingChoice
			if(was)
				simulateChoiceMutation(owner)
			..()
			if(was && owner)
				owner.NamekSyncAll()

		postAscension(mob/owner)
			..()
			if(owner)
				owner.NamekSyncAll()

		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choiceTitle = "Namekian Path"
			NamekIndex()
				return 1
			choiceSelection(mob/owner)
				if(owner && !choiceSelected && !pickingChoice)
					choices = NamekPathChoices(owner.Class)
					choiceMessage = NamekPathPrompt(owner.Class)
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = NAMEK_ASC_ANGER
			NamekIndex()
				return 2

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			anger = NAMEK_ASC_ANGER
			NamekIndex()
				return 3

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = NAMEK_ASC_ANGER
			NamekIndex()
				return 4

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			anger = NAMEK_ASC_ANGER
			NamekIndex()
				return 5

		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = NAMEK_ASC_ANGER
			NamekIndex()
				return 6

ascension
	sub_ascension
		namekian
			var/namek_path

			onAscension(mob/owner)
				if(owner && !applied && !pickingChoice)
					owner.NamekPath = namek_path
					passives = NamekPathPassives(namek_path, 1)
				. = ..()

			revertAscension(mob/owner)
				var/was = applied && !pickingChoice
				if(was)
					passives = NamekPathPassives(namek_path, 1)
				..()
				if(was && owner && owner.NamekPath == namek_path)
					owner.NamekPath = null

			postAscension(mob/owner)
				..()
				if(owner)
					owner.NamekSyncAll()

			dark_warrior
				namek_path = NAMEK_PATH_DARK_WARRIOR

			shadow_knight
				namek_path = NAMEK_PATH_SHADOW_KNIGHT

			dende_priest
				namek_path = NAMEK_PATH_DENDE_PRIEST

			poko_priest
				namek_path = NAMEK_PATH_POKO_PRIEST

			demon_king
				namek_path = NAMEK_PATH_DEMON_KING

			conqueror
				namek_path = NAMEK_PATH_CONQUEROR
