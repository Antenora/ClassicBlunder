/obj/Skills/Utility/Inner_Dragon_Wish
	name = "Inner Dragon Wish"
	desc = "Invoke the inner dragon to grant a powerful boon."
	Copyable = 0
	Cooldown = 604800 // one week!!!!!!!
	CooldownStatic = 1
	cooldown_start = 0
	cooldown_remaining = 0

	verb/Wish()
		set name = "Make a Wish"
		set desc = "Call upon your inner dragon to reshape destiny."
		set category = "Skills"

		var/mob/M = usr
		if(!M) return
		if(M.Class != "Dragon")
			M << "<font color=#77ff77><b>Your inner dragon slumbers. Only Namekian of the Dragon caste may call upon it.</b></font>"
			return

		if(src.cooldown_remaining || (world.realtime < src.cooldown_start + src.Cooldown))
			var/time_left = round((src.cooldown_start + src.Cooldown - world.realtime) / 86400, 0.1)
			M << "<font color=#77ff77><b>Your inner dragon has not yet awakened. Try again in [time_left] days.</b></font>"
			return

		var/choice = input(M, "What will you wish for?", "Inner Dragon Wish") in list("Increase Economy", "Unlock Ascension (Warrior only)", "Unlock Orange Namekian (Warrior only)", "Reclass to Warrior")
		if(!choice) return

		switch(choice)
			if("Increase Economy")
				if(M.EconomyMult <= 1)
					M.EconomyMult *= 2
					M << "<font color=#ffff77><b>Your inner dragon doubles your fortune!</b></font>"
				else
					M.EconomyMult += 0.15
					M << "<font color=#ffff77><b>Your inner dragon blesses your trade! Your economy multiplier rises to [round(M.EconomyMult, 0.01)]!</b></font>"

			if("Unlock Ascension (Warriors Only)")
				var/list/namekian_targets = list()
				for(var/mob/P in view(10, M))
					if(P != M && P.isRace(NAMEKIAN))
						namekian_targets["[P.name]"] = P

				if(!namekian_targets.len)
					M << "<font color=#aaaaaa><b>There are no Namekians nearby to bless...</b></font>"
					return

				var/asc_choice = input(M, "Whose ascension will you awaken?", "Choose Namekian") as anything in namekian_targets
				if(!asc_choice) return
				var/mob/target = namekian_targets[asc_choice]

				if(target.Class != "Warrior")
					M << "<font color=#ff7777><b>The dragon’s power rejects the unworthy. Only Warrior caste Namekians may be blessed.</b></font>"
					return
				if(target.AscensionsAcquired >= 3 && M.Potential<=45)
					M << "<font color=#ff7777><b>The dragon senses that [target]'s spirit cannot ascend further through this wish.</b></font>"
					return
				if(target.AscensionsAcquired >= 4 && M.Potential<=55)
					M << "<font color=#ff7777><b>The dragon senses that [target]'s spirit cannot ascend further through this wish.</b></font>"
					return
				var/ascension/next
				switch(target.AscensionsAcquired + 1)
					if(1) next = new /ascension/namekian/one
					if(2) next = new /ascension/namekian/two
					if(3) next = new /ascension/namekian/three
					if(4) next = new /ascension/namekian/four
					if(5) next = new /ascension/namekian/five
					if(6) next = new /ascension/namekian/six

				if(next)
					next.onAscension(target)
					M << "<font color=#77ffff><b>The dragon’s light flows into [target], awakening their next ascension!</b></font>"
					target << "<font color=#77ffff><b>Your soul resonates with the dragon’s call! Ascension [target.AscensionsAcquired] unlocked!</b></font>"
					Log("Admin", "[ExtractInfo(M)] granted [target]'s Ascension [target.AscensionsAcquired] via Inner Dragon Wish.")

			if("Unlock Orange Namekian (Warrior only)")
				var/list/namekian_targets = list()
				for(var/mob/P in view(10, M))
					if(P != M && P.isRace(NAMEKIAN))
						namekian_targets["[P.name]"] = P

				if(!namekian_targets.len)
					M << "<font color=#aaaaaa><b>There are no Namekians nearby to bless...</b></font>"
					return

				var/trans_choice = input(M, "Who will you grant hidden power to?", "Choose Namekian") as anything in namekian_targets
				if(!trans_choice) return
				var/mob/target = namekian_targets[trans_choice]

				if(target.transUnlocked >= 1)
					M << "<font color=#ff7777><b>The dragon’s power cannot unlock any further power for them...</b></font>"
					return

				target.transUnlocked = 1
				M << "<font color=#77ffff><b>The dragon’s light flows into [target], awakening their Orange Namekian power!</b></font>"
				target << "<font color=#77ffff><b>Your soul resonates with the dragon’s call! Your Orange Namekian power has been unlocked!</b></font>"
				Log("Admin", "[ExtractInfo(M)] granted [target]'s Orange Namekian via Inner Dragon Wish.")

			if("Reclass to Warrior")
				M.Class = "Warrior"
				M << "<font color=#77ff77><b>Your body surges with power, transforming you into a Namekian of the Warrior caste!</b></font>"

				if(M.AscensionsAcquired>=1)
					M.StrAscension += 0.35
					M.EndAscension += 0.35
					var/passives1 = list("Duelist" = 0.5, "TechniqueMastery" = 0.25, "Tenacity" = 0.5)
					M.passive_handler.increaseList(passives1)
				if(M.AscensionsAcquired>=2)
					M.StrAscension += 0.35
					M.EndAscension += 0.35
					var/passives2 = list("Duelist" = 1, "TechniqueMastery" = 0.5, "Tenacity" = 0.5)
					M.passive_handler.increaseList(passives2)
				if(M.AscensionsAcquired>=3)
					M.StrAscension += 0.65
					M.EndAscension += 0.65
					M.OffAscension += 0.65
					M.RecovAscension+= 0.65
					var/passives3 = list ("Duelist" = 2, "Extend" = 1, "Gum Gum" = 1, "TechniqueMastery" = 1, "Tenacity" = 0.5)
					M.passive_handler.increaseList(passives3)
				if(M.AscensionsAcquired>=4)
					var/passives4 = list("Duelist" = 2.5, "Extend" = 1, "Gum Gum" = 1, "TechniqueMastery" = 1, "Tenacity" = 0.5)
					M.passive_handler.increaseList(passives4)
					M.StrAscension += 1
					M.EndAscension += 0.35
					M.RecovAscension += 0.5
				if(M.AscensionsAcquired>=5)
					M.StrAscension += 1
					M.EndAscension += 1
				if(M.AscensionsAcquired>=6)
					M.StrAscension += 1
					M.EndAscension += 1

				if(M.AscensionsAcquired >= 4)
					M.transUnlocked = 1
					M << "<font color=#ff9933><b>The fire of the Orange Namekian ignites within you!</b></font>"

		src.Cooldown(1, src.Cooldown, M)
		M << "<font color=#77ff77><b>Your inner dragon returns to its slumber for a week...</b></font>"