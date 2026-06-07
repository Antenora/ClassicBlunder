race
	majin
		name = "Majin"
		desc = "Primordial ooze given shape from the overuse of magic, given life by Aether."
		visual = 'Majins.png'

		passives = list("StaticWalk" = 1, "SpaceWalk" = 1, "Steady" = 1, "DrainlessPUSpike" = 1, "MartialMagic" = 1, "BladeFisting" = 1)
		skills = list(/obj/Skills/Absorb, /obj/Skills/Release_Absorb, /obj/Skills/Buffs/SlotlessBuffs/Regeneration)

		locked = TRUE
		intellect = 1.25
		imagination = 4
		anger = 2
		regeneration = 4
		recovery = 3
		strength = 1.5
		endurance = 3
		speed = 1.5
		force = 1.5
		offense = 1.5
		defense = 1

		onFinalization(mob/user)
			..()
			var/obj/Skills/Buffs/regen = user.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
			regen.RegenerateLimbs = 1;
			user.findOrAddSkill(/obj/Skills/Release_Absorb)
			if(!user.majinPassive)
				user.majinPassive = new(user)
			if(!user.majinAbsorb)
				user.majinAbsorb = new(user)

		// ChangeRace hook: free the absorb room (releasing any victims), drop the
		// majin-only racial datums, and clear the once-per-ascension cheat-death
		// flag so an ex-Majin doesn't carry that state into another race.
		onChangeOut(mob/user)
			user.MajinCleanupOnDeletion()
			if(user.majinAbsorb)
				del(user.majinAbsorb)
				user.majinAbsorb = null
			if(user.majinPassive)
				del(user.majinPassive)
				user.majinPassive = null
			user.majinCheatDeathUsed = 0
